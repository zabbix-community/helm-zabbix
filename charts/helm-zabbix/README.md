# Helm Chart For Zabbix.

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Version: 3.2.0](https://img.shields.io/badge/Version-3.2.0-informational?style=flat-square)

Zabbix is a mature and effortless enterprise-class open source monitoring solution for network monitoring and application monitoring of millions of metrics.

# Introduction

This Helm chart installs [Zabbix](https://www.zabbix.com) in a Kubernetes cluster.

### Important notes

> **About the Zabbix version supported**
* This helm chart is compatible with non-LTS version of Zabbix, that include important changes and functionalities.
* But by default this helm chart will install the latest LTS version (example: 6.0.x).
See more info in [Zabbix Life Cycle & Release Policy](https://www.zabbix.com/life_cycle_and_release_policy) page
* When you want use a non-LTS version (example: 6.2.x), you have to set this in values.yaml yourself.

> **Break change 3.0.0**
* Will be used Postgresql 14.x and Zabbix 6.x.
* This version removes the possibility to specify database username/password per
  subsection in favor of specifying all of them centrally at one place.
* Also, the names of the values have changed from upper to lowercase.
* It is now possible to start the Zabbix Server pods with replicas of more than 1.
  HA functionality of Zabbix will automatically be enabled and it is made sure that
  the database schema publication will only happen once, and not by all of the Zabbix
  server pods at the same time.
* More info: https://github.com/zabbix-community/helm-zabbix/pull/54

> **Break change 2.0.0**
* Will be used Postgresql 14.x and Zabbix 6.x.
* This version implements a central way of managing database access credentials
using a secret, which then will be respected by all the components
installed by this chart: zabbixserver, zabbixweb and postgresql.
* The secret must contain a number of keys indicating DB host, DB name,
user and password and can direct towards a database installed within
this chart, or an external database.
* The benefit of this is that now the database can respect the values
in the central DB access secret and initialize accordingly.
* Last but not least, the credential secret can be chosen to be
auto-generated (password will be set to a random string) at chart
installation, if postgresql.enabled is set to true. With this, an easy
to use "out-of-the-box" installation with as little customizations as
possible is possible, while still obtaining a good level of security.
* More info: https://github.com/zabbix-community/helm-zabbix/pull/53

> **Break change 1.0.0**
* Will be used Postgresql 14.x and Zabbix 6.x.
* The installation of any component of chart is optional for easy integration with the official
 chart: https://git.zabbix.com/projects/ZT/repos/kubernetes-helm/
* More info: https://github.com/zabbix-community/helm-zabbix/issues/42

# Prerequisites

- Kubernetes cluster 1.10+
- Helm 3.0+
- Kubectl
- PV provisioner support in the underlying infrastructure (optional).

Install requirement ``kubectl`` and ``helm`` following the instructions this
[tutorial](docs/requirements.md).

# Zabbix components

## Zabbix Server

**Zabbix server** is the central process of Zabbix software.

The server performs the polling and trapping of data, it calculates triggers, sends notifications
to users. It is the central component to which Zabbix agents and proxies report data on availability
and integrity of systems. The server can itself remotely check networked services (such as web servers
and mail servers) using simple service checks
[Official documentation](https://www.zabbix.com/documentation/current/en/manual/concepts/server).

Zabbix Server can be operated in a High Availability mode since version 6.0 which is automatically
enabled by this Helm chart when setting the Zabbix server component to run more than 1 replica.
In this HA mode, all Zabbix server instances periodically send a heartbeat to the Database server
(just updating a timestamp in a table) as well as which of the nodes is the "active" one. In case
the active node does not send a heartbeat within a certain time, any of the remaining ones
automatically take over. It is everytime possible to join new nodes to the HA cluster by just
raising the amount of replicas of the Zabbix server.

## Zabbix Agent

> **zabbix-agent2** is supported in this helm chart.

**Zabbix agent** is deployed on a monitoring target to actively monitor local resources and
applications (hard drives, memory, processor statistics etc)
[Official documentation](https://www.zabbix.com/documentation/current/en/manual/concepts/agent).

## Zabbix Web (frontend)

**Zabbix web** interface is a part of Zabbix software. It is used to manage resources under
monitoring and view monitoring statistics
[Official documentation](https://www.zabbix.com/documentation/current/en/manual/web_interface).

## Zabbix Web Service

**Zabbix web service** is a process that is used for communication with external web services
[Official documentation](https://www.zabbix.com/documentation/current/en/manual/concepts/web_service).

## Zabbix Proxy

> This helm chart installs Zabbix proxy with SQLite3 support

**Zabbix proxy** is a process that may collect monitoring data from one or more monitored devices
and send the information to the Zabbix server, essentially working on behalf of the server.
All collected data is buffered locally and then transferred to the **Zabbix server** the
proxy belongs to
[Official documentation](https://www.zabbix.com/documentation/current/en/manual/concepts/proxy).

## PostgreSQL

A database is required for zabbix to work, in this helm chart we're using Postgresql 14.x.

> We use plain postgresql database by default WITHOUT persistence. If you want persistence or
would like to use TimescaleDB instead, check the comments in the ``values.yaml`` file.

## Configure the chart

The items of section [Configuration](#Configuration) can be set via ``--set`` flag during
installation or change the values according to the need of the environment in
``helm-zabbix/values.yaml`` file.

### Configure central database access related settings

All settings referring to how the different components that this Chart installs access the
Zabbix Database (either an external, already existing database or one deployed within
this Helm chart) are being configured centrally under the ``db_access`` section of the
``values.yaml`` file.

By default, this Chart will deploy it's own very simple PostgreSQL database. All settings
relevant to how to access this database will be held in one central unified secret with the
name configured with the ``db_access.unified_secret_name`` setting.

Instead of letting the Chart automatically generate such a secret with a random password
(which will NOT be recreated on upgrade/redeploy), you can supply such a secret yourself.
Use ``db_access.unified_secret_autocreate=false`` in such a case and read the comments
in ``values.yaml`` for how the values inside the secret should be set.

If you want to connect your Zabbix installation to a Postgres database deployed using the
[CrunchyData PGO Operator](https://access.crunchydata.com/documentation/postgres-operator/latest/),
you can use the secret that PGO generates for your DB automatically directly to connect Zabbix to it,
by just referring to its name with the ``db_access.unified_secret_name`` setting to it.

There is also the possibility to set all DB relevant settings directly inside the ``db_access``
section of the ``values.yaml`` file by using the settings noted there
(``db_server_host``, ``postgres_user``, etc). If doing so, you still can use one single secret
to told just and only the database password. If you want to do so, supply the
``db_access.postgres_password_secret`` and ``db_access.postgres_password_secret_key``
settings, accordingly.

## Configure Postgresql database to match with your performance expectations

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
    storage_size: 50Gi
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

### Configure the way how to expose Zabbix service:

- **Ingress**: The ingress controller must be installed in the Kubernetes cluster.
- **IngressRoute**: The custom resource definition if you use the
[Traefik](https://traefik.io/traefik/) ingress controller.
- **Route**: The ingress controller used by Red Hat Openshift, based on HAProxy
- **ClusterIP**: Exposes the service on a cluster-internal IP. Choosing this value makes the
service only reachable from within the cluster.
- **NodePort**: Exposes the service on each Node’s IP at a static port (the NodePort).
You’ll be able to contact the NodePort service, from outside the cluster, by requesting
``NodeIP:NodePort``.
- **LoadBalancer**: Exposes the service externally using a cloud provider’s load balancer.

# Installation

Access a Kubernetes cluster.

Add Helm repo:

```bash
helm repo add zabbix-community https://zabbix-community.github.io/helm-charts
```

Update the list helm chart available for installation (like ``apt-get update``). This is recommend
before install/upgrade a helm chart:

```bash
helm repo update
```

Export default values of chart ``helm-zabbix`` to file ``$HOME/zabbix_values.yaml``:

```bash
helm show values zabbix-community/zabbix > $HOME/zabbix_values.yaml
```

Change the values according to the environment in the file ``$HOME/zabbix_values.yaml``.

See the example of installation in kind in this [tutorial](docs/example/README.md).

Test the installation/upgrade with command:

```bash
helm upgrade --install zabbix zabbix-community/zabbix \
 --dependency-update \
 --create-namespace \
 -f $HOME/zabbix_values.yaml -n monitoring --debug --dry-run
```

Install/upgrade the Zabbix with command:

```bash
helm upgrade --install zabbix zabbix-community/zabbix \
 --dependency-update \
 --create-namespace \
 -f $HOME/zabbix_values.yaml -n monitoring --debug
```

View the pods.

```bash
kubectl get pods -n monitoring
```

# How to access Zabbix

After deploying the chart in your cluster, you can use the following command to access the zabbix
frontend service:

View informations of ``zabbix`` services.

```bash
kubectl describe services zabbix-web -n monitoring
```

Listen on port 8888 locally, forwarding to 80 in the service ``APPLICATION_NAME-zabbix-web``. Example:

```bash
kubectl port-forward service/zabbix-zabbix-web 8888:80 -n monitoring
```

Access Zabbix:

* URL: http://localhost:8888
* Login: **Admin**
* Password: **zabbix**

# Troubleshooting

View the pods.

```bash
kubectl get pods -n monitoring
```

View informations of pods.

```bash
kubectl describe pods/POD_NAME -n monitoring
```

View all containers of pod.

```bash
kubectl get pods POD_NAME -n monitoring -o jsonpath='{.spec.containers[*].name}*'
```

View the logs container of pods.

```bash
kubectl logs -f pods/POD_NAME -c CONTAINER_NAME -n monitoring
```

Access prompt of container.

```bash
kubectl exec -it pods/POD_NAME -c CONTAINER_NAME -n monitoring -- sh
```

View informations of service Zabbix.

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

# License

[Apache License 2.0](/LICENSE)

# Configuration

The following tables lists the configurable parameters of the chart and their default values.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity configurations |
| db_access.db_server_host | string | `"zabbix-postgresql"` | Address of database host - ignored if postgresql.enabled=true |
| db_access.db_server_port | string | `"5432"` | Port of database host - ignored if postgresql.enabled=true |
| db_access.postgres_db | string | `"zabbix"` | Name of database |
| db_access.postgres_password | string | `"zabbix"` | Password of database - ignored if postgres_password_secret is set |
| db_access.postgres_user | string | `"zabbix"` | User of database |
| db_access.unified_secret_autocreate | bool | `true` | automatically create secret if not already present (works only in combination with postgresql.enabled=true) |
| db_access.unified_secret_name | string | `"zabbixdb-pguser-zabbix"` | Name of one secret for unified configuration of DB access |
| db_access.use_unified_secret | bool | `true` | Whether to use the unified db access secret |
| ingress.annotations | object | `{}` | Ingress annotations |
| ingress.enabled | bool | `false` | Enables Ingress |
| ingress.hosts | list | `[{"host":"chart-example.local","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}]` | Ingress hosts |
| ingress.pathType | string | `"Prefix"` | pathType is only for k8s >= 1.1= |
| ingress.tls | list | `[]` | Ingress TLS configuration |
| ingressroute.annotations | object | `{}` | IngressRoute annotations |
| ingressroute.enabled | bool | `false` | Enables Traefik IngressRoute |
| ingressroute.entryPoints | list | `["websecure"]` | Ingressroute entrypoints |
| ingressroute.hostName | string | `"chart-example.local"` | Ingressroute host name |
| nodeSelector | object | `{}` | nodeSelector configurations |
| postgresql.enabled | bool | `true` | Create a database using Postgresql |
| postgresql.extraContainers | list | `[]` | additional containers to start within the postgresql pod |
| postgresql.extraEnv | list | `[]` | Extra environment variables. A list of additional environment variables. |
| postgresql.extraInitContainers | list | `[]` | additional init containers to start within the postgresql pod |
| postgresql.extraPodSpecs | object | `{}` | additional specifications to the postgresql pod |
| postgresql.extraRuntimeParameters | object | `{"max_connections":50}` | Extra Postgresql runtime parameters ("-c" options) |
| postgresql.extraVolumeMounts | list | `[]` | additional volumeMounts to the postgresql container |
| postgresql.extraVolumes | list | `[]` | additional volumes to make available to the postgresql pod |
| postgresql.image.pullPolicy | string | `"IfNotPresent"` | Pull policy of Docker image |
| postgresql.image.pullSecrets | list | `[]` | List of dockerconfig secrets names to use when pulling images |
| postgresql.image.repository | string | `"postgres"` | Postgresql Docker image name: chose one of "postgres" or "timescale/timescaledb" |
| postgresql.image.tag | int | `14` | Tag of Docker image of Postgresql server, chose "14" for postgres or "latest-pg14" for timescaledb |
| postgresql.persistence.enabled | bool | `false` | whether to enable persistent storage for the postgres container or not |
| postgresql.persistence.existing_claim_name | bool | `false` | existing persistent volume claim name to be used to store posgres data |
| postgresql.persistence.storage_size | string | `"5Gi"` | size of the PVC to be automatically generated |
| postgresql.service.annotations | object | `{}` | Annotations for the zabbix-server service |
| postgresql.service.clusterIP | string | `nil` | Cluster IP for Zabbix server |
| postgresql.service.port | int | `5432` | Port of service in Kubernetes cluster |
| postgresql.service.type | string | `"ClusterIP"` | Type of service in Kubernetes cluster |
| route.annotations | object | `{}` | Openshift Route extra annotations |
| route.enabled | bool | `false` | Enables Route object for Openshift |
| route.hostName | string | `"chart-example.local"` | Host Name for the route. Can be left empty |
| route.tls | object | `{"termination":"edge"}` | Openshift Route TLS settings |
| tolerations | list | `[]` | Tolerations configurations |
| zabbix_image_tag | string | `"ubuntu-6.0.8"` | Zabbix components (server, agent, web frontend, ...) image tag to use. This helm chart is compatible with non-LTS version of Zabbix, that include important changes and functionalities. But by default this helm chart will install the latest LTS version (example: 6.0.x). See more info in [Zabbix Life Cycle & Release Policy](https://www.zabbix.com/life_cycle_and_release_policy) page When you want use a non-LTS version (example: 6.2.x), you have to set this yourself. You can change version here or overwrite in each component (example: zabbixserver.image.tag, etc). |
| zabbixagent.ZBX_ACTIVE_ALLOW | bool | `true` | This variable is boolean (true or false) and enables or disables feature of active checks |
| zabbixagent.ZBX_JAVAGATEWAY_ENABLE | bool | `false` | The variable enable communication with Zabbix Java Gateway to collect Java related checks. By default, value is false. |
| zabbixagent.ZBX_PASSIVESERVERS | string | `"127.0.0.1"` | The variable is comma separated list of allowed Zabbix server or proxy hosts for connections to Zabbix agent container. |
| zabbixagent.ZBX_PASSIVE_ALLOW | bool | `true` | This variable is boolean (true or false) and enables or disables feature of passive checks. By default, value is true |
| zabbixagent.ZBX_SERVER_HOST | string | `"127.0.0.1"` | Zabbix server host |
| zabbixagent.ZBX_SERVER_PORT | int | `10051` | Zabbix server port |
| zabbixagent.ZBX_VMWARECACHESIZE | string | `"128M"` | Cache size |
| zabbixagent.enabled | bool | `true` | Enables use of **Zabbix Agent** |
| zabbixagent.extraEnv | list | `[]` | Extra environment variables. A list of additional environment variables. See example: https://github.com/zabbix-community/helm-zabbix/blob/master/docs/example/kind/values.yaml |
| zabbixagent.extraVolumeMounts | list | `[]` | additional volumeMounts to the zabbix agent container |
| zabbixagent.image.pullPolicy | string | `"IfNotPresent"` | Pull policy of Docker image |
| zabbixagent.image.pullSecrets | list | `[]` | List of dockerconfig secrets names to use when pulling images |
| zabbixagent.image.repository | string | `"zabbix/zabbix-agent2"` | Zabbix agent Docker image name. Can use zabbix/zabbix-agent or zabbix/zabbix-agent2 |
| zabbixagent.image.tag | string | `nil` | Zabbix agent Docker image tag, if you want to override zabbix_image_tag |
| zabbixagent.resources | object | `{}` | Requests and limits of pod resources. See: [https://kubernetes.io/docs/concepts/configuration/manage-resources-containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers) |
| zabbixagent.service.annotations | object | `{}` | Annotations for the zabbix-agent service |
| zabbixagent.service.clusterIP | string | `nil` | Cluster IP for Zabbix agent |
| zabbixagent.service.port | int | `10050` | Port to expose service |
| zabbixagent.service.type | string | `"ClusterIP"` | Type of service for Zabbix agent |
| zabbixproxy.ZBX_HOSTNAME | string | `"zabbix-proxy"` | Zabbix proxy hostname Case sensitive hostname |
| zabbixproxy.ZBX_JAVAGATEWAY_ENABLE | bool | `false` | The variable enable communication with Zabbix Java Gateway to collect Java related checks. By default, value is false. |
| zabbixproxy.ZBX_PROXYMODE | int | `0` | The variable allows to switch Zabbix proxy mode. Bu default, value is 0 - active proxy. Allowed values are 0 and 1. |
| zabbixproxy.ZBX_SERVER_HOST | string | `"zabbix-zabbix-server"` | Zabbix server host |
| zabbixproxy.ZBX_SERVER_PORT | int | `10051` | Zabbix server port |
| zabbixproxy.ZBX_VMWARECACHESIZE | string | `"128M"` | Cache size |
| zabbixproxy.enabled | bool | `false` | Enables use of **Zabbix Proxy** |
| zabbixproxy.extraContainers | list | `[]` | additional containers to start within the zabbix proxy pod |
| zabbixproxy.extraEnv | list | `[]` | Extra environment variables. A list of additional environment variables. See example: https://github.com/zabbix-community/helm-zabbix/blob/master/docs/example/kind/values.yaml |
| zabbixproxy.extraInitContainers | list | `[]` | additional init containers to start within the zabbix proxy pod |
| zabbixproxy.extraPodSpecs | object | `{}` | additional specifications to the zabbix proxy pod |
| zabbixproxy.extraVolumeClaimTemplate | list | `[]` | extra volumeClaimTemplate for zabbixproxy statefulset |
| zabbixproxy.extraVolumeMounts | list | `[]` | additional volumeMounts to the zabbix proxy container |
| zabbixproxy.extraVolumes | list | `[]` | additional volumes to make available to the zabbix proxy pod |
| zabbixproxy.image.pullPolicy | string | `"IfNotPresent"` | Pull policy of Docker image |
| zabbixproxy.image.pullSecrets | list | `[]` | List of dockerconfig secrets names to use when pulling images |
| zabbixproxy.image.repository | string | `"zabbix/zabbix-proxy-sqlite3"` | Zabbix proxy Docker image name |
| zabbixproxy.image.tag | string | `nil` | Zabbix proxy Docker image tag, if you want to override zabbix_image_tag |
| zabbixproxy.replicaCount | int | `1` | Number of replicas of ``zabbixproxy`` module |
| zabbixproxy.resources | object | `{}` | Requests and limits of pod resources. See: [https://kubernetes.io/docs/concepts/configuration/manage-resources-containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers) |
| zabbixproxy.service.annotations | object | `{}` | Annotations for the zabbix-proxy service |
| zabbixproxy.service.clusterIP | string | `nil` | Cluster IP for Zabbix proxy |
| zabbixproxy.service.port | int | `10051` | Port to expose service |
| zabbixproxy.service.type | string | `"ClusterIP"` | Type of service for Zabbix proxy |
| zabbixserver.enabled | bool | `true` | Enables use of **Zabbix Server** |
| zabbixserver.extraContainers | list | `[]` | additional containers to start within the zabbix server pod |
| zabbixserver.extraEnv | list | `[]` | Extra environment variables. A list of additional environment variables. See example: https://github.com/zabbix-community/helm-zabbix/blob/master/docs/example/kind/values.yaml |
| zabbixserver.extraInitContainers | list | `[]` | additional init containers to start within the zabbix server pod |
| zabbixserver.extraPodSpecs | object | `{}` | additional specifications to the zabbix server pod |
| zabbixserver.extraVolumeMounts | list | `[]` | additional volumeMounts to the zabbix server container |
| zabbixserver.extraVolumes | list | `[]` | additional volumes to make available to the zabbix server pod |
| zabbixserver.ha_nodes_autoclean | object | `{"delete_older_than_seconds":3600,"enabled":true,"image":{"pullPolicy":"IfNotPresent","pullSecrets":[],"repository":"postgres","tag":"14"},"schedule":"0 1 * * *"}` | automatically clean orphaned ha nodes from ha_nodes db table |
| zabbixserver.hostIP | string | `"0.0.0.0"` | optional set hostIP different from 0.0.0.0 to open port only on this IP |
| zabbixserver.hostPort | bool | `false` | optional set true open a port direct on node where zabbix server runs  |
| zabbixserver.image.pullPolicy | string | `"IfNotPresent"` | Pull policy of Docker image |
| zabbixserver.image.pullSecrets | list | `[]` | List of dockerconfig secrets names to use when pulling images |
| zabbixserver.image.repository | string | `"zabbix/zabbix-server-pgsql"` | Zabbix server Docker image name |
| zabbixserver.image.tag | string | `nil` | Zabbix server Docker image tag, if you want to override zabbix_image_tag |
| zabbixserver.pod_anti_affinity | bool | `true` | set permissive podAntiAffinity to spread replicas over cluster nodes if replicaCount>1 |
| zabbixserver.replicaCount | int | `1` | Number of replicas of ``zabbixserver`` module |
| zabbixserver.resources | object | `{}` | Requests and limits of pod resources. See: [https://kubernetes.io/docs/concepts/configuration/manage-resources-containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers) |
| zabbixserver.service.annotations | object | `{}` | Annotations for the zabbix-server service |
| zabbixserver.service.clusterIP | string | `nil` | Cluster IP for Zabbix server |
| zabbixserver.service.nodePort | int | `31051` | NodePort of service on each node |
| zabbixserver.service.port | int | `10051` | Port of service in Kubernetes cluster |
| zabbixserver.service.type | string | `"ClusterIP"` | Type of service in Kubernetes cluster |
| zabbixweb.enabled | bool | `true` | Enables use of **Zabbix Web** |
| zabbixweb.extraContainers | list | `[]` | additional containers to start within the zabbix web pod |
| zabbixweb.extraEnv | list | `[]` | Extra environment variables. A list of additional environment variables. See example: https://github.com/zabbix-community/helm-zabbix/blob/master/docs/example/kind/values.yaml |
| zabbixweb.extraInitContainers | list | `[]` | additional init containers to start within the zabbix web pod |
| zabbixweb.extraPodSpecs | object | `{}` | additional specifications to the zabbix web pod |
| zabbixweb.extraVolumeMounts | list | `[]` | additional volumeMounts to the zabbix web container |
| zabbixweb.extraVolumes | list | `[]` | additional volumes to make available to the zabbix web pod |
| zabbixweb.image.pullPolicy | string | `"IfNotPresent"` | Pull policy of Docker image |
| zabbixweb.image.pullSecrets | list | `[]` | List of dockerconfig secrets names to use when pulling images |
| zabbixweb.image.repository | string | `"zabbix/zabbix-web-nginx-pgsql"` | Zabbix web Docker image name |
| zabbixweb.image.tag | string | `nil` | Zabbix web Docker image tag, if you want to override zabbix_image_tag |
| zabbixweb.livenessProbe.failureThreshold | int | `6` | When a probe fails, Kubernetes will try failureThreshold times before giving up. Giving up in case of liveness probe means restarting the container. In case of readiness probe the Pod will be marked Unready |
| zabbixweb.livenessProbe.initialDelaySeconds | int | `30` | Number of seconds after the container has started before liveness |
| zabbixweb.livenessProbe.path | string | `"/"` | Path of health check of application |
| zabbixweb.livenessProbe.periodSeconds | int | `10` | Specifies that the kubelet should perform a liveness probe every N seconds |
| zabbixweb.livenessProbe.successThreshold | int | `1` | Minimum consecutive successes for the probe to be considered successful after having failed |
| zabbixweb.livenessProbe.timeoutSeconds | int | `5` | Number of seconds after which the probe times out |
| zabbixweb.pod_anti_affinity | bool | `true` | set permissive podAntiAffinity to spread replicas over cluster nodes if replicaCount>1 |
| zabbixweb.readinessProbe.failureThreshold | int | `6` | When a probe fails, Kubernetes will try failureThreshold times before giving up. Giving up in case of liveness probe means restarting the container. In case of readiness probe the Pod will be marked Unready |
| zabbixweb.readinessProbe.initialDelaySeconds | int | `5` | Number of seconds after the container has started before readiness |
| zabbixweb.readinessProbe.path | string | `"/"` | Path of health check of application |
| zabbixweb.readinessProbe.periodSeconds | int | `10` | Specifies that the kubelet should perform a readiness probe every N seconds |
| zabbixweb.readinessProbe.successThreshold | int | `1` | Minimum consecutive successes for the probe to be considered successful after having failed |
| zabbixweb.readinessProbe.timeoutSeconds | int | `5` | Number of seconds after which the probe times out |
| zabbixweb.replicaCount | int | `1` | Number of replicas of ``zabbixweb`` module |
| zabbixweb.resources | object | `{}` | Requests and limits of pod resources. See: [https://kubernetes.io/docs/concepts/configuration/manage-resources-containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers) |
| zabbixweb.service | object | `{"annotations":{},"clusterIP":null,"port":80,"type":"ClusterIP"}` | Certificate containing certificates for SAML configuration saml_certs_secret_name: zabbix-web-samlcerts |
| zabbixweb.service.annotations | object | `{}` | Annotations for the zabbix-web service |
| zabbixweb.service.clusterIP | string | `nil` | Cluster IP for Zabbix web |
| zabbixweb.service.port | int | `80` | Port to expose service |
| zabbixweb.service.type | string | `"ClusterIP"` | Type of service for Zabbix web |
| zabbixwebservice.enabled | bool | `true` | Enables use of **Zabbix Web Service** |
| zabbixwebservice.extraContainers | list | `[]` | additional containers to start within the zabbix webservice pod |
| zabbixwebservice.extraEnv | list | `[]` | Extra environment variables. A list of additional environment variables. See example: https://github.com/zabbix-community/helm-zabbix/blob/master/docs/example/kind/values.yaml |
| zabbixwebservice.extraInitContainers | list | `[]` | additional init containers to start within the zabbix webservice pod |
| zabbixwebservice.extraPodSpecs | object | `{}` | additional specifications to the zabbix webservice pod |
| zabbixwebservice.extraVolumeMounts | list | `[]` | additional volumeMounts to the zabbix webservice container |
| zabbixwebservice.extraVolumes | list | `[]` | additional volumes to make available to the zabbix webservice pod |
| zabbixwebservice.image.pullPolicy | string | `"IfNotPresent"` | Pull policy of Docker image |
| zabbixwebservice.image.pullSecrets | list | `[]` | List of dockerconfig secrets names to use when pulling images |
| zabbixwebservice.image.repository | string | `"zabbix/zabbix-web-service"` | Zabbix webservice Docker image name |
| zabbixwebservice.image.tag | string | `nil` | Zabbix webservice Docker image tag, if you want to override zabbix_image_tag |
| zabbixwebservice.pod_anti_affinity | bool | `true` | set permissive podAntiAffinity to spread replicas over cluster nodes if replicaCount>1 |
| zabbixwebservice.replicaCount | int | `1` | Number of replicas of ``zabbixwebservice`` module |
| zabbixwebservice.resources | object | `{}` | Requests and limits of pod resources. See: [https://kubernetes.io/docs/concepts/configuration/manage-resources-containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers) |
| zabbixwebservice.service | object | `{"annotations":{},"clusterIP":null,"port":10053,"type":"ClusterIP"}` | set the IgnoreURLCertErrors configuration setting of Zabbix web service ignore_url_cert_errors=1 |
| zabbixwebservice.service.annotations | object | `{}` | Annotations for the zabbix-web service |
| zabbixwebservice.service.clusterIP | string | `nil` | Cluster IP for Zabbix web |
| zabbixwebservice.service.port | int | `10053` | Port to expose service |
| zabbixwebservice.service.type | string | `"ClusterIP"` | Type of service for Zabbix web |
