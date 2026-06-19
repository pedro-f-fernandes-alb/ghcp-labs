#!/bin/sh
# =============================================================================
# entrypoint.sh — Reminder Engine container startup
#
# Waits for the database to be reachable, then runs the scheduler in a loop.
# Writes a PID file so the Docker health check can verify the process is live.
# =============================================================================
set -eu

# ── Helper: log with timestamp ────────────────────────────────────────────────
log() {
    printf '%s [entrypoint] %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*"
}

# ── Wait for PostgreSQL to accept connections ─────────────────────────────────
DB_RETRIES=30
DB_DELAY=2

log "Waiting for database at ${DATABASE_URL%%@*}@... (up to $((DB_RETRIES * DB_DELAY))s)"

i=0
until python - <<'EOF'
import os, sys, psycopg2
try:
    conn = psycopg2.connect(os.environ["DATABASE_URL"], connect_timeout=3)
    conn.close()
    sys.exit(0)
except Exception:
    sys.exit(1)
EOF
do
    i=$((i + 1))
    if [ "$i" -ge "$DB_RETRIES" ]; then
        log "ERROR: database not reachable after $((DB_RETRIES * DB_DELAY))s — aborting."
        exit 1
    fi
    log "Database not ready yet (attempt $i/$DB_RETRIES). Retrying in ${DB_DELAY}s..."
    sleep "$DB_DELAY"
done

log "Database is ready."

# ── Write PID file for the health check ──────────────────────────────────────
echo $$ > /tmp/scheduler.pid
log "Scheduler PID $$ written to /tmp/scheduler.pid"

# ── Run the scheduler loop ────────────────────────────────────────────────────
INTERVAL="${SCHEDULER_INTERVAL_SECONDS:-300}"
log "Starting scheduler loop (interval=${INTERVAL}s)."

while true; do
    log "Running scheduler cycle..."
    python -m lab06.run_sprint_demo 2>&1 || log "WARNING: scheduler cycle exited non-zero."
    log "Cycle complete. Sleeping ${INTERVAL}s."
    sleep "$INTERVAL"
done
