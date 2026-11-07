# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository overview

This repo contains a single Helm chart, `charts/zabbix`, that deploys [Zabbix](https://www.zabbix.com) (monitoring solution) on Kubernetes, backed by PostgreSQL/TimescaleDB only (no MySQL/MariaDB support planned). It supports only Zabbix 8.0, Kubernetes 1.34+ (`kubeVersion` in `Chart.yaml`) and Helm 4. There is no application source code — all logic lives in Helm templates (Go templates) and `values.yaml`.

## Common commands

All chart commands are run from `charts/zabbix/` and are wrapped in the `Makefile` there, which runs `helm`/`helm-docs` inside Docker containers (no local Helm install required):

```bash
cd charts/zabbix
make help                    # lists all targets below with their one-line descriptions
make lint                    # helm lint . (via dockerized helm)
make package                 # helm package . -d packages
make gen-docs                # regenerates charts/zabbix/README.md from README.md.gotmpl via helm-docs (run after editing values.yaml)
make check-os                # fails if the OS is not Ubuntu 22.04/24.04/26.04 (amd64) or macOS (arm64/amd64)
make check-deps              # lists missing dependencies (git, curl, docker, mise and the tools of mise.toml)
make install-deps            # installs mise and the tools of mise.toml (docker is installed separately)
make kind-create             # creates only the kind cluster from docs/example/kind/kind-3nodes.yaml and selects it as current
make deploy                  # helm upgrade --install in the current cluster
make undeploy                # helm uninstall from the current cluster
make argocd-install          # helm upgrade --install of Argo CD in the current cluster
make argocd-deploy           # deploys a snapshot of the local chart with Argo CD, for tests only (see docs/example/argocd/README.md)
make argocd-undeploy         # removes the Argo CD Application and the resources managed by it
make stack-up                # kind-create + argocd-install + deploy (helm) with docs/example/kind/values.yaml
make kind-load IMAGES="..."  # loads local images (e.g. of the HA job and sidecar) into the kind cluster
make external-db-create      # creates the external PostgreSQL of docs/example/kind/external-postgresql.yaml, needed by HA
make external-db-delete      # removes it and its data
make stack-up-ha             # kind-create + external-db-create + deploy (helm) with docs/example/kind/values-ha.yaml
make stack-down              # deletes the kind cluster
```

The dockerized `helm`/`helm-docs` image tags are derived from the root `mise.toml`, the single place that pins tool versions.

`help` is self-documenting: it greps the Makefile for `target: ## description` comments, so any new target added with a trailing `## ...` comment shows up automatically — no separate list to maintain.

If `helm` is installed locally (the root `mise.toml` pins `helm`, `helm-docs`, `kind`, `kubectl` and `argocd`, plus the Argo CD chart version; see `charts/zabbix/docs/requirements.md`), the equivalent direct commands work too, e.g. `helm lint .` from `charts/zabbix/`.

There is no unit test suite in the traditional sense. Chart correctness is validated by:
- `helm lint`
- `helm template`/`--dry-run` against the chart
- The built-in Helm test hooks in `charts/zabbix/templates/tests/` (`test-server-connection.yaml`, `test-web-connection.yaml`), run post-install via `helm test <release> -n <namespace>`
- CI in `.github/workflows/tests.yaml`, which spins up `kind` clusters and runs full install/upgrade/test/uninstall cycles across four scenarios: internal DB without HA, external DB with HA + external secret, external DB with HA without external secret, and the transition from a standalone Zabbix Server to HA (`helm upgrade` enabling HA). They use the Helm version pinned in `mise.toml`, and the first three scenarios exercise upgrades across Zabbix 8.0 image tags only (default `appVersion`, `ubuntu-8.0-latest`, `alpine-8.0-latest`). A `lint` job runs `helm lint --strict` first, checks that the default images of the HA job and sidecar (`ghcr.io/zabbix-community/...`) are published and checks the rendering of `ZBX_SERVER_HOST` of Zabbix Proxy and of the HA job image tag with a numeric `tagSuffix` (without quotes it is an int64/float64, which must still render as digits).

To test changes locally against a real cluster (e.g. `kind`), follow `charts/zabbix/docs/example/README.md`, which uses `charts/zabbix/docs/example/kind/values.yaml` as an override file. To test Zabbix Server HA (with Helm or Argo CD, including local builds of the HA job and sidecar images loaded with `make kind-load` and `docs/example/ha/values-local-images.yaml`), follow `charts/zabbix/docs/example/ha/README.md`. `make argocd-deploy ARGOCD_VALUES_FILES="<abs paths>"` deploys with other values files.

## Versioning and release rules (see CONTRIBUTING.md and README.md)

- Never bump `version`/`appVersion` in `charts/zabbix/Chart.yaml` or `charts/zabbix/artifacthub-pkg.yml` on your own initiative — that's the maintainers' release process, done via git tag (the tag triggers `.github/workflows/helm-chart-releaser.yml`, which publishes the GitHub Release `zabbix-x.y.z` in the Helm repository and then pushes the same version to the OCI registry `oci://ghcr.io/zabbix-community/charts/zabbix`, never overwriting a published version). If a maintainer explicitly asks to cut/publish a new release, use the `release-chart` skill at `.agents/skills/release-chart/SKILL.md` — it encodes the exact file list, ordering, and confirmation points (especially before pushing a tag, which is hard to reverse) instead of re-deriving the process from scratch.
- Never hand-edit `charts/zabbix/README.md` — it is generated by `make gen-docs` from `charts/zabbix/README.md.gotmpl` (which contains the prose/docs) plus the `values.yaml` comments (which become the values table). Edit the `.gotmpl` file and/or `values.yaml` comments, then regenerate.
- Keep `values.yaml` defaults working/sane, since templates reference them directly and CI installs with mostly-default values.
- The maintainer-only release steps are documented in three places, and all need to stay consistent if the process changes: `CONTRIBUTING.md` ("For code mainteners only" section, exact commands), the root `README.md` ("Release process" section, a summary plus a Mermaid flowchart), and `.agents/skills/release-chart/SKILL.md` (the actionable, step-by-step version meant to be followed directly).
- Zabbix support rules: check them on every Zabbix bump, in `https://www.zabbix.com/documentation/<version>/en/manual/installation/requirements`. Zabbix 8.0 requires PostgreSQL 15-18 and TimescaleDB 2.20-2.29; the newest TimescaleDB is often not supported yet. The PostgreSQL tags are in `postgresql.image.tag` and `zabbixServer.haNodesAutoClean.image.tag`, in `values.yaml` and in `docs/example/kind/values.yaml`.
- Zabbix 8.0 images have a compiled entrypoint (source: `templates/entrypoints` in `zabbix/zabbix-docker`) that silently ignores unknown variables, such as `ZBX_JAVAGATEWAY_ENABLE`, and the proxy doesn't read `ZBX_SERVER_PORT`. Check the source before adding an env var to a template.
- The Zabbix Proxy of the `alpine-8.0.0` image crashes (signal 11, restart loop) with `ZBX_DEBUGLEVEL=4`, so the default of `zabbixProxy.ZBX_DEBUGLEVEL` is `3`.
- The HA database job uses an image from `zabbix-community/helm-zabbix-image-db-init-upgrade-job`, which must be published for each Zabbix major version, from the same schema version as the Zabbix release: Zabbix Server refuses to upgrade the schema in HA mode and exits. `tagSuffix` in `zabbixServer.zabbixServerHA.dbCreateUpgradeJob.image` must point to a published `<major>-<timestamp>` tag (each build of that repository publishes all majors with the same timestamp). The `8.0-trunk-*` images are built from 8.0.0rc2, whose schema is not compatible with Zabbix 8.0.0. The HA labels sidecar image comes from `zabbix-community/helm-zabbix-image-ha-labels-sidecar` (`haLabelsSidecar.image.tag` is a `<timestamp>` tag). The `lint` CI job fails when a default tag of these images is not published.
- Version semantics: the first digit follows the Zabbix major version (e.g. `7.1.0` → `8.0.0`) and is always a breaking change; bumping the middle digit (`major`, e.g. `6.0.2` → `6.1.0`) signals a change that may require users to update their `values.yaml`; bumping the last digit (`minor`, e.g. `6.0.2` → `6.0.3`) is a safe, no-API-change upgrade.
- The root `README.md` also has a "Repository structure" section with an annotated directory tree. Update it (and this file, if the architecture notes below are affected) when adding, removing, or renaming top-level files/templates.

## Architecture

### Template/value organization

Every component follows the same pattern in `values.yaml`: a top-level key (`zabbixServer`, `zabbixProxy`, `zabbixAgent`, `zabbixWeb`, `zabbixWebService`, `zabbixJavaGateway`, `zabbixBrowserMonitoring`, `postgresql`) with `enabled`, `image`, `resources`, `extraEnv`, `extraVolumes`/`extraVolumeMounts`, `extraDeploymentAnnotations`/`extraDeploymentLabels`, `extraPodAnnotations`/`extraPodLabels`, etc. following consistent naming across components. `global.commonLabels` applies to all resources. When adding a new tunable, mirror the sibling component's pattern rather than inventing a new shape.

Each component's Kubernetes objects live in one template file named `<kind>-<component>.yaml` under `charts/zabbix/templates/` (e.g. `deployment-zabbix-server.yaml`, `statefulset-zabbix-proxy.yaml`, `daemonset-zabbix-agent.yaml`). Shared template helpers/macros are in `templates/_helpers.tpl`.

### Database access (`postgresAccess`)

All DB connection info (host/port/user/password/db/schema) is centralized in one Secret (named `<release>-db-access` by default, or `postgresAccess.existingSecretName` if pointing at an externally-managed secret, e.g. one generated by CNPG/PGO). The helper `zabbix.postgresAccess.variables` in `_helpers.tpl` generates the env vars for any container needing DB access, and its behavior branches on a `context` argument (`db_client` uses `PGHOST`/`PGUSER`/etc. for psql-based cron jobs, `db_init_upgrade` uses plain values instead of secret refs for the pre-install job, everything else uses `DB_SERVER_HOST`/`POSTGRES_USER`/etc. via `secretKeyRef`). When touching DB env var logic, changes usually need to be made in this one helper, not per-template.

### Zabbix Server High Availability (`zabbixServer.zabbixServerHA`)

This is the most complex part of the chart:
- HA is a native Zabbix Server feature (hot-standby via heartbeat rows in the DB), gated in this chart by `zabbixServer.zabbixServerHA.enabled`.
- HA is **mutually exclusive with `postgresql.enabled=true`** (enforced by a `fail` in `templates/job-create-upgrade-db.yaml`) — HA requires bringing your own (ideally HA) external Postgres.
- When HA is enabled, `templates/job-create-upgrade-db.yaml` runs as a Helm `pre-install,pre-upgrade` hook Job (weight `-5`) that prepares/migrates the DB schema and reconciles the `ha_node` table *before* any Zabbix Server pod starts (this ordering is why it can't be a post-install hook and why `postgresql.enabled` + HA can't coexist — Helm has no way to deploy a DB pod before a pre-install hook runs).
- The job has its own ServiceAccount/Role/RoleBinding (`<fullname>-create-upgrade-db`, `templates/*-create-upgrade-db.yaml`), which are hooks too (weight `-10`, `before-hook-creation,hook-succeeded`): regular resources don't exist yet when pre-install/pre-upgrade hooks run, which caused #201. Never make the job depend on a regular resource.
- Never use `.Release.IsUpgrade`/`.Release.IsInstall` for HA logic: they are always install under Argo CD (`helm template`), which caused #231. The job receives `HELM_HOOK_TYPE=auto` (`dbCreateUpgradeJob.hookType`) and checks whether the Zabbix Server Deployment exists. It scales the Deployment down (major schema upgrade, or standalone → HA transition) and Helm/Argo CD restore the replicas when they apply it afterwards. Its waits are bounded by `dbCreateUpgradeJob.waitTimeout`; `activeDeadlineSeconds` is empty by default because schema upgrades of big databases can take hours.
- A separate sidecar ("HA Labels sidecar", image from `zabbix-community/helm-zabbix-image-ha-labels-sidecar`) watches each Zabbix Server pod's process count to determine active/standby status and updates pod labels accordingly, so Services can route Active checks/Active Proxies to the right pod without probing the Zabbix Server port directly (probing pollutes Zabbix Server logs).
- `templates/cronjob-hanodes-autoclean.yaml`, `templates/role-ha-helper.yaml`, `templates/rolebinding-ha-helper.yaml` support this HA machinery (stale HA node cleanup, RBAC of the HA labels sidecar, bound to the service account of the Zabbix Server pods).
- See the "Native Zabbix Server High Availability" section of `charts/zabbix/README.md.gotmpl` before changing anything here — the reasoning behind the hook ordering and constraints is non-obvious and documented there.

### Other notable behaviors

- `templates/extra-manifests.yaml` lets users inject arbitrary extra manifests via `.Values.extraManifests`, rendered through `zabbix.tools.render` in `_helpers.tpl` (supports both plain YAML values and Helm template strings needing `tpl`).
- Zabbix Proxy (`statefulset-zabbix-proxy.yaml`) uses SQLite3 locally and supports multiple replicas for proxy groups; when replicated, `ZBX_HOSTNAME` can't be statically set and falls back to the pod name. `zabbixProxy.affinity` replaces the global `affinity` for the proxy only, and `minReadySeconds`/`updateStrategy` control its rollout.
- `ZBX_SERVER_HOST` of Zabbix Proxy comes from the helper `zabbix.proxy.serverHost`: a passive proxy (`ZBX_PROXYMODE=1`) gets the value as is (it refuses to start with a port in its `Server` list), and an active proxy gets `zabbixProxy.ZBX_SERVER_PORT` appended to each `;`-separated Zabbix Server HA node without port. The `lint` CI job checks this rendering.
- The StatefulSets of Zabbix Proxy and PostgreSQL use the headless Services `<fullname>-zabbix-proxy-headless` and `<fullname>-postgresql-headless` (in `service.yaml`) as `serviceName`. `serviceName` is immutable: changing it breaks `helm upgrade` and needs `kubectl delete statefulset --cascade=orphan` before the upgrade, documented in the breaking changes.
- Zabbix Agent supports both DaemonSet mode (`zabbixAgent.runAsDaemonSet=true`, uses `hostNetwork: true`) and Deployment/sidecar modes, plus a dynamic hostname mode via `ZBX_HOSTNAMEITEM`.
- Breaking changes between major chart versions are tracked in the "Breaking changes of this helm chart" section of `charts/zabbix/README.md.gotmpl` — check it when bumping `postgresAccess`, label/selector, or naming-convention behavior, since those have caused required-reinstall breakage before.
