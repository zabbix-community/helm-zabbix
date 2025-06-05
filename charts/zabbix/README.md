# Helm chart for Zabbix

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Version: 7.0.9](https://img.shields.io/badge/Version-7.0.9-informational?style=flat-square)  [![Downloads](https://img.shields.io/github/downloads/zabbix-community/helm-zabbix/total?label=Downloads%20All%20Releases
)](https://tooomm.github.io/github-release-stats/?username=zabbix-community&repository=helm-zabbix)

Zabbix is a mature and effortless enterprise-class open source monitoring solution for network monitoring and application monitoring of millions of metrics.

This Helm chart installs [Zabbix](https://www.zabbix.com) in a Kubernetes cluster. It supports only Postgresql/TimescaleDB as a database backend at this point in time, without any plans to extend database support towards MySQL, MariaDB, etc. Also, this Helm Chart supports [Zabbix Server High Availability](#native-zabbix-server-high-availability)

# Table of Contents
<!-- TOC -->

- [Helm chart for Zabbix](#helm-chart-for-zabbix)
- [Table of Contents](#table-of-contents)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [How to access Zabbix](#how-to-access-zabbix)
- [Troubleshooting](#troubleshooting)
- [Uninstallation](#uninstallation)
- [Breaking changes of this helm chart](#breaking-changes-of-this-helm-chart)
  - [Version 7.0.0](#version-700)
  - [Version 6.1.0](#version-610)
  - [Version 6.0.0](#version-600)
  - [Version 5.0.0](#version-500)
  - [Version 4.0.0](#version-400)
  - [Version 3.0.0](#version-300)
  - [Version 2.0.0](#version-200)
  - [Version 1.0.0](#version-100)
- [Zabbix components](#zabbix-components)
  - [Zabbix Server](#zabbix-server)
  - [Zabbix Agent](#zabbix-agent)
  - [Zabbix Web (frontend)](#zabbix-web-frontend)
  - [Zabbix Web Service](#zabbix-web-service)
  - [Zabbix Proxy](#zabbix-proxy)
  - [PostgreSQL](#postgresql)
- [Thanks](#thanks)
- [License](#license)
- [Configuration](#configuration)
  - [Helm Values](#helm-values)
  - [Database access settings](#database-access-settings)
  - [Postgresql database](#postgresql-database)
  - [Native Zabbix Server High Availability](#native-zabbix-server-high-availability)
  - [Expose Zabbix service](#expose-zabbix-service)
  - [Multiple replicas for Zabbix Proxy statefulset](#multiple-replicas-for-zabbix-proxy-statefulset)

<!-- TOC -->

# Prerequisites

- Kubernetes cluster 1.21+
- Helm 3.0+
- Kubectl
- PV provisioner support in the underlying infrastructure (optional).

Install the ``kubectl`` and ``helm`` requirements following the instructions in this [tutorial](docs/requirements.md).

# Installation

> [!IMPORTANT]
> Read the [Breaking changes of this helm chart](#breaking-changes-of-this-helm-chart)!

Access the Kubernetes cluster.

Add Helm repository:

```bash
helm repo add zabbix-community https://zabbix-community.github.io/helm-zabbix
```

Update the list helm charts available for installation. This is recommend prior to installation/upgrade:

```bash
helm repo update
```

Get all versions of helm chart:

```bash
helm search repo zabbix-community/zabbix -l
```

Set the helm chart version you want to use. Example:

```bash
export ZABBIX_CHART_VERSION='7.0.9'
```

Export default values of ``zabbix`` chart to ``$HOME/zabbix_values.yaml`` file:

```bash
helm show values zabbix-community/zabbix --version $ZABBIX_CHART_VERSION > $HOME/zabbix_values.yaml
```

Change the values according to the environment in the ``$HOME/zabbix_values.yaml`` file. The items of [Configuration](#configuration) section can be set via ``--set`` flag in
installation command or change the values according to the need of the environment in ``$HOME/zabbix_values.yaml`` file.

Test the installation/upgrade with the command:

```bash
helm upgrade --install zabbix zabbix-community/zabbix \
 --dependency-update \
 --create-namespace \
 --version $ZABBIX_CHART_VERSION \
 -f $HOME/zabbix_values.yaml -n monitoring --debug --dry-run
```

Install/upgrade Zabbix with the command:

```bash
helm upgrade --install zabbix zabbix-community/zabbix \
 --dependency-update \
 --create-namespace \
 --version $ZABBIX_CHART_VERSION \
 -f $HOME/zabbix_values.yaml -n monitoring --debug
```

See the installation example in [kind](https://kind.sigs.k8s.io) cluster in this [tutorial](docs/example/README.md).

# How to access Zabbix

Create port-forward for Zabbix:

```bash
kubectl port-forward service/zabbix-zabbix-web 8888:80 -n monitoring
```

Login to Zabbix:

- URL: http://localhost:8888
- Login: **Admin**
- Password: **zabbix**

# Troubleshooting

See the pods:

```bash
kubectl get pods -n monitoring
```

See details for each pod:

```bash
kubectl describe pods/POD_NAME -n monitoring
```

See all containers in the pod:

```bash
kubectl get pods POD_NAME -n monitoring -o jsonpath='{.spec.containers[*].name}*'
```

See the logs for each container in the pod:

```bash
kubectl logs -f pods/POD_NAME -c CONTAINER_NAME -n monitoring
```

Access the container prompt.

```bash
kubectl exec -it pods/POD_NAME -c CONTAINER_NAME -n monitoring -- sh
```

See details of Zabbix services.

```bash
kubectl get svc -n monitoring
kubectl get pods --output=wide -n monitoring
kubectl describe services zabbix -n monitoring
```

# Uninstallation

To uninstall/delete the ``zabbix`` deployment:

```bash
helm uninstall zabbix -n monitoring
```

# Breaking changes of this helm chart

## Version 7.0.0

> [!CAUTION]
> Re-installation of your Release will be necessary. Make sure you do not lose any data!

- Changed values under `postgresAccess`, partially made necessary by changing *db-create-upgrade-job* for [Native Zabbix Server High Availability](#native-zabbix-server-high-availability) to be a *pre-install/pre-upgrade* job:
  - removed `postgresAccess.useUnifiedSecret`. It's now ALWAYS a unified secret containing DB connection relevant settings that is used by all components of this Chart requiring a DB connection
  - `unifiedSecretName` now called `existingSecretName` to be more compliant with other Helm Charts
  - `unifiedSecretAutoCreate` has been removed. Secret generation now depends on having set `existingSecretName`
  - `unifiedSecretXXXKey` renamed to simpler `secretXXXKey` value names
- Default settings in `values.yaml` are now `postgresql.enabled=true` (no change here) and `zabbixServer.zabbixServerHA=false` (changed, due to [Native Zabbix Server High Availability](#native-zabbix-server-high-availability))
- All labels of all manifests have been unified to fulfill the best practices / standards of how a newly created helm chart (`helm create...`) would do it. This results in you having to **uninstall and install your Release again**, as `spec.selector` label matchers are *immutable* for *Deployments*, *Statefulsets* and such. If you use `postgresql.enabled=true` ("internal database"), be careful not to delete your Zabbix database when issuing uninstallation. By default, Helm does not remove *PersistentVolumeClaims* when uninstalling a release, but to be sure, you can [annotate your PVC additionally](https://github.com/helm/helm/issues/6261#issuecomment-523472128) to prevent its deletion
- Removed all pre 1.21 Kubernetes compatibility switches (`v1beta1`, ...)
- `deploymentAnnotations` have been renamed to `extraDeploymentAnnotations` for every of the components of this helm chart in `values.yaml`
- `deploymentLabels` have been renamed to `extraDeploymentLabels` for every of the components of this helm chart in `values.yaml`. The same counts for `statefulSetLabels`, etc.
- `deploymentAnnotations` have been renamed to `extraDeploymentAnnotations` for every of the components of this helm chart in `values.yaml`. The same counts for `statefulSetAnnotations`, `daemonSetAnnotations`, etc.
- `containerLabels` are now called `extraPodLabels` and `containerAnnotations` went to be `extraPodAnnotations`, as these names match better to what the values actually do
- when using `zabbixAgent.runAsDaemonSet=true`, zabbix agent pods now default to use `hostNetwork: true`

## Version 6.1.0

- Removing support for non-default Kubernetes features and Custom Resource objects: `IngressRoute`, `Route`, more info: [#123](https://github.com/zabbix-community/helm-zabbix/pull/123)
- Removing support for [karpenter](https://karpenter.sh) due to the more generalistic approach: [#121](https://github.com/zabbix-community/helm-zabbix/pull/121)
- Adding support to deploy any arbitrary manifests together with this Helm Chart by embedding them in the `.Values.extraManifests` list [#121](https://github.com/zabbix-community/helm-zabbix/pull/121)
- From now on, the keys to use for a `unifiedSecret` to configure postgresql access globally for all relevant components that this Helm Chart deploys, can be configured in `values.yaml` file
- It is now possible to use a different Schema other than `public` in Postgresql database, when using an external database

## Version 6.0.0

- New implementation of native Zabbix Server High Availability (see [Support of native Zabbix Server High Availability](#support-of-native-zabbix-server-high-availability) section)
- No breaking changes in values.yaml, but nevertheless you might want to review your values.yaml's `zabbixServer.zabbixServerHA` section

## Version 5.0.0

- Will be using Postgresql 16.x and Zabbix 7.x.
- Adjust in extraEnv to add support in environment variables from configmap and secret. More info: #93

## Version 4.0.0

- Will be used Postgresql 15.x and Zabbix 6.x.
- Allow install zabbix-agent2 as deployment and sidecar container. More info: https://github.com/zabbix-community/helm-zabbix/issues/20
- This release changes parameter names in preparation for addressing these issues in the future and use [camelCase](https://en.wikipedia.org/wiki/Camel_case) pattern where is possible. More info: https://github.com/zabbix-community/helm-zabbix/issues/18 and https://github.com/zabbix-community/helm-zabbix/issues/21
  - ``db_access`` -> ``postgresAccess``
  - ``db_access.use_unified_secret`` -> ``postgresAccess.useUnifiedSecret``
  - ``db_access.unified_secret_name`` -> ``postgresAccess.unifiedSecretName``
  - ``db_access.unified_secret_autocreate`` -> ``postgresAccess.unifiedSecretAutoCreate``
  - ``db_access.db_server_host`` -> ``postgresAccess.host``
  - ``db_access.db_server_port`` -> ``postgresAccess.port``
  - ``db_access.postgres_user`` -> ``postgresAccess.user``
  - ``db_access.postgres_password`` -> ``postgresAccess.password``
  - ``db_access.postgres_db`` -> ``postgresAccess.database``
  - ``db_access.postgres_password_secret`` -> ``postgresAccess.passwordSecret``
  - ``db_access.postgres_password_secret_key`` -> ``postgresAccess.passwordSecretKey``
  - ``ingressroute`` -> ``ingressRoute``
  - ``postgresql.existing_claim_name`` -> ``postgresql.existingClaimName``
  - ``postgresql.storage_size`` -> ``postgresql.storageSize``
  - ``postgresql.storage_class`` -> ``postgresql.storageClass``
  - ``zabbix_image_tag`` -> ``zabbixImageTag``
  - ``zabbixagent`` -> ``zabbixAgent``
  - ``zabbixproxy`` -> ``zabbixProxy``
  - ``zabbixserver`` -> ``zabbixServer``
  - ``zabbixserver.pod_anti_affinity`` -> ``zabbixServer.podAntiAffinity``
  - ``zabbixserver.ha_nodes_autoclean`` -> ``zabbixServer.haNodesAutoClean``
  - ``zabbixserver.ha_nodes_autoclean.delete_older_than_seconds`` -> ``zabbixServer.haNodesAutoClean.deleteOlderThanSeconds``
  - ``zabbixweb`` -> ``zabbixWeb``
  - ``zabbixweb.pod_anti_affinity`` -> ``zabbixWeb.podAntiAffinity``
  - ``zabbixweb.saml_certs_secret_name`` -> ``zabbixWeb.samlCertsSecretName``
  - ``zabbixwebservice`` -> ``zabbixWebService``
  - ``zabbixwebservice.pod_anti_affinity`` -> ``zabbixWebService.podAntiAffinity``
  - ``zabbixwebservice.ignore_url_cert_errors`` -> ``zabbixWebService.ignoreURLCertErrors``

## Version 3.0.0

- Will be used Postgresql 14.x and Zabbix 6.x.
- This version removes the possibility to specify database username/password per
  subsection in favor of specifying all of them centrally at one place.
- Also, the names of the values have changed from upper to lowercase.
- It is now possible to start the Zabbix Server pods with replicas of more than 1.
  HA functionality of Zabbix will automatically be enabled and it is made sure that
  the database schema publication will only happen once, and not by all of the Zabbix
  Server pods at the same time.
- More info: https://github.com/cetic/helm-zabbix/pull/54

## Version 2.0.0

- Will be used Postgresql 14.x and Zabbix 6.x.
- This version implements a central way of managing database access credentials
using a secret, which then will be respected by all the components
installed by this chart: zabbixServer, zabbixWeb and postgresql.
- The secret must contain a number of keys indicating DB host, DB name,
user and password and can direct towards a database installed within
this chart, or an external database.
- The benefit of this is that now the database can respect the values
in the central DB access secret and initialize accordingly.
- Last but not least, the credential secret can be chosen to be
auto-generated (password will be set to a random string) at chart
installation, if postgresql.enabled is set to true. With this, an easy
to use "out-of-the-box" installation with as little customizations as
possible is possible, while still obtaining a good level of security.
- More info: https://github.com/cetic/helm-zabbix/pull/53

## Version 1.0.0

- Will be used Postgresql 14.x and Zabbix 6.x.
- The installation of any component of chart is optional for easy integration with the official
 chart: https://git.zabbix.com/projects/ZT/repos/kubernetes-helm/
- More info: https://github.com/cetic/helm-zabbix/issues/42

# Zabbix components

> [!NOTE]
> About the Zabbix version supported

- This helm chart is compatible with non-LTS version of Zabbix, that include important changes and functionalities.
- But by default this helm chart will install the latest LTS version (example: 7.0.x).
See more info in [Zabbix Life Cycle & Release Policy](https://www.zabbix.com/life_cycle_and_release_policy) page
- When you want use a non-LTS version (example: 7.2.x), you have to set this in ``values.yaml`` yourself. This Helm Chart is actively being tested with the current non-LTS major releases, so it will be most probably working without any problem just setting `zabbixImageTag`, for example to the value of `ubuntu-7.2.1` or `alpine-7.2-latest`.

## Zabbix Server

**Zabbix Server** is the central process of Zabbix software.

The server performs the polling and trapping of data, it calculates triggers, sends notifications
to users. It is the central component to which Zabbix agents and proxies report data on availability
and integrity of systems. The server can itself remotely check networked services (such as web servers
and mail servers) using simple service checks
[Official documentation](https://www.zabbix.com/documentation/current/en/manual/concepts/server).

Zabbix Server can be operated in a High Availability mode since version 6.0 which is automatically
enabled by this Helm chart when setting the Zabbix Server component to run more than 1 replica.
In this HA mode, all Zabbix Server instances periodically send a heartbeat to the Database server
(just updating a timestamp in a table) as well as which of the nodes is the "active" one. In case
the active node does not send a heartbeat within a certain time, any of the remaining ones
automatically take over. It is every time possible to join new nodes to the HA cluster by just
raising the amount of replicas of the Zabbix Server.

## Zabbix Agent

> [!NOTE]
> **zabbix-agent2** is supported in this helm chart and will be used by default.

**Zabbix Agent** is deployed on a monitoring target to actively monitor local resources and
applications (hard drives, memory, processor statistics etc)
[Official documentation](https://www.zabbix.com/documentation/current/en/manual/concepts/agent).

## Zabbix Web (frontend)

**Zabbix Web** interface is a part of Zabbix software. It is used to manage resources under
monitoring and view monitoring statistics
[Official documentation](https://www.zabbix.com/documentation/current/en/manual/web_interface).

## Zabbix Web Service

**Zabbix Web Service** is a process that is used for communication with external web services
[Official documentation](https://www.zabbix.com/documentation/current/en/manual/concepts/web_service).

## Zabbix Proxy

> [!NOTE]
> This helm chart installs Zabbix Proxy with SQLite3 support

**Zabbix Proxy** is a process that may collect monitoring data from one or more monitored devices
and send the information to the Zabbix Server, essentially working on behalf of the server.
All collected data is buffered locally and then transferred to the **Zabbix Server** the
proxy belongs to
[Official documentation](https://www.zabbix.com/documentation/current/en/manual/concepts/proxy).

## PostgreSQL

A database is required for zabbix to work, in this helm chart we're using Postgresql.

> [!IMPORTANT]
> We use plain postgresql database by default WITHOUT persistence. If you want persistence or
would like to use TimescaleDB instead, check the comments in the ``values.yaml`` file.

# Thanks

> **About the new home of helm chart**
- The new home of the Zabbix helm chart is: https://github.com/zabbix-community/helm-zabbix.
It is a fork from the [cetic/helm-zabbix](https://github.com/cetic/helm-zabbix).
- In this [issue](https://github.com/cetic/helm-zabbix/issues/68) it was agreed with [Sebastien Dupont](https://github.com/banzothat) that the repository would get a new home.
- We are grateful to [Cetic](https://www.cetic.be/) for making the infrastructure available on CircleCI to host the helm chart from the start. Now, the new versions will be hosted on Github.
- We are very grateful to [Alexandre Nuttinck](https://github.com/alexnuttinck) and [Amen Ayadi](https://github.com/AyadiAmen), who were the first developers of the helm chart and who worked at Cetic. Your dedication and effort made it possible to install Zabbix on a Kubernetes cluster.

# License

[Apache License 2.0](/LICENSE)

# Configuration

## Helm Values

The following tables lists the configurable parameters of the chart and their default values.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity configurations. Reference: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/ |
| extraManifests | list | `[]` | Extra arbitrary Kubernetes manifests to deploy within the release |
| global.commonLabels | object | `{}` | Labels to apply to all resources. |
| global.imagePullSecrets | list | `[]` | Reference to one or more secrets to be used when pulling images.  For example:  imagePullSecrets:    - name: "image-pull-secret" |
| helmTestJobs.nodeSelector | object | `{}` | nodeSelector configurations. Reference: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/ |
| helmTestJobs.serverConnection.image.pullPolicy | string | `"IfNotPresent"` | Pull Policy for Helm test job testing connection to Zabbix server |
| helmTestJobs.serverConnection.image.pullSecrets | list | `[]` | Pull Secrets for Helm test job testing connection to Zabbix server |
| helmTestJobs.serverConnection.image.repository | string | `"busybox"` | Image repository for Helm test job testing connection to Zabbix server |
| helmTestJobs.serverConnection.image.tag | string | `"latest"` | Image tag for Helm test job testing connection to Zabbix server |
| helmTestJobs.serverConnection.resources | object | `{}` | Resource limits/reservations for Helm test job testing connection to Zabbix server |
| helmTestJobs.serverConnection.securityContext | object | `{}` | Security Context for Helm test job testing connection to Zabbix server |
| helmTestJobs.webConnection.image.pullPolicy | string | `"IfNotPresent"` | Pull Policy for Helm test job testing connection to web frontend |
| helmTestJobs.webConnection.image.pullSecrets | list | `[]` | Pull Secrets for Helm test job testing connection to web frontend |
| helmTestJobs.webConnection.image.repository | string | `"busybox"` | Image repository for Helm test job testing connection to web frontend |
| helmTestJobs.webConnection.image.tag | string | `"latest"` | Image tag for Helm test job testing connection to web frontend |
| helmTestJobs.webConnection.resources | object | `{}` | Resource limits/reservations for Helm test job testing connection to web frontend |
| helmTestJobs.webConnection.securityContext | object | `{}` | Security Context for Helm test job testing connection to web frontend |
| ingress.annotations | object | `{}` | Ingress annotations |
| ingress.enabled | bool | `false` | Enables Ingress |
| ingress.hosts | list | `[{"host":"chart-example.local","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}]` | Ingress hosts |
| ingress.pathType | string | `"Prefix"` | pathType is only for k8s >= 1.1= |
| ingress.tls | list | `[]` | Ingress TLS configuration |
| postgresAccess.database | string | `"zabbix"` | Name of database, eignored if existingSecretName is set |
| postgresAccess.existingSecretName | string | `""` | Name of an existing secret to use for database access. This could be one created by a Postgres operator such as CNPG or PGO |
| postgresAccess.host | string | `"zabbix-postgresql"` | Address of database host - ignored if postgresql.enabled=true |
| postgresAccess.password | string | `"zabbix"` | Password of database, eignored if existingSecretName is set |
| postgresAccess.port | string | `"5432"` | Port of database host - ignored if postgresql.enabled=true or when existingSecretName is set |
| postgresAccess.schema | string | `""` | Schema of database. Can be left empty if secretSchemaKey is not set. Only being used if external database is used (`postgresql.enabled` not set) |
| postgresAccess.secretDBKey | string | `"dbname"` | key of the postgres access secret where database name for the postgres db is found if removed postgresAccess.database is used |
| postgresAccess.secretHostKey | string | `"host"` | key of the postgres access secret where host ip / dns name for the postgres db is found if removed postgresAccess.host is used |
| postgresAccess.secretPasswordKey | string | `"password"` | key of the unified postgres access secret where password for the postgres db is found |
| postgresAccess.secretPortKey | string | `"port"` | key of the postgres access secret where the port for the postgres db is found if removed postgresAccess.port is used |
| postgresAccess.secretSchemaKey | string | `""` | key of the postgres access secret where schema name for the postgres db is found. Can be left empty (defaults to "public", then). Only being used if external database is used (`postgresql.enabled` not set) |
| postgresAccess.secretUserKey | string | `"user"` | key of the postgres access secret where user name for the postgres db is found |
| postgresAccess.user | string | `"zabbix"` | User of database, ignored if existingSecretName is set |
| postgresql.enabled | bool | `true` | Create a database using Postgresql. Not usable in combination with ``zabbixserver.zabbixServerHA=true`` |
| postgresql.extraContainers | list | `[]` | Additional containers to start within the postgresql pod |
| postgresql.extraEnv | list | `[]` | Extra environment variables. A list of additional environment variables. |
| postgresql.extraInitContainers | list | `[]` | Additional init containers to start within the postgresql pod |
| postgresql.extraPodAnnotations | object | `{}` | Annotations to add to the pod |
| postgresql.extraPodLabels | object | `{}` | Labels to add to the pod |
| postgresql.extraPodSpecs | object | `{}` | Additional specifications to the postgresql pod |
| postgresql.extraRuntimeParameters | object | `{"max_connections":100}` | Extra Postgresql runtime parameters ("-c" options) |
| postgresql.extraStatefulSetAnnotations | object | `{}` | Annotations to add to the statefulset |
| postgresql.extraStatefulSetLabels | object | `{}` | Labels to add to the statefulset |
| postgresql.extraVolumeMounts | list | `[]` | Additional volumeMounts to the postgresql container |
| postgresql.extraVolumes | list | `[]` | Additional volumes to make available to the postgresql pod |
| postgresql.image.pullPolicy | string | `"IfNotPresent"` | Pull policy of Docker image |
| postgresql.image.pullSecrets | list | `[]` | List of dockerconfig secrets names to use when pulling images |
| postgresql.image.repository | string | `"postgres"` | Postgresql Docker image name: chose one of "postgres" or "timescale/timescaledb" |
| postgresql.image.tag | int | `16` | Tag of Docker image of Postgresql server, choice "16" for postgres "2.17.2-pg16" for timescaledb (Zabbix supports TimescaleDB. More info: https://www.zabbix.com/documentation/7.0/en/manual/installation/requirements) |
| postgresql.livenessProbe | object | `{}` | The kubelet uses liveness probes to know when to restart a container. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| postgresql.nodeSelector | object | `{}` | nodeSelector configurations. Reference: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/ |
| postgresql.persistence.enabled | bool | `false` | Whether to enable persistent storage for the postgres container or not |
| postgresql.persistence.existingClaimName | bool | `false` | Existing persistent volume claim name to be used to store postgres data |
| postgresql.persistence.storageSize | string | `"5Gi"` | Size of the PVC to be automatically generated |
| postgresql.readinessProbe | object | `{}` | The kubelet uses readiness probes to know when a container is ready to start accepting traffic. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| postgresql.resources | object | `{}` | Requests and limits of pod resources. See: [https://kubernetes.io/docs/concepts/configuration/manage-resources-containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers) |
| postgresql.securityContext | object | `{}` | Security Context configurations. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| postgresql.service.annotations | object | `{}` | Annotations for the zabbix-server service |
| postgresql.service.clusterIP | string | `nil` | clusterIP is the IP address of the service and is usually assigned randomly. If an address is specified manually, is in-range (as per system configuration), and is not in use, it will be allocated to the service. |
| postgresql.service.port | int | `5432` | Port of service in Kubernetes cluster |
| postgresql.service.type | string | `"ClusterIP"` | Type of service to expose the application. Valid options are ExternalName, ClusterIP, NodePort, and LoadBalancer. More details: https://kubernetes.io/docs/concepts/services-networking/service/ |
| postgresql.startupProbe | object | `{}` | The kubelet uses startup probes to know when a container application has started.  Reference: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| rbac.additionalRulesForClusterRole | list | `[]` |  |
| rbac.create | bool | `true` | Specifies whether the RBAC resources should be created |
| securityContext | object | `{}` | Security Context configurations. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| serviceAccount.annotations | object | `{}` | Optional additional annotations to add to the Service Account. |
| serviceAccount.automountServiceAccountToken | bool | `true` | Automount API credentials for a Service Account. |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created. |
| serviceAccount.labels | object | `{}` | Optional additional labels to add to the Service Account. |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template. |
| tolerations | list | `[]` | Tolerations configurations. Reference: https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/ |
| zabbixAgent.ZBX_ACTIVE_ALLOW | bool | `false` | This variable is boolean (true or false) and enables or disables feature of active checks |
| zabbixAgent.ZBX_DEBUGLEVEL | int | `3` | The variable is used to specify debug level, from 0 to 5 |
| zabbixAgent.ZBX_PASSIVE_ALLOW | bool | `true` | This variable is boolean (true or false) and enables or disables feature of passive checks. By default, value is true |
| zabbixAgent.ZBX_SERVER_HOST | string | `"0.0.0.0/0"` | Zabbix Server host |
| zabbixAgent.ZBX_SERVER_PORT | int | `10051` | Zabbix Server port |
| zabbixAgent.ZBX_TIMEOUT | int | `4` | The variable is used to specify timeout for processing checks. By default, value is 4. |
| zabbixAgent.enabled | bool | `true` | Enables use of **Zabbix Agent** |
| zabbixAgent.extraContainers | list | `[]` | Additional containers to start within the Zabbix Agent pod |
| zabbixAgent.extraDaemonSetAnnotations | object | `{}` | Annotations to add to the daemonSet |
| zabbixAgent.extraDaemonSetLabels | object | `{}` | Labels to add to the daemonSet |
| zabbixAgent.extraDeploymentLabels | object | `{}` | Labels to add to the deployment |
| zabbixAgent.extraEnv | list | `[]` | Extra environment variables. A list of additional environment variables. List can be extended with other environment variables listed here: https://github.com/zabbix/zabbix-docker/tree/6.0/Dockerfiles/agent2/alpine#environment-variables. See example: https://github.com/zabbix-community/helm-zabbix/blob/main/charts/zabbix/docs/example/kind/values.yaml |
| zabbixAgent.extraInitContainers | list | `[]` | Additional init containers to start within the Zabbix Agent pod |
| zabbixAgent.extraPodAnnotations | object | `{}` | Annotations to add to the pods |
| zabbixAgent.extraPodLabels | object | `{}` | Labels to add to the pods |
| zabbixAgent.extraPodSpecs | object | `{}` | Additional specifications to the Zabbix Agent pod |
| zabbixAgent.extraVolumeMounts | list | `[]` | Additional volumeMounts to the zabbix Agent container |
| zabbixAgent.extraVolumes | list | `[]` | Additional volumes to make available to the Zabbix Agent pod |
| zabbixAgent.hostNetwork | bool | `true` | set whether zabbix agent / agent2 in DaemonSet mode should use hostNetwork. Usually the right option if using zabbix agent for node monitoring. Only applies if `zabbixAgent.runAsDaemonSet=true` |
| zabbixAgent.hostRootFsMount | bool | `true` | If true, agent pods mounts host / at /host/root |
| zabbixAgent.image.pullPolicy | string | `"IfNotPresent"` | Pull policy of Docker image |
| zabbixAgent.image.pullSecrets | list | `[]` | List of dockerconfig secrets names to use when pulling images |
| zabbixAgent.image.repository | string | `"zabbix/zabbix-agent2"` | Zabbix Agent Docker image name. Can use zabbix/zabbix-agent or zabbix/zabbix-agent2 |
| zabbixAgent.image.tag | string | `nil` | Zabbix Agent Docker image tag, if you want to override zabbixImageTag |
| zabbixAgent.livenessProbe | object | `{"failureThreshold":3,"periodSeconds":10,"successThreshold":1,"tcpSocket":{"port":"zabbix-agent"},"timeoutSeconds":3}` | The kubelet uses liveness probes to know when to restart a container. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| zabbixAgent.livenessProbe.tcpSocket.port | string | `"zabbix-agent"` | Port number/alias name of the container |
| zabbixAgent.nodeSelector | object | `{}` | nodeSelector configurations. Reference: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/ |
| zabbixAgent.readinessProbe | object | `{}` | The kubelet uses readiness probes to know when a container is ready to start accepting traffic. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| zabbixAgent.resources | object | `{}` | Requests and limits of pod resources. See: [https://kubernetes.io/docs/concepts/configuration/manage-resources-containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers) |
| zabbixAgent.runAsDaemonSet | bool | `false` | Enable this mode if you want to run zabbix-agent as daemonSet. The 'zabbixAgent.runAsSidecar' option must be false. |
| zabbixAgent.runAsSidecar | bool | `true` | Its is a default mode. Zabbix-agent will run as sidecar in zabbix-server and zabbix-proxy pods. Disable this mode if you want to run zabbix-agent as daemonSet |
| zabbixAgent.securityContext | object | `{}` | Security Context configurations. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| zabbixAgent.service.annotations | object | `{}` | Annotations for the zabbix-agent service |
| zabbixAgent.service.clusterIP | string | `nil` | clusterIP is the IP address of the service and is usually assigned randomly. If an address is specified manually, is in-range (as per system configuration), and is not in use, it will be allocated to the service. |
| zabbixAgent.service.externalIPs | list | `[]` | externalIPs is a list of IP addresses for which nodes in the cluster will also accept traffic for this service. These IPs are not managed by Kubernetes. |
| zabbixAgent.service.loadBalancerClass | string | `""` | loadBalancerClass is the class of the load balancer implementation this Service belongs to. If specified, the value of this field must be a label-style identifier, with an optional prefix, e.g. "internal-vip" or "example.com/internal-vip". Unprefixed names are reserved for end-users. This field can only be set when the Service type is 'LoadBalancer'. If not set, the default load balancer implementation is used, today this is typically done through the cloud provider integration, but should apply for any default implementation. If set, it is assumed that a load balancer implementation is watching for Services with a matching class. Any default load balancer implementation (e.g. cloud providers) should ignore Services that set this field. This field can only be set when creating or updating a Service to type 'LoadBalancer'. Once set, it can not be changed. This field will be wiped when a service is updated to a non 'LoadBalancer' type. |
| zabbixAgent.service.loadBalancerIP | string | `""` | Only applies to Service Type: LoadBalancer. This feature depends on whether the underlying cloud-provider supports specifying the loadBalancerIP when a load balancer is created. This field will be ignored if the cloud-provider does not support the feature. |
| zabbixAgent.service.loadBalancerSourceRanges | list | `[]` | If specified and supported by the platform, this will restrict traffic through the cloud-provider load-balancer will be restricted to the specified client IPs. This field will be ignored if the cloud-provider does not support the feature. |
| zabbixAgent.service.nodePort | int | `31050` | NodePort port to allocate on each node (only if service.type = NodePort or Loadbalancer) |
| zabbixAgent.service.port | int | `10050` | Port of service in Kubernetes cluster |
| zabbixAgent.service.sessionAffinity | string | `"None"` | Supports "ClientIP" and "None". Used to maintain session affinity. Enable client IP based session affinity. Must be ClientIP or None. Defaults to None. More info: https://kubernetes.io/docs/concepts/services-networking/service/#virtual-ips-and-service-proxies |
| zabbixAgent.service.type | string | `"ClusterIP"` | Type of service to expose the application. Valid options are ExternalName, ClusterIP, NodePort, and LoadBalancer. More details: https://kubernetes.io/docs/concepts/services-networking/service/ |
| zabbixAgent.startupProbe | object | `{"failureThreshold":5,"initialDelaySeconds":15,"periodSeconds":5,"successThreshold":1,"tcpSocket":{"port":"zabbix-agent"},"timeoutSeconds":3}` | The kubelet uses startup probes to know when a container application has started.  Reference: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| zabbixAgent.startupProbe.tcpSocket.port | string | `"zabbix-agent"` | Port number/alias name of the container |
| zabbixBrowserMonitoring.customWebDriverURL | string | `""` | Custom WebDriver URL. If set, it overrides the default internal WebDriver service URL. Set zabbixBrowserMonitoring.webdriver.enabled to false when setting this. |
| zabbixBrowserMonitoring.enabled | bool | `false` | Enable browser pollers |
| zabbixBrowserMonitoring.nodeSelector | object | `{}` | nodeSelector configurations. Reference: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/ |
| zabbixBrowserMonitoring.pollers | int | `1` | Number of browser pollers to start |
| zabbixBrowserMonitoring.webdriver.enabled | bool | `true` | Enable webdriver |
| zabbixBrowserMonitoring.webdriver.image.pullPolicy | string | `"IfNotPresent"` | Pull policy of Docker image |
| zabbixBrowserMonitoring.webdriver.image.pullSecrets | list | `[]` | List of dockerconfig secrets names to use when pulling images |
| zabbixBrowserMonitoring.webdriver.image.repository | string | `"selenium/standalone-chrome"` | WebDriver container image |
| zabbixBrowserMonitoring.webdriver.image.tag | string | `"127.0-chromedriver-127.0-grid-4.23.0-20240727"` | WebDriver container image tag, See https://hub.docker.com/r/selenium/standalone-chrome/tags |
| zabbixBrowserMonitoring.webdriver.name | string | `"chrome"` | WebDriver container name |
| zabbixBrowserMonitoring.webdriver.port | int | `4444` | WebDriver container port |
| zabbixImageTag | string | `"ubuntu-7.0.13"` | Zabbix components (server, agent, web frontend, ...) image tag to use. This helm chart is compatible with non-LTS version of Zabbix, that include important changes and functionalities. But by default this helm chart will install the latest LTS version (example: 7.0.x). See more info in [Zabbix Life Cycle & Release Policy](https://www.zabbix.com/life_cycle_and_release_policy) page When you want use a non-LTS version (example: 7.2.x), you have to set this yourself. You can change version here or overwrite in each component (example: zabbixserver.image.tag, etc). |
| zabbixJavaGateway.ZABBIX_OPTIONS | string | `""` | Additional arguments for Zabbix Java Gateway. Useful to enable additional libraries and features. |
| zabbixJavaGateway.ZBX_DEBUGLEVEL | int | `3` | The variable is used to specify debug level, from 0 to 5 |
| zabbixJavaGateway.ZBX_JAVAGATEWAY | string | `"zabbix-java-gateway"` |  |
| zabbixJavaGateway.ZBX_PROPERTIES_FILE | string | `""` | Name of properties file. Can be used to set additional properties using a key-value format in such a way that they are not visible on a command line or to overwrite existing ones. |
| zabbixJavaGateway.ZBX_START_POLLERS | int | `5` | This variable is specified amount of pollers. By default, value is 5 |
| zabbixJavaGateway.ZBX_TIMEOUT | int | `3` | This variable is used to specify timeout for outgoing connections. By default, value is 3. |
| zabbixJavaGateway.enabled | bool | `false` | Enables use of **Zabbix Java Gateway** |
| zabbixJavaGateway.extraContainers | list | `[]` | Additional containers to start within the Zabbix Java Gateway pod |
| zabbixJavaGateway.extraDeploymentAnnotations | object | `{}` | Annotations to add to the deployment |
| zabbixJavaGateway.extraDeploymentLabels | object | `{}` | Labels to add to the deployment |
| zabbixJavaGateway.extraEnv | list | `[]` | Extra environment variables. A list of additional environment variables. List can be extended with other environment variables listed here: https://github.com/zabbix/zabbix-docker/tree/6.0/Dockerfiles/agent2/alpine#environment-variables. See example: https://github.com/zabbix-community/helm-zabbix/blob/main/charts/zabbix/docs/example/kind/values.yaml |
| zabbixJavaGateway.extraInitContainers | list | `[]` | Additional init containers to start within the Zabbix Java Gateway pod |
| zabbixJavaGateway.extraPodAnnotations | object | `{}` | Annotations to add to the pod |
| zabbixJavaGateway.extraPodLabels | object | `{}` | Labels to add to the pod |
| zabbixJavaGateway.extraPodSpecs | object | `{}` | Additional specifications to the Zabbix Java Gateway pod |
| zabbixJavaGateway.extraVolumeMounts | list | `[]` | Additional volumeMounts to the Zabbix Java Gateway container |
| zabbixJavaGateway.extraVolumes | list | `[]` | Additional volumes to make available to the Zabbix Java Gateway pod |
| zabbixJavaGateway.image.pullPolicy | string | `"IfNotPresent"` | Pull policy of Docker image |
| zabbixJavaGateway.image.pullSecrets | list | `[]` | List of dockerconfig secrets names to use when pulling images |
| zabbixJavaGateway.image.repository | string | `"zabbix/zabbix-java-gateway"` | Zabbix Java Gateway Docker image name. |
| zabbixJavaGateway.image.tag | string | `nil` | Zabbix Java Gateway Docker image tag, if you want to override zabbixImageTag |
| zabbixJavaGateway.livenessProbe | object | `{"failureThreshold":3,"periodSeconds":10,"successThreshold":1,"tcpSocket":{"port":"zabbix-java-gw"},"timeoutSeconds":3}` | The kubelet uses liveness probes to know when to restart a container. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| zabbixJavaGateway.livenessProbe.tcpSocket.port | string | `"zabbix-java-gw"` | Port number/alias name of the container |
| zabbixJavaGateway.nodeSelector | object | `{}` | nodeSelector configurations. Reference: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/ |
| zabbixJavaGateway.podAntiAffinity | bool | `true` | Set permissive podAntiAffinity to spread replicas over cluster nodes if replicaCount>1 |
| zabbixJavaGateway.readinessProbe | object | `{}` | The kubelet uses readiness probes to know when a container is ready to start accepting traffic. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| zabbixJavaGateway.replicaCount | int | `1` | Number of replicas of ``Zabbix Java Gateway`` module |
| zabbixJavaGateway.resources | object | `{}` | Requests and limits of pod resources. See: [https://kubernetes.io/docs/concepts/configuration/manage-resources-containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers) |
| zabbixJavaGateway.securityContext | object | `{}` | Security Context configurations. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| zabbixJavaGateway.service.annotations | object | `{}` | Annotations for the zabbix-java-gateway service |
| zabbixJavaGateway.service.clusterIP | string | `nil` | clusterIP is the IP address of the service and is usually assigned randomly. If an address is specified manually, is in-range (as per system configuration), and is not in use, it will be allocated to the service. |
| zabbixJavaGateway.service.externalIPs | list | `[]` | externalIPs is a list of IP addresses for which nodes in the cluster will also accept traffic for this service. These IPs are not managed by Kubernetes. |
| zabbixJavaGateway.service.loadBalancerClass | string | `""` | loadBalancerClass is the class of the load balancer implementation this Service belongs to. If specified, the value of this field must be a label-style identifier, with an optional prefix, e.g. "internal-vip" or "example.com/internal-vip". Unprefixed names are reserved for end-users. This field can only be set when the Service type is 'LoadBalancer'. If not set, the default load balancer implementation is used, today this is typically done through the cloud provider integration, but should apply for any default implementation. If set, it is assumed that a load balancer implementation is watching for Services with a matching class. Any default load balancer implementation (e.g. cloud providers) should ignore Services that set this field. This field can only be set when creating or updating a Service to type 'LoadBalancer'. Once set, it can not be changed. This field will be wiped when a service is updated to a non 'LoadBalancer' type. |
| zabbixJavaGateway.service.loadBalancerIP | string | `""` | Only applies to Service Type: LoadBalancer. This feature depends on whether the underlying cloud-provider supports specifying the loadBalancerIP when a load balancer is created. This field will be ignored if the cloud-provider does not support the feature. |
| zabbixJavaGateway.service.loadBalancerSourceRanges | list | `[]` | If specified and supported by the platform, this will restrict traffic through the cloud-provider load-balancer will be restricted to the specified client IPs. This field will be ignored if the cloud-provider does not support the feature. |
| zabbixJavaGateway.service.nodePort | int | `31052` | NodePort port to allocate on each node (only if service.type = NodePort or Loadbalancer) |
| zabbixJavaGateway.service.port | int | `10052` | Port of service in Kubernetes cluster |
| zabbixJavaGateway.service.sessionAffinity | string | `"None"` | Supports "ClientIP" and "None". Used to maintain session affinity. Enable client IP based session affinity. Must be ClientIP or None. Defaults to None. More info: https://kubernetes.io/docs/concepts/services-networking/service/#virtual-ips-and-service-proxies |
| zabbixJavaGateway.service.type | string | `"ClusterIP"` | Type of service to expose the application. Valid options are ExternalName, ClusterIP, NodePort, and LoadBalancer. More details: https://kubernetes.io/docs/concepts/services-networking/service/ |
| zabbixJavaGateway.startupProbe | object | `{"failureThreshold":5,"initialDelaySeconds":15,"periodSeconds":5,"successThreshold":1,"tcpSocket":{"port":"zabbix-java-gw"},"timeoutSeconds":3}` | The kubelet uses startup probes to know when a container application has started.  Reference: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| zabbixJavaGateway.startupProbe.tcpSocket.port | string | `"zabbix-java-gw"` | Port number/alias name of the container |
| zabbixProxy.ZBX_DEBUGLEVEL | int | `4` |  |
| zabbixProxy.ZBX_HOSTNAME | string | `"zabbix-proxy"` | Zabbix Proxy hostname. Case sensitive hostname. If not defined the pod name will be used |
| zabbixProxy.ZBX_JAVAGATEWAY_ENABLE | bool | `false` | The variable enable communication with Zabbix Java Gateway to collect Java related checks. By default, value is false. |
| zabbixProxy.ZBX_PROXYMODE | int | `0` | The variable allows to switch Zabbix Proxy mode. By default, value is 0 - active proxy. Allowed values are 0 and 1. |
| zabbixProxy.ZBX_SERVER_HOST | string | `"zabbix-zabbix-server"` | Zabbix Server host |
| zabbixProxy.ZBX_SERVER_PORT | int | `10051` | Zabbix Server port |
| zabbixProxy.ZBX_TIMEOUT | int | `4` |  |
| zabbixProxy.ZBX_VMWARECACHESIZE | string | `"128M"` | Cache size |
| zabbixProxy.enabled | bool | `false` | Enables use of **Zabbix Proxy** |
| zabbixProxy.extraContainers | list | `[]` | Additional containers to start within the Zabbix Proxy pod |
| zabbixProxy.extraEnv | list | `[]` | Extra environment variables. A list of additional environment variables. List can be extended with other environment variables listed here: https://github.com/zabbix/zabbix-docker/tree/6.0/Dockerfiles/proxy-sqlite3/alpine#environment-variables. See example: https://github.com/zabbix-community/helm-zabbix/blob/main/charts/zabbix/docs/example/kind/values.yaml |
| zabbixProxy.extraInitContainers | list | `[]` | Additional init containers to start within the Zabbix Proxy pod |
| zabbixProxy.extraPodAnnotations | object | `{}` | Annotations to add to the pod |
| zabbixProxy.extraPodLabels | object | `{}` | Labels to add to the pod |
| zabbixProxy.extraPodSpecs | object | `{}` | Additional specifications to the Zabbix Proxy pod |
| zabbixProxy.extraStatefulSetAnnotations | object | `{}` | Annotations to add to the statefulset |
| zabbixProxy.extraStatefulSetLabels | object | `{}` | Labels to add to the statefulset |
| zabbixProxy.extraVolumeClaimTemplate | list | `[]` | Extra volumeClaimTemplate for zabbixProxy statefulset |
| zabbixProxy.extraVolumeMounts | list | `[]` | Additional volumeMounts to the Zabbix Proxy container |
| zabbixProxy.extraVolumes | list | `[]` | Additional volumes to make available to the Zabbix Proxy pod |
| zabbixProxy.image.pullPolicy | string | `"IfNotPresent"` | Pull policy of Docker image |
| zabbixProxy.image.pullSecrets | list | `[]` | List of dockerconfig secrets names to use when pulling images |
| zabbixProxy.image.repository | string | `"zabbix/zabbix-proxy-sqlite3"` | Zabbix Proxy Docker image name |
| zabbixProxy.image.tag | string | `nil` | Zabbix Proxy Docker image tag, if you want to override zabbixImageTag |
| zabbixProxy.lifecycle | object | `{}` | Container Lifecycle Hooks. Reference: https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/ |
| zabbixProxy.livenessProbe | object | `{}` | The kubelet uses liveness probes to know when to restart a container. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| zabbixProxy.nodeSelector | object | `{}` | nodeSelector configurations. Reference: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/ |
| zabbixProxy.readinessProbe | object | `{}` | The kubelet uses readiness probes to know when a container is ready to start accepting traffic. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| zabbixProxy.replicaCount | int | `1` | Number of replicas of ``zabbixProxy`` module |
| zabbixProxy.resources | object | `{}` | Requests and limits of pod resources. See: [https://kubernetes.io/docs/concepts/configuration/manage-resources-containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers) |
| zabbixProxy.securityContext | object | `{}` | Security Context configurations. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| zabbixProxy.service.annotations | object | `{}` | Annotations for the zabbix-proxy service |
| zabbixProxy.service.clusterIP | string | `nil` | clusterIP is the IP address of the service and is usually assigned randomly. If an address is specified manually, is in-range (as per system configuration), and is not in use, it will be allocated to the service. |
| zabbixProxy.service.externalIPs | list | `[]` | externalIPs is a list of IP addresses for which nodes in the cluster will also accept traffic for this service. These IPs are not managed by Kubernetes. |
| zabbixProxy.service.loadBalancerClass | string | `""` | loadBalancerClass is the class of the load balancer implementation this Service belongs to. If specified, the value of this field must be a label-style identifier, with an optional prefix, e.g. "internal-vip" or "example.com/internal-vip". Unprefixed names are reserved for end-users. This field can only be set when the Service type is 'LoadBalancer'. If not set, the default load balancer implementation is used, today this is typically done through the cloud provider integration, but should apply for any default implementation. If set, it is assumed that a load balancer implementation is watching for Services with a matching class. Any default load balancer implementation (e.g. cloud providers) should ignore Services that set this field. This field can only be set when creating or updating a Service to type 'LoadBalancer'. Once set, it can not be changed. This field will be wiped when a service is updated to a non 'LoadBalancer' type. |
| zabbixProxy.service.loadBalancerIP | string | `""` | Only applies to Service Type: LoadBalancer. This feature depends on whether the underlying cloud-provider supports specifying the loadBalancerIP when a load balancer is created. This field will be ignored if the cloud-provider does not support the feature. |
| zabbixProxy.service.loadBalancerSourceRanges | list | `[]` | If specified and supported by the platform, this will restrict traffic through the cloud-provider load-balancer will be restricted to the specified client IPs. This field will be ignored if the cloud-provider does not support the feature. |
| zabbixProxy.service.nodePort | int | `31053` | NodePort port to allocate on each node (only if service.type = NodePort or Loadbalancer) |
| zabbixProxy.service.port | int | `10051` | Port of service in Kubernetes cluster |
| zabbixProxy.service.sessionAffinity | string | `"None"` | Supports "ClientIP" and "None". Used to maintain session affinity. Enable client IP based session affinity. Must be ClientIP or None. Defaults to None. More info: https://kubernetes.io/docs/concepts/services-networking/service/#virtual-ips-and-service-proxies |
| zabbixProxy.service.type | string | `"ClusterIP"` | Type of service to expose the application. Valid options are ExternalName, ClusterIP, NodePort, and LoadBalancer. More details: https://kubernetes.io/docs/concepts/services-networking/service/ |
| zabbixProxy.startupProbe | object | `{}` | The kubelet uses startup probes to know when a container application has started.  Reference: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| zabbixServer.enabled | bool | `true` | Enables use of **Zabbix Server** |
| zabbixServer.extraContainers | list | `[]` | Additional containers to start within the Zabbix Server pod |
| zabbixServer.extraDeploymentAnnotations | object | `{}` | Annotations to add to the deployment |
| zabbixServer.extraDeploymentLabels | object | `{}` | Labels to add to the deployment |
| zabbixServer.extraEnv | list | `[]` | Extra environment variables. A list of additional environment variables. List can be extended with other environment variables listed here: https://github.com/zabbix/zabbix-docker/tree/6.0/Dockerfiles/server-pgsql/alpine#environment-variables. See example: https://github.com/zabbix-community/helm-zabbix/blob/main/charts/zabbix/docs/example/kind/values.yaml |
| zabbixServer.extraInitContainers | list | `[]` | Additional init containers to start within the Zabbix Server pod |
| zabbixServer.extraPodAnnotations | object | `{}` | Annotations to add to the pods |
| zabbixServer.extraPodLabels | object | `{}` | Labels to add to the pods |
| zabbixServer.extraPodSpecs | object | `{}` | Additional specifications to the Zabbix Server pod |
| zabbixServer.extraVolumeMounts | list | `[]` | Additional volumeMounts to the Zabbix Server container |
| zabbixServer.extraVolumes | list | `[]` | Additional volumes to make available to the Zabbix Server pod |
| zabbixServer.haNodesAutoClean | object | `{"concurrencyPolicy":"Replace","cronjobLabels":{},"deleteOlderThanSeconds":3600,"enabled":true,"extraContainers":[],"extraEnv":[],"extraInitContainers":[],"extraPodSpecs":{},"extraVolumeMounts":[],"extraVolumes":[],"image":{"pullPolicy":"IfNotPresent","pullSecrets":[],"repository":"postgres","tag":16},"resources":{},"schedule":"0 1 * * *","securityContext":{}}` | Automatically clean orphaned ha nodes from ha_nodes db table |
| zabbixServer.haNodesAutoClean.cronjobLabels | object | `{}` | Labels to add to the cronjob for ha nodes autoclean |
| zabbixServer.haNodesAutoClean.extraContainers | list | `[]` | Additional containers to start within the cronjob hanodes autoclean |
| zabbixServer.haNodesAutoClean.extraEnv | list | `[]` | Extra environment variables. A list of additional environment variables. |
| zabbixServer.haNodesAutoClean.extraInitContainers | list | `[]` | Additional init containers to start within the cronjob hanodes autoclean |
| zabbixServer.haNodesAutoClean.extraPodSpecs | object | `{}` | Additional specifications to the cronjob hanodes autoclean |
| zabbixServer.haNodesAutoClean.extraVolumeMounts | list | `[]` | Additional volumeMounts to the cronjob hanodes autoclean |
| zabbixServer.haNodesAutoClean.extraVolumes | list | `[]` | Additional volumes to make available to the cronjob hanodes autoclean |
| zabbixServer.haNodesAutoClean.image.repository | string | `"postgres"` | Postgresql Docker image name: chose one of "postgres" or "timescale/timescaledb" |
| zabbixServer.haNodesAutoClean.image.tag | int | `16` | Tag of Docker image of Postgresql server, choice "16" for postgres "2.17.2-pg16" for timescaledb (Zabbix supports TimescaleDB. More info: https://www.zabbix.com/documentation/7.0/en/manual/installation/requirements) |
| zabbixServer.haNodesAutoClean.resources | object | `{}` | Requests and limits of pod resources. See: [https://kubernetes.io/docs/concepts/configuration/manage-resources-containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers) |
| zabbixServer.haNodesAutoClean.securityContext | object | `{}` | Security Context configurations. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| zabbixServer.hostIP | string | `"0.0.0.0"` | Optional set hostIP different from 0.0.0.0 to open port only on this IP |
| zabbixServer.hostPort | bool | `false` | Optional set true open a port direct on node where Zabbix Server runs |
| zabbixServer.image.pullPolicy | string | `"IfNotPresent"` | Pull policy of Docker image |
| zabbixServer.image.pullSecrets | list | `[]` | List of dockerconfig secrets names to use when pulling images |
| zabbixServer.image.repository | string | `"zabbix/zabbix-server-pgsql"` | Zabbix Server Docker image name |
| zabbixServer.image.tag | string | `nil` | Zabbix Server Docker image tag, if you want to override zabbixImageTag |
| zabbixServer.livenessProbe | object | `{}` | The kubelet uses liveness probes to know when to restart a container. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| zabbixServer.nodeSelector | object | `{}` | nodeSelector configurations. Reference: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/ |
| zabbixServer.podAntiAffinity | bool | `true` | Set permissive podAntiAffinity to spread replicas over cluster nodes if replicaCount>1 |
| zabbixServer.readinessProbe | object | `{}` | The kubelet uses readiness probes to know when a container is ready to start accepting traffic. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| zabbixServer.replicaCount | int | `1` | Number of replicas of ``zabbixServer`` module. Will be forced to be 1 if ``zabbixServer.zabbixServerHA=false`` |
| zabbixServer.resources | object | `{}` | Requests and limits of pod resources. See: [https://kubernetes.io/docs/concepts/configuration/manage-resources-containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers) |
| zabbixServer.securityContext | object | `{}` | Security Context configurations. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| zabbixServer.service.annotations | object | `{}` | Annotations for the zabbix-server service |
| zabbixServer.service.clusterIP | string | `nil` | clusterIP is the IP address of the service and is usually assigned randomly. If an address is specified manually, is in-range (as per system configuration), and is not in use, it will be allocated to the service. |
| zabbixServer.service.externalIPs | list | `[]` | externalIPs is a list of IP addresses for which nodes in the cluster will also accept traffic for this service. These IPs are not managed by Kubernetes. |
| zabbixServer.service.loadBalancerClass | string | `""` | loadBalancerClass is the class of the load balancer implementation this Service belongs to. If specified, the value of this field must be a label-style identifier, with an optional prefix, e.g. "internal-vip" or "example.com/internal-vip". Unprefixed names are reserved for end-users. This field can only be set when the Service type is 'LoadBalancer'. If not set, the default load balancer implementation is used, today this is typically done through the cloud provider integration, but should apply for any default implementation. If set, it is assumed that a load balancer implementation is watching for Services with a matching class. Any default load balancer implementation (e.g. cloud providers) should ignore Services that set this field. This field can only be set when creating or updating a Service to type 'LoadBalancer'. Once set, it can not be changed. This field will be wiped when a service is updated to a non 'LoadBalancer' type. |
| zabbixServer.service.loadBalancerIP | string | `""` | Only applies to Service Type: LoadBalancer. This feature depends on whether the underlying cloud-provider supports specifying the loadBalancerIP when a load balancer is created. This field will be ignored if the cloud-provider does not support the feature. |
| zabbixServer.service.loadBalancerSourceRanges | list | `[]` | If specified and supported by the platform, this will restrict traffic through the cloud-provider load-balancer will be restricted to the specified client IPs. This field will be ignored if the cloud-provider does not support the feature. |
| zabbixServer.service.nodePort | int | `31051` | NodePort port to allocate on each node (only if service.type = NodePort or Loadbalancer) |
| zabbixServer.service.port | int | `10051` | Port of service in Kubernetes cluster |
| zabbixServer.service.sessionAffinity | string | `"None"` | Supports "ClientIP" and "None". Used to maintain session affinity. Enable client IP based session affinity. Must be ClientIP or None. Defaults to None. More info: https://kubernetes.io/docs/concepts/services-networking/service/#virtual-ips-and-service-proxies |
| zabbixServer.service.type | string | `"ClusterIP"` | Type of service to expose the application. Valid options are ExternalName, ClusterIP, NodePort, and LoadBalancer. More details: https://kubernetes.io/docs/concepts/services-networking/service/ |
| zabbixServer.startupProbe | object | `{}` | The kubelet uses startup probes to know when a container application has started.  Reference: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| zabbixServer.zabbixServerHA | object | `{"dbCreateUpgradeJob":{"extraContainers":[],"extraInitContainers":[],"extraPodSpecs":{},"extraVolumeMounts":[],"extraVolumes":[],"image":{"pullPolicy":"IfNotPresent","pullSecrets":[],"repository":"ghcr.io/zabbix-community/zabbix-server-create-upgrade-db","tag":"","tagSuffix":"20241230222241"},"resources":{},"securityContext":{}},"enabled":false,"haLabelsSidecar":{"extraVolumeMounts":[],"image":{"pullPolicy":"IfNotPresent","pullSecrets":[],"repository":"ghcr.io/zabbix-community/zabbix-server-ha-label-manager","tag":"20241230230305"},"labelName":"zabbix.com/server-ha-role","resources":{},"securityContext":{}},"role":{"annotations":{}},"roleBinding":{"annotations":{}},"serviceAccount":{"annotations":{}}}` | Section responsible for native Zabbix Server High Availability support of this Helm Chart |
| zabbixServer.zabbixServerHA.dbCreateUpgradeJob | object | `{"extraContainers":[],"extraInitContainers":[],"extraPodSpecs":{},"extraVolumeMounts":[],"extraVolumes":[],"image":{"pullPolicy":"IfNotPresent","pullSecrets":[],"repository":"ghcr.io/zabbix-community/zabbix-server-create-upgrade-db","tag":"","tagSuffix":"20241230222241"},"resources":{},"securityContext":{}}` | Settings for the database initialization / upgrade job needed for HA enabled setups |
| zabbixServer.zabbixServerHA.dbCreateUpgradeJob.extraContainers | list | `[]` | Additional containers to start within the dbCreateUpgradeJob pod |
| zabbixServer.zabbixServerHA.dbCreateUpgradeJob.extraInitContainers | list | `[]` | Additional init containers to start within the dbCreateUpgradeJob pod |
| zabbixServer.zabbixServerHA.dbCreateUpgradeJob.extraPodSpecs | object | `{}` | Additional specifications to the dbCreateUpgradeJob pod |
| zabbixServer.zabbixServerHA.dbCreateUpgradeJob.extraVolumeMounts | list | `[]` | Additional volumeMounts to the dbCreateUpgradeJob pod |
| zabbixServer.zabbixServerHA.dbCreateUpgradeJob.extraVolumes | list | `[]` | Additional volumes to make available to the dbCreateUpgradeJob pod |
| zabbixServer.zabbixServerHA.dbCreateUpgradeJob.image | object | `{"pullPolicy":"IfNotPresent","pullSecrets":[],"repository":"ghcr.io/zabbix-community/zabbix-server-create-upgrade-db","tag":"","tagSuffix":"20241230222241"}` | Image settings for the database initialization / upgrade job |
| zabbixServer.zabbixServerHA.dbCreateUpgradeJob.image.pullPolicy | string | `"IfNotPresent"` | Pull policy for the db initialization / upgrade job |
| zabbixServer.zabbixServerHA.dbCreateUpgradeJob.image.pullSecrets | list | `[]` | Pull secrets for the db initialization / upgrade job |
| zabbixServer.zabbixServerHA.dbCreateUpgradeJob.image.repository | string | `"ghcr.io/zabbix-community/zabbix-server-create-upgrade-db"` | Image repository for the database initialization / upgrade job |
| zabbixServer.zabbixServerHA.dbCreateUpgradeJob.image.tag | string | `""` | it is going to be chosen based of the zabbix_server pod container otherwise |
| zabbixServer.zabbixServerHA.dbCreateUpgradeJob.image.tagSuffix | string | `"20241230222241"` | The tag suffix used for the dbCreateUpgradeJob's image when not explicitly specifying a tag for the image. The tag name will be concatenated with major release of zabbix_server image if specified |
| zabbixServer.zabbixServerHA.dbCreateUpgradeJob.resources | object | `{}` | Resource requests and limits for the dbCreateUpgradeJob pod |
| zabbixServer.zabbixServerHA.dbCreateUpgradeJob.securityContext | object | `{}` | Security Context configurations. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| zabbixServer.zabbixServerHA.enabled | bool | `false` | Enables support for Zabbix Server High Availability. If disabled, replicaCount will always be 1. Can not be combined with ``postgresql.enabled=true`` |
| zabbixServer.zabbixServerHA.haLabelsSidecar | object | `{"extraVolumeMounts":[],"image":{"pullPolicy":"IfNotPresent","pullSecrets":[],"repository":"ghcr.io/zabbix-community/zabbix-server-ha-label-manager","tag":"20241230230305"},"labelName":"zabbix.com/server-ha-role","resources":{},"securityContext":{}}` | The HA labels sidecar checks for the current pod whether it is the active Zabbix Server HA node and sets labels on it, accordingly |
| zabbixServer.zabbixServerHA.haLabelsSidecar.extraVolumeMounts | list | `[]` | Extra VolumeMounts for the HA labels sidecar |
| zabbixServer.zabbixServerHA.haLabelsSidecar.image | object | `{"pullPolicy":"IfNotPresent","pullSecrets":[],"repository":"ghcr.io/zabbix-community/zabbix-server-ha-label-manager","tag":"20241230230305"}` | Image settings for the HA labels sidecar |
| zabbixServer.zabbixServerHA.haLabelsSidecar.image.pullPolicy | string | `"IfNotPresent"` | Pull policy for the HA labels sidecar image |
| zabbixServer.zabbixServerHA.haLabelsSidecar.image.pullSecrets | list | `[]` | Pull secrets for the HA labels sidecar image |
| zabbixServer.zabbixServerHA.haLabelsSidecar.image.repository | string | `"ghcr.io/zabbix-community/zabbix-server-ha-label-manager"` | Repository where to get the image for the HA labels sidecar container |
| zabbixServer.zabbixServerHA.haLabelsSidecar.image.tag | string | `"20241230230305"` | Tag of the HA labels sidecar container image |
| zabbixServer.zabbixServerHA.haLabelsSidecar.labelName | string | `"zabbix.com/server-ha-role"` | Label name for the sidecar to set on the zabbix server pods, will be used in the zabbix server Service as an additional selector to point to the active Zabbix Server pod |
| zabbixServer.zabbixServerHA.haLabelsSidecar.resources | object | `{}` | Resource requests and limits for the HA labels sidecar |
| zabbixServer.zabbixServerHA.haLabelsSidecar.securityContext | object | `{}` | Security context for the HA labels sidecar |
| zabbixServer.zabbixServerHA.role | object | `{"annotations":{}}` | K8S Role being used for database initialization and upgrade job, which needs access to certain Kubernetes resources |
| zabbixServer.zabbixServerHA.role.annotations | object | `{}` | Extra annotations for the role needed to give the HA related sidecars and the DB job API permissions |
| zabbixServer.zabbixServerHA.roleBinding | object | `{"annotations":{}}` | Rolebinding being used for the database initialization and upgrade job |
| zabbixServer.zabbixServerHA.roleBinding.annotations | object | `{}` | Extra annotations for the roleBinding needed to give the HA related DB init and upgrade job |
| zabbixServer.zabbixServerHA.serviceAccount | object | `{"annotations":{}}` | Serviceaccount for the database initialization and upgrade job |
| zabbixServer.zabbixServerHA.serviceAccount.annotations | object | `{}` | Extra annotations for the serviceAccount needed to give the DB job API permissions |
| zabbixWeb.enabled | bool | `true` | Enables use of **Zabbix Web** |
| zabbixWeb.extraContainers | list | `[]` | Additional containers to start within the Zabbix Web pod |
| zabbixWeb.extraDeploymentAnnotations | object | `{}` | Annotations to add to the deployment |
| zabbixWeb.extraDeploymentLabels | object | `{}` | Labels to add to the deployment |
| zabbixWeb.extraEnv | list | `[]` | Extra environment variables. A list of additional environment variables. List can be extended with other environment variables listed here: https://github.com/zabbix/zabbix-docker/tree/6.0/Dockerfiles/web-apache-pgsql/alpine#environment-variables. See example: https://github.com/zabbix-community/helm-zabbix/blob/main/charts/zabbix/docs/example/kind/values.yaml |
| zabbixWeb.extraInitContainers | list | `[]` | Additional init containers to start within the Zabbix Web pod |
| zabbixWeb.extraPodAnnotations | object | `{}` | Annotations to add to the pods |
| zabbixWeb.extraPodLabels | object | `{}` | Labels to add to the pods |
| zabbixWeb.extraPodSpecs | object | `{}` | Additional specifications to the Zabbix Web pod |
| zabbixWeb.extraVolumeMounts | list | `[]` | Additional volumeMounts to the Zabbix Web container |
| zabbixWeb.extraVolumes | list | `[]` | Additional volumes to make available to the Zabbix Web pod |
| zabbixWeb.image.pullPolicy | string | `"IfNotPresent"` | Pull policy of Docker image |
| zabbixWeb.image.pullSecrets | list | `[]` | List of dockerconfig secrets names to use when pulling images |
| zabbixWeb.image.repository | string | `"zabbix/zabbix-web-nginx-pgsql"` | Zabbix Web Docker image name |
| zabbixWeb.image.tag | string | `nil` | Zabbix Web Docker image tag, if you want to override zabbixImageTag |
| zabbixWeb.livenessProbe.failureThreshold | int | `6` |  |
| zabbixWeb.livenessProbe.httpGet.path | string | `"/"` | Path of health check of application |
| zabbixWeb.livenessProbe.httpGet.port | string | `"zabbix-web"` | Port number/alias name of the container |
| zabbixWeb.livenessProbe.initialDelaySeconds | int | `30` |  |
| zabbixWeb.livenessProbe.periodSeconds | int | `10` |  |
| zabbixWeb.livenessProbe.successThreshold | int | `1` |  |
| zabbixWeb.livenessProbe.timeoutSeconds | int | `5` |  |
| zabbixWeb.nodeSelector | object | `{}` | nodeSelector configurations. Reference: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/ |
| zabbixWeb.podAntiAffinity | bool | `true` | set permissive podAntiAffinity to spread replicas over cluster nodes if replicaCount>1 |
| zabbixWeb.readinessProbe.failureThreshold | int | `6` |  |
| zabbixWeb.readinessProbe.httpGet.path | string | `"/"` | Path of health check of application |
| zabbixWeb.readinessProbe.httpGet.port | string | `"zabbix-web"` | Port number/alias name of the container |
| zabbixWeb.readinessProbe.initialDelaySeconds | int | `5` |  |
| zabbixWeb.readinessProbe.periodSeconds | int | `10` |  |
| zabbixWeb.readinessProbe.successThreshold | int | `1` |  |
| zabbixWeb.readinessProbe.timeoutSeconds | int | `5` |  |
| zabbixWeb.replicaCount | int | `1` | Number of replicas of ``zabbixWeb`` module |
| zabbixWeb.resources | object | `{}` | Requests and limits of pod resources. See: [https://kubernetes.io/docs/concepts/configuration/manage-resources-containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers) |
| zabbixWeb.samlCertsSecretName | string | `""` | Secret name containing certificates for SAML configuration. Example: zabbix-web-samlcerts |
| zabbixWeb.securityContext | object | `{}` | Security Context configurations. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| zabbixWeb.service.annotations | object | `{}` | Annotations for the Zabbix Web |
| zabbixWeb.service.clusterIP | string | `nil` | clusterIP is the IP address of the service and is usually assigned randomly. If an address is specified manually, is in-range (as per system configuration), and is not in use, it will be allocated to the service. |
| zabbixWeb.service.externalIPs | list | `[]` | externalIPs is a list of IP addresses for which nodes in the cluster will also accept traffic for this service. These IPs are not managed by Kubernetes. |
| zabbixWeb.service.loadBalancerClass | string | `""` | loadBalancerClass is the class of the load balancer implementation this Service belongs to. If specified, the value of this field must be a label-style identifier, with an optional prefix, e.g. "internal-vip" or "example.com/internal-vip". Unprefixed names are reserved for end-users. This field can only be set when the Service type is 'LoadBalancer'. If not set, the default load balancer implementation is used, today this is typically done through the cloud provider integration, but should apply for any default implementation. If set, it is assumed that a load balancer implementation is watching for Services with a matching class. Any default load balancer implementation (e.g. cloud providers) should ignore Services that set this field. This field can only be set when creating or updating a Service to type 'LoadBalancer'. Once set, it can not be changed. This field will be wiped when a service is updated to a non 'LoadBalancer' type. |
| zabbixWeb.service.loadBalancerIP | string | `""` | Only applies to Service Type: LoadBalancer. This feature depends on whether the underlying cloud-provider supports specifying the loadBalancerIP when a load balancer is created. This field will be ignored if the cloud-provider does not support the feature. |
| zabbixWeb.service.loadBalancerSourceRanges | list | `[]` | If specified and supported by the platform, this will restrict traffic through the cloud-provider load-balancer will be restricted to the specified client IPs. This field will be ignored if the cloud-provider does not support the feature. |
| zabbixWeb.service.nodePort | int | `31080` | NodePort port to allocate on each node (only if service.type = NodePort or Loadbalancer) |
| zabbixWeb.service.port | int | `80` |  |
| zabbixWeb.service.sessionAffinity | string | `"None"` | Supports "ClientIP" and "None". Used to maintain session affinity. Enable client IP based session affinity. Must be ClientIP or None. Defaults to None. More info: https://kubernetes.io/docs/concepts/services-networking/service/#virtual-ips-and-service-proxies |
| zabbixWeb.service.type | string | `"ClusterIP"` | Type of service to expose the application. Valid options are ExternalName, ClusterIP, NodePort, and LoadBalancer. More details: https://kubernetes.io/docs/concepts/services-networking/service/ |
| zabbixWeb.startupProbe | object | `{}` | The kubelet uses startup probes to know when a container application has started.  Reference: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| zabbixWebService.enabled | bool | `true` | Enables use of **Zabbix Web Service** |
| zabbixWebService.extraContainers | list | `[]` | Additional containers to start within the Zabbix Web Service pod |
| zabbixWebService.extraDeploymentAnnotations | object | `{}` | Annotations to add to the deployment |
| zabbixWebService.extraDeploymentLabels | object | `{}` | Labels to add to the deployment |
| zabbixWebService.extraEnv | list | `[]` | Extra environment variables. A list of additional environment variables. List can be extended with other environment variables listed here: https://github.com/zabbix/zabbix-docker/tree/6.0/Dockerfiles/web-service/alpine#environment-variables. See example: https://github.com/zabbix-community/helm-zabbix/blob/main/charts/zabbix/docs/example/kind/values.yaml |
| zabbixWebService.extraInitContainers | list | `[]` | Additional init containers to start within the Zabbix Web Service pod |
| zabbixWebService.extraPodAnnotations | object | `{}` | Annotations to add to the pods |
| zabbixWebService.extraPodLabels | object | `{}` | Labels to add to the pods |
| zabbixWebService.extraPodSpecs | object | `{}` | Additional specifications to the Zabbix Web Service pod |
| zabbixWebService.extraVolumeMounts | list | `[]` | Additional volumeMounts to the Zabbix Web Service container |
| zabbixWebService.extraVolumes | list | `[]` | Additional volumes to make available to the Zabbix Web Service pod |
| zabbixWebService.image.pullPolicy | string | `"IfNotPresent"` | Pull policy of Docker image |
| zabbixWebService.image.pullSecrets | list | `[]` | List of dockerconfig secrets names to use when pulling images |
| zabbixWebService.image.repository | string | `"zabbix/zabbix-web-service"` | Zabbix Webservice Docker image name |
| zabbixWebService.image.tag | string | `nil` | Zabbix Webservice Docker image tag, if you want to override zabbixImageTag |
| zabbixWebService.livenessProbe | object | `{}` | The kubelet uses liveness probes to know when to restart a container. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| zabbixWebService.nodeSelector | object | `{}` | nodeSelector configurations. Reference: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/ |
| zabbixWebService.podAntiAffinity | bool | `true` | Set permissive podAntiAffinity to spread replicas over cluster nodes if replicaCount>1 |
| zabbixWebService.readinessProbe | object | `{}` | The kubelet uses readiness probes to know when a container is ready to start accepting traffic. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| zabbixWebService.replicaCount | int | `1` | Number of replicas of ``zabbixWebService`` module |
| zabbixWebService.resources | object | `{}` | Requests and limits of pod resources. See: [https://kubernetes.io/docs/concepts/configuration/manage-resources-containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers) |
| zabbixWebService.securityContext | object | `{}` | Security Context configurations. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| zabbixWebService.service | object | `{"annotations":{},"clusterIP":null,"port":10053,"type":"ClusterIP"}` | Set the IgnoreURLCertErrors configuration setting of Zabbix Web Service ignoreURLCertErrors=1 |
| zabbixWebService.service.annotations | object | `{}` | Annotations for the Zabbix Web Service |
| zabbixWebService.service.clusterIP | string | `nil` | clusterIP is the IP address of the service and is usually assigned randomly. If an address is specified manually, is in-range (as per system configuration), and is not in use, it will be allocated to the service. |
| zabbixWebService.service.port | int | `10053` | Port of service in Kubernetes cluster |
| zabbixWebService.service.type | string | `"ClusterIP"` | Type of service to expose the application. Valid options are ExternalName, ClusterIP, NodePort, and LoadBalancer. More details: https://kubernetes.io/docs/concepts/services-networking/service/ |
| zabbixWebService.startupProbe | object | `{}` | The kubelet uses startup probes to know when a container application has started.  Reference: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |

## Database access settings

All settings referring to how the different components that this Chart installs access the
Zabbix PostgreSQL Database (either an external, already existing database or one deployed within
this Helm chart) are being configured centrally under the ``postgresAccess`` section of the
``values.yaml`` file.

By default, this Chart will deploy it's own very simple PostgreSQL database. All settings
relevant to how to access this database will be held in one central *Secret* with the
name of the *Helm Release*, suffixed with *-db-access* and values defined in ``values.yaml``.

Instead of letting the Chart automatically generate such a secret, you can use an existing Secret.
Use ``postgresAccess.externalSecretName`` in such a case and read the comments
in ``values.yaml`` for how the keys inside the Secret holding the relevant values can be set.

If you want to connect your Zabbix installation to a Postgres database deployed using the
[CrunchyData PGO Operator](https://access.crunchydata.com/documentation/postgres-operator/latest/),
you can use the secret that PGO/CNPG generates for your database directly to connect Zabbix to it,
by just referring to its name with the ``postgresAccess.externalSecretName`` setting to it.

## Postgresql database

While the default database configuration shipped with this Chart is fine for most (very small,
for testing only) Zabbix installations, you will want to set some specific settings to better
match your setup. First of all, you should consider enabling Postgresql database persistence
(``postgresql.persistence.enabled``), as otherwise all your changes and historical data will
be gone as soon as you remove the installation of Zabbix. Additionally, you might want to tune
Postgresql by supplying extra postgresql runtime parameters using the
``postgresql.extraRuntimeParameters`` dictionary:

```yaml
postgresql:
  enabled: true
  persistence:
    enabled: true
    storageSize: 50Gi
  extraRuntimeParameters:
    max_connections: 250
    dynamic_shared_memory_type: posix
    shared_buffers: 4GB
    temp_buffers: 16MB
    work_mem: 128MB
    maintenance_work_mem: 256MB
    effective_cache_size: 6GB
    min_wal_size: 80MB
```

Alternatively, you can add your own configuration file for postgresql (using a ConfigMap and
the ``postgresql.extraVolumes`` setting) to mount it into the postgresql container and referring
to this config file with the ``postgresql.extraRuntimeParameters`` set to:

```yaml
postgresql:
  extraRuntimeParameters:
    config.file: /path/to/your/config.file
```

Much more than using the database deployment done by this Helm Chart, it is highly recommended, and for usage of the [Zabbix Server High Availability](#native-zabbix-server-high-availability) even necessary, is the usage of an external database employing proper Backup, Restore, and High Availability functionalities. A good, and probably the best, way to do this inside Kubernetes is using one of the Postgresql database operators [CrunchyData PGO Operator](https://access.crunchydata.com/documentation/postgres-operator/latest/) or [CNPG](https://cloudnative-pg.io) See [Examples](/docs/examples/). For CNPG, a simple database manifest could look as follows:

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: zabbix-db
spec:
  instances: 3
  imageName: ghcr.io/cloudnative-pg/postgresql:16
  storage:
    size: 5Gi
```

## Native Zabbix Server High Availability

Since version 6.0, Zabbix has its own implementation of [High Availability](https://www.zabbix.com/documentation/current/en/manual/concepts/server/ha), which is a simple approach to realize a Hot-Standby high availability setup with Zabbix Server. This feature applies only to the Zabbix Server component, not Zabbix Proxy, Webdriver, Web Frontend or such. In a Zabbix monitoring environment, by design, there can only be one central active Zabbix Server taking over the responsibility of storing data into database, calculating triggers, sending alerts, evt. The native High Availability concept does not change that, it just implements a way to have additional Zabbix Server processes being "standby" and "jumping in" as soon as the active one does not report it's availability (updating a table in the database), anymore. As such, the Zabbix Server High Availability works well together (and somewhat requires, to be an entirely high available setup), an also high available database setup. High availability of Postgres Database is not covered by this Helm Chart, but can rather easily be achieved by using one of the well-known Postgresql database operators [PGO](https://github.com/CrunchyData/postgres-operator) and [CNPG](https://cloudnative-pg.io), which are supported to be used with this Helm Chart.

> [!IMPORTANT]
> In order to deploy Zabbix Server in High Available mode using this Helm Chart, you need to bring your own (external) database. Recommended is to supply a highly available Postgresql setup using one of the well-known Postgresql operators [PGO](https://github.com/CrunchyData/postgres-operator) or [CNPG](https://cloudnative-pg.io) See [Examples](/docs/examples/).

For the HA feature, which has not been designed for usage in Kubernetes by Zabbix SIA, to work in K8S, there have been some challenges to overcome, primarily the fact that Zabbix Server does not allow to upgrade or to initialize database schema when running in HA mode enabled. Intention by Zabbix is to turn HA mode off, issue Major Release Upgrade, turn HA mode back on. This doesn't conclude with Kubernetes concepts. Beside of that, some additional circumstances led us to an implementation as follows:

- added a portion in values.yaml generally switching *Zabbix Server HA* on or off. If turned off, the Zabbix Server deployment will always be started with 1 replica and without the ZBX_HANODENAME env variable. This is an easy-to-use setup with no additional job pods, but it's not possible to just scale up zabbix server pods from here
- when `.Values.zabbixServer.zabbixServerHA.enabled` is set to `true`, a Kubernetes Job, marked as Helm *pre-install,pre-upgrade* hook, is being deployed used to prepare the database and the database's schema version (by "schema", we refer to the tables, their structure, etc.) prior to any Zabbix Server pods trying to access the database. This job also handles major release upgrades. In case the job is being started in a `helm upgrade` situation, it scales down zabbix server deployment before upgrading database schema, manages entries in the DBs `ha_node` table, etc. Additionally, this job figures out whether a migration from a non-HA enabled setup to a HA-enabled one has been done, and handles necessary actions (scale down pods, delete entries in database) accordingly. The image bases off the zabbix_server image and its source code can be found [here](https://github.com/zabbix-community/helm-zabbix-image-db-init-upgrade-job).

Due to the way Helm works (not offering a possibility to deploy manifests BEFORE a pre-install/pre-upgrade job) and the need to implement the database preparation as such (Helm never finishing an installation when using `--wait` flag when using post-install/post-upgrade job instead, and ArgoCD suffering the same issue), it is **not supported** to have this Helm Chart deploying the database Pod itself (`postgresql.enabled`) and enabling the Zabbix Server HA mode. `postgresql.enabled` is meant for non-production / test use cases, when for production an external database or one managed by an operator, set up in a high available manner, is strongly recommended anyway.

In order to make it possible to use **Active checks** and **Active Zabbix Proxies** with a Zabbix Server setup having High Availability enabled, a **HA Labels sidecar** has been introduced, continuously monitoring the Zabbix server pod for amount of running Zabbix server processes to figure out whether the Pod is being "active" or "standby" Zabbix Server node, and updating HA-related labels on the pod, accordingly. The image for these sidecar containers is been contained [here within this Github organization](https://github.com/zabbix-community/helm-zabbix-image-ha-labels-sidecar). The reason to implement it this way and not by probing the port number, which was my initial approach, is that probing the port of Zabbix Server will make it generate a message in the log, stating that a connection without a proper payload has been initiated towards the Zabbix Server. More info: #115

## Expose Zabbix service

- **Ingress**: The ingress controller must be installed in the Kubernetes cluster.
- **ClusterIP**: Exposes the service on a cluster-internal IP. Choosing this value makes the
service only reachable from within the cluster.
- **NodePort**: Exposes the service on each Node's IP at a static port (the NodePort).
You'll be able to contact the NodePort service, from outside the cluster, by requesting
``NodeIP:NodePort``.
- **LoadBalancer**: Exposes the service externally using a cloud provider's load balancer.

## Multiple replicas for Zabbix Proxy statefulset

In case you use proxy groups, it may be necessary to have several zabbix proxy replicas.
you can then no longer set the ZBX_HOSTNAME value.
This value will then take the name of each pod.
Name that you can then give to your zabbix proxies on the zabbix server side.

> [!IMPORTANT]
> You will need to deploy proxy service per replica if you want the Active Agent checks to work.
> **If not defined the pod name will be used.**
