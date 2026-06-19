# SBOM Summary — CycloneDX

**Generated:** 2026-06-19  
**Format:** CycloneDX 1.6  
**Tool:** cyclonedx-py 7.3.0  
**Total dependencies:** 4

---

## Dependency Table

| Package | Version | Category | Notes |
|---------|---------|----------|-------|
| `bcrypt` | *(unpinned)* | Security — Password Hashing | No version pinned |
| `pytest` | *(unpinned)* | Testing | No version pinned |
| `pyyaml` | *(unpinned)* | Serialization / Config Parsing | No version pinned |
| `requests` | `2.18.0` | HTTP Client | **Outdated** — released 2017; current stable is 2.32.x |

---

## Category Breakdown

| Category | Packages | Count |
|----------|----------|-------|
| Security | `bcrypt` | 1 |
| Testing | `pytest` | 1 |
| Serialization / Config | `pyyaml` | 1 |
| HTTP Client | `requests` | 1 |

---

## Outdated Dependencies

| Package | Pinned Version | Latest Stable | Risk |
|---------|---------------|---------------|------|
| `requests` | `2.18.0` | `2.32.x` | **High** — multiple security CVEs fixed since 2.18 (e.g. CVE-2023-32681, proxy credential leakage) |

---

## Recommendations

- **Pin all versions** — `bcrypt`, `pytest`, and `pyyaml` are unpinned, which can cause non-reproducible builds.
- **Upgrade `requests`** — version `2.18.0` is ~8 years old and has known vulnerabilities. Upgrade to `>=2.32.0`.
