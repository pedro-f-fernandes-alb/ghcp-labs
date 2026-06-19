# Security Scan Report — `requirements.txt`

**Scan Date:** 2026-06-19  
**Scanner:** pip-audit (OSV / PyPI Advisory Database)  
**Scope:** All `requirements.txt` files in the workspace

---

## Summary

| Metric | Count |
|--------|-------|
| Files scanned | 6 |
| Total packages evaluated | 56 (15 direct + 41 transitive) |
| Files with vulnerabilities | **1** (`lab07/requirements.txt`) |
| Files clean | 5 |
| Total unique CVEs found | **17** |
| 🔴 CRITICAL | 2 |
| 🟠 HIGH | 5 |
| 🟡 MEDIUM | 10 |
| 🟢 LOW | 0 |

> All vulnerabilities originate from **`lab07/requirements.txt`** via the single pinned dependency `requests==2.18.0` (released 2017), which pulls in equally outdated transitive packages (`urllib3==1.21.1`, `idna==2.5`).  
> The remaining five files — `lab02`, `lab03`, `lab05`, `lab06`, `lab08` — are **clean**.

---

## Findings

### File: `lab07/requirements.txt`

#### Package: `requests == 2.18.0`

| CVE ID | PYSEC ID | Severity | Fix Version | Description |
|--------|----------|----------|-------------|-------------|
| CVE-2018-18074 | PYSEC-2018-28 | 🔴 CRITICAL (9.8) | 2.20.0 | HTTP `Authorization` header forwarded to a downgraded HTTP URI on same-hostname HTTPS→HTTP redirect, leaking credentials in plaintext. |
| CVE-2023-32681 | PYSEC-2023-74 | 🟡 MEDIUM (6.1) | 2.31.0 | `Proxy-Authorization` header leaked to destination server during HTTPS→HTTPS and HTTP→HTTPS redirects when proxy credentials are embedded in the URL. |
| CVE-2024-35195 | — | 🟡 MEDIUM (5.6) | 2.32.0 | `verify=False` sessions bypass certificate verification for subsequent requests even when verification is re-enabled within the same session object. |
| CVE-2024-47081 | — | 🟡 MEDIUM (6.1) | 2.32.4 | URL netloc parsed incorrectly, potentially enabling request dispatch to an unintended host. |
| CVE-2026-25645 | — | 🟡 MEDIUM | 2.33.0 | Credential exposure via crafted multi-hop redirect chains (GHSA-gc5v-m9x4-r6x2). |

---

#### Package: `idna == 2.5` *(transitive dependency of requests)*

| CVE ID | PYSEC ID | Severity | Fix Version | Description |
|--------|----------|----------|-------------|-------------|
| CVE-2024-3651 | PYSEC-2024-60 | 🟠 HIGH (7.5) | 3.7 | ReDoS (Regular Expression Denial of Service) via a specially crafted hostname passed to `idna.encode()`, allowing CPU exhaustion. |
| CVE-2026-45409 | PYSEC-2026-215 | 🟠 HIGH | 3.15 | Denial of service via malformed internationalized domain names causing unbounded processing (GHSA-65pc-fj4g-8rjx). |

---

#### Package: `urllib3 == 1.21.1` *(transitive dependency of requests)*

