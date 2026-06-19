# =============================================================================
# Dockerfile — Reminder Engine (lab07)
#
# Multi-stage build:
#   builder  — installs dependencies into a virtual environment
#   runtime  — lean final image with no build tooling
# =============================================================================

# ── Stage 1: dependency builder ───────────────────────────────────────────────
FROM python:3.12-slim AS builder

WORKDIR /build

# Install only the packages needed to compile wheels, then clean up in the
# same layer to minimise the intermediate image size.
RUN apt-get update \
    && apt-get install -y --no-install-recommends gcc libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy and install Python dependencies into an isolated virtual environment
# so the runtime stage can copy the whole directory cleanly.
COPY lab06/requirements.txt ./requirements.txt
RUN python -m venv /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir --upgrade pip \
    && /opt/venv/bin/pip install --no-cache-dir \
        -r requirements.txt \
        psycopg2-binary

# ── Stage 2: lean runtime image ───────────────────────────────────────────────
FROM python:3.12-slim AS runtime

# Install runtime shared libraries only (no build headers).
RUN apt-get update \
    && apt-get install -y --no-install-recommends libpq5 \
    && rm -rf /var/lib/apt/lists/*

# Run as a non-root user to follow the principle of least privilege.
RUN useradd --no-create-home --shell /bin/false appuser

WORKDIR /app

# Copy the virtual environment from the builder stage.
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy application source.
COPY lab06/ ./lab06/

# Copy the entrypoint script and make it executable.
COPY lab07/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER appuser

ENTRYPOINT ["/entrypoint.sh"]
