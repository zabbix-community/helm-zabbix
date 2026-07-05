---
name: release-chart
description: Cut and publish a new release of the Zabbix Helm chart in this repository, following the versioning rules and maintainer release process documented in CONTRIBUTING.md and CLAUDE.md (bump Chart.yaml/artifacthub-pkg.yml/values.yaml, regenerate docs, tag the release so CI publishes it). Trigger on requests like "release a new chart version", "cut a release", "bump the chart version", "publish v7.1.0", "prepare the next Zabbix chart release".
---

# Release a new version of the helm-zabbix chart

This skill walks through the maintainer-only release process documented in `CONTRIBUTING.md` ("For code mainteners only") and `CLAUDE.md` ("Versioning and release rules"). Its final steps are hard to reverse — pushing a git tag triggers a public GitHub Release via CI — so **always confirm the version number and each push/tag/PR action with the user before running it**. Do not skip confirmation because a step "seems obvious".

## Installing and invoking this skill

This repo keeps skills under `.agents/skills/` rather than `.claude/skills/` so the same file can be reused by any AI assistant that supports a skills convention, not just Claude Code. To get Claude Code's native `/release-chart` invocation, symlink this directory in:

- **Project-level** (this repo only):
  ```bash
  mkdir -p .claude/skills
  ln -s ../../.agents/skills/release-chart .claude/skills/release-chart
  ```
- **Personal** (available in every repo you work in):
  ```bash
  mkdir -p ~/.claude/skills
  ln -s /absolute/path/to/helm-zabbix/.agents/skills/release-chart ~/.claude/skills/release-chart
  ```

Once linked, run it with `/release-chart`, or just describe the task in natural language — e.g. "release a new chart version", "cut a release", "bump the chart version", "prepare the next Zabbix chart release" (these phrases match the `description` frontmatter above).

No symlink is strictly required to benefit from this file: `CLAUDE.md` already tells Claude Code to read and follow it whenever a maintainer asks to cut/publish a release, so it works out of the box in this repo. The symlink is only needed for the formal `/release-chart` slash invocation or to reuse the skill from other repositories.

## 0. Preconditions

- Confirm with the user (if not already given):
  - The new chart `version` (and whether `appVersion`/`zabbixImageTag` — the Zabbix version — is also changing).
  - Whether this is a **major** bump (the middle digit, e.g. `7.0.12` → `7.1.0` — signals a change that may require users to update their `values.yaml`) or a **minor** bump (the last digit, e.g. `7.0.12` → `7.0.13` — no API/interface changes).
- Verify all PRs intended for this release are already merged into `main`, and local `main` is up to date.
- Never bump versions or tag directly on `main` — always use a release branch.

## 1. Create the release branch

```bash
git checkout main
git pull upstream main
git checkout -b BRANCH_NAME
```

## 2. Run local tests

```bash
cd charts/zabbix
make help   # lists all available targets with descriptions
make lint
```

Fix any lint errors before continuing.

## 3. Bump versions — exact files, nothing else

1. `charts/zabbix/Chart.yaml` — `version:` (chart version) and `appVersion:` (Zabbix version, only if it's changing).
2. `charts/zabbix/artifacthub-pkg.yml` — three separate spots, all must match `Chart.yaml`:
   - `version:` and `appVersion:` fields near the top.
   - `createdAt:` — set to the output of `date +%Y-%m-%dT%TZ`.
   - The hardcoded `export ZABBIX_CHART_VERSION='...'` line inside the `install:` block. This file is plain YAML (not Go-templated), so this string must be edited by hand.
3. `charts/zabbix/values.yaml` — `zabbixImageTag:` if the Zabbix version (`appVersion`) changed.
4. If this is a **major** release: add a new subsection under "Breaking changes of this helm chart" in `charts/zabbix/README.md.gotmpl`, explaining what changed and what users need to check in their own `values.yaml`.

**Do not hand-edit** `charts/zabbix/README.md`, and do not touch the `export ZABBIX_CHART_VERSION=...` line inside `README.md.gotmpl` — that one is templated from `Chart.yaml`'s `version` via `{{ template "chart.version" . }}` and regenerates automatically in the next step. Only `artifacthub-pkg.yml`'s copy of that line is a plain hardcoded string.

## 4. Regenerate chart docs

```bash
cd charts/zabbix
make gen-docs
```

Confirm the resulting diff to `charts/zabbix/README.md` only touches the version number and (if `values.yaml` changed) the values table — nothing else should move.

## 5. Commit, push, and open a PR

Confirm with the user before pushing or opening the PR (visible, shared-state actions):

```bash
git add charts/zabbix/Chart.yaml charts/zabbix/artifacthub-pkg.yml charts/zabbix/values.yaml charts/zabbix/README.md charts/zabbix/README.md.gotmpl
git commit -m "Release x.y.z"
git push --set-upstream origin BRANCH_NAME
```

Open a PR to `main`, address review feedback, then merge.

## 6. Tag and publish — confirm explicitly before this step

After the release PR is merged into `main`:

```bash
git checkout main
git pull upstream main
git tag -a x.y.z -m "New release"
git push upstream --tags
```

Pushing the tag triggers `.github/workflows/helm-chart-releaser.yml`, which packages the chart and publishes a GitHub Release named `zabbix-x.y.z`. This is the point of no easy return for this process — do not run it without the user explicitly confirming the exact tag/version first.

## 7. Finalize release notes

Edit the auto-generated GitHub Release notes to match the style of previous releases (see the repo's Releases page). If this was a major release, make sure the breaking-changes write-up from step 3.4 is reflected in the release notes.

## Reference

- Full command-by-command detail: `CONTRIBUTING.md` → "For code mainteners only".
- Version semantics and cross-doc consistency notes: `CLAUDE.md` → "Versioning and release rules".
- A visual summary (Mermaid flowchart) of this same process: root `README.md` → "Release process".

Keep this file, `CONTRIBUTING.md`, and `CLAUDE.md` in sync — if the release steps change, update all three.
