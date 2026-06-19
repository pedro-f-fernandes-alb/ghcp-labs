# Pull Request: `lab07/pr-workflow` → `main`

## Description

Implements the full deployment pipeline for the lab07 service: supply chain security scanning, containerised build, CI/CD pipeline authoring, and infrastructure provisioning via IaC. Copilot-assisted throughout.

---

## Changes

| Area | File(s) | Notes |
|------|---------|-------|
| **SBOM** | `lab07/sbom.xml` | Generated via `cyclonedx-bom` (`cyclonedx-py`) from `lab07/requirements.txt` |
| **Pipeline YAML** | `.github/workflows/lab07-pipeline.yml` | Stages: build → scan → validate-iac → manual-approval → deploy |
| **IaC** | `lab07/main.bicep` or `lab07/main.tf` | Optional — validated by the pipeline when present |

---

## Supply Chain Security Checklist

- [ ] SBOM generated and attached as pipeline artifact
- [ ] CVE scan passes with zero critical/high findings (`trivy` or `grype`)
- [ ] All container base images pinned to digest (no `latest` tags)
- [ ] IaC validated — no drift, no hard-coded secrets
- [ ] Pipeline requires manual approval before deploy stage
- [ ] Dependabot or Renovate enabled on this branch

---

> **Reviewer note:** All artifacts were scaffolded with GitHub Copilot. Please verify IaC cost estimate before merging.