| CVE ID | PYSEC ID | Severity | Fix Version | Description |
|--------|----------|----------|-------------|-------------|
| CVE-2018-20060 | PYSEC-2018-32 | 🔴 CRITICAL (9.8) | 1.23 | `Authorization` header not stripped on cross-origin redirect, leaking credentials to attacker-controlled third-party hosts. |
| CVE-2018-25091 | PYSEC-2023-207 | 🟠 HIGH (7.5) | 1.24.2 | `Authorization` header forwarded when the redirect target hostname changes. |
| CVE-2019-11324 | PYSEC-2019-133 | 🟠 HIGH (7.5) | 1.24.2 | Incorrect CA certificate validation logic; `certifi` bundle overrides system trust store in edge cases, enabling MITM attacks. |
| CVE-2023-43804 | PYSEC-2023-192 | 🟠 HIGH (8.1) | 1.26.17 / 2.0.6 | `Cookie` header not stripped on cross-origin redirect, potentially exposing session tokens to attacker-controlled servers. |
| CVE-2019-11236 | PYSEC-2019-132 | 🟡 MEDIUM (6.5) | 1.24.3 | CRLF injection via crafted URL path, enabling HTTP response splitting and header injection. |
| CVE-2020-26137 | PYSEC-2020-148 | 🟡 MEDIUM (6.5) | 1.25.9 | CRLF injection via crafted HTTP method string, allowing request header manipulation. |
| CVE-2023-45803 | PYSEC-2023-212 | 🟡 MEDIUM (4.2) | 1.26.18 / 2.0.7 | Request body not removed when redirected from POST to GET (303 response), potentially leaking payloads. |
| CVE-2024-37891 | — | 🟡 MEDIUM (4.4) | 1.26.19 / 2.2.2 | `Proxy-Authorization` header forwarded to destination server during HTTPS CONNECT tunnel redirects. |
| CVE-2025-50181 | — | 🟡 MEDIUM | 2.5.0 | Information disclosure via header handling in proxy tunneling scenarios (GHSA-pq67-6m6q-mj2v). |
| CVE-2025-66471 | — | 🟡 MEDIUM | 2.6.0 | HTTP request smuggling vulnerability via malformed chunked transfer encoding (GHSA-2xpw-w6gg-jr37). |

---

## Remediation Plan

### Root Cause

All 17 vulnerabilities trace back to **one outdated pinned version**: `requests==2.18.0` in `lab07/requirements.txt`. This 2017 release pulls in `urllib3==1.21.1` and `idna==2.5`, both of which have accumulated a decade of unpatched CVEs.

---

### Priority 1 — Fix CRITICAL and HIGH vulnerabilities immediately

| Package | Current | Action | Target Version |
|---------|---------|--------|----------------|
| `requests` | 2.18.0 | Upgrade | `>=2.33.0` |
| `urllib3` | 1.21.1 (transitive) | Add explicit pin | `>=2.6.0` |
| `idna` | 2.5 (transitive) | Add explicit pin | `>=3.15` |

**Proposed `lab07/requirements.txt`:**
```
pytest
bcrypt
pyyaml
requests>=2.33.0
urllib3>=2.6.0
idna>=3.15
```

These three changes resolve all 17 findings.

---

### Priority 2 — Process improvements

| Action | Detail |
|--------|--------|
| **CI/CD gate** | Add `pip-audit -r requirements.txt` as a required check on every pull request. Fail the build on any HIGH or CRITICAL finding. |
| **Replace exact pins with minimum bounds + lockfile** | Use `pip-compile` (pip-tools) or `uv lock` to generate reproducible lockfiles from `>=` bounds, rather than hard-pinning outdated exact versions. |
| **Pin unpinned packages** | `bcrypt` and `pyyaml` in `lab07/requirements.txt` are currently unversioned. While clean today, unpinned packages create supply-chain risk. Pin them to verified minimum versions. |
| **Dependabot / Renovate** | Enable automated dependency update PRs to prevent version drift going forward. |

---

### Clean Files (no action required)

| File | Packages Checked | Status |
|------|-----------------|--------|
| `lab02/requirements.txt` | 15 | ✅ Clean |
| `lab03/requirements.txt` | 5 | ✅ Clean |
| `lab05/requirements.txt` | 12 | ✅ Clean |
| `lab06/requirements.txt` | 5 | ✅ Clean |
| `lab08/requirements.txt` | 7 | ✅ Clean |

## Dependency & Supply Chain Policy

- **SBOM requirement**: All releases must include an updated SBOM
- **Vulnerability scanning**: Mandatory before PR merge
- **Severity thresholds**: 
  - CRITICAL: Block merge immediately, remediate before release
  - HIGH: Address within 72 hours
  - MEDIUM: Address within 2 weeks
  - LOW: Track and batch with regular updates
- **Update cadence**: Dependencies reviewed and updated monthly
- **Approval**: Security team reviews scan reports before merge