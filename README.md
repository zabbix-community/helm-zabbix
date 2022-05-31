# Helm Chart For Zabbix.

[![CircleCI](https://circleci.com/gh/cetic/helm-zabbix.svg?style=svg)](https://circleci.com/gh/cetic/helm-zabbix/tree/master) [![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![version](https://img.shields.io/github/tag/cetic/helm-zabbix.svg?label=release) ![Version: 3.0.0](https://img.shields.io/badge/Version-3.0.0-informational?style=flat-square)

Zabbix is a mature and effortless enterprise-class open source monitoring solution for network monitoring and application monitoring of millions of metrics.

# Introduction

This Helm chart installs [Zabbix](https://www.zabbix.com) in a Kubernetes cluster.

### Important notes

> **This helm chart is still under development**

> **Break change 3.0.0**
* This version removes the possibility to specify database username/password per
  subsection in favor of specifying all of them centrally at one place.
* Also, the names of the values have changed from upper to lowercase.

> **Break change 2.0.0**
* The version 2.0.0 has a break change.
* Will be used Postgresql 14.x and Zabbix 6.0.4.
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
* More info: https://github.com/cetic/helm-zabbix/pull/53

> **Break change 1.0.0**
* The version 1.0.0 has a break change.
* Will be used Postgresql 14.x and Zabbix 6.0.0.
* The installation of any component of chart is optional for easy integration with the official chart: https://git.zabbix.com/projects/ZT/repos/kubernetes-helm/
* More info: https://github.com/cetic/helm-zabbix/issues/42

# Prerequisites

- Kubernetes cluster 1.10+
- Helm 3.0+
- Kubectl
- PV provisioner support in the underlying infrastructure.

Install requirement ``kubectl`` and ``helm`` following the instructions this [tutorial](docs/requirements.md).

# Zabbix components

## Zabbix Server

**Zabbix server** is the central process of Zabbix software.

The server performs the polling and trapping of data, it calculates triggers, sends notifications to users. It is the central component to which Zabbix agents and proxies report data on availability and integrity of systems. The server can itself remotely check networked services (such as web servers and mail servers) using simple service checks.

## Zabbix Agent

> **zabbix-agent2** is supported in this helm chart.

**Zabbix agent** is deployed on a monitoring target to actively monitor local resources and applications (hard drives, memory, processor statistics etc).

## Zabbix Web (frontend)

**Zabbix web** interface is a part of Zabbix software. It is used to manage resources under monitoring and view monitoring statistics.

## Zabbix Proxy

> This helm chart installs Zabbix proxy with SQLite3 support

**Zabbix proxy** is a process that may collect monitoring data from one or more monitored devices and send the information to the Zabbix server, essentially working on behalf of the server. All collected data is buffered locally and then transferred to the **Zabbix server** the proxy belongs to.

## PostgreSQL

A database is required for zabbix to work, in this helm chart we're using Postgresql 14.x.

> To use a different database make sure you use the right docker image, the docker image we're using here is for postgresql only.

## Configure the chart

The items of section [Configuration](#Configuration) can be set via ``--set`` flag during installation or change the values according to the need of the environment in ``helm-zabbix/values.yaml`` file.

### Configure the way how to expose Zabbix service:

- **Ingress**: The ingress controller must be installed in the Kubernetes cluster.
- **ClusterIP**: Exposes the service on a cluster-internal IP. Choosing this value makes the service only reachable from within the cluster.
- **NodePort**: Exposes the service on each Node’s IP at a static port (the NodePort). You’ll be able to contact the NodePort service, from outside the cluster, by requesting ``NodeIP:NodePort``.
- **LoadBalancer**: Exposes the service externally using a cloud provider’s load balancer.

# Installation

Access a Kubernetes cluster.

Add Helm repo:

```bash
helm repo add cetic https://cetic.github.io/helm-charts
```

Update the list helm chart available for installation (like ``apt-get update``). This is recommend before install/upgrade a helm chart:

```bash
helm repo update
```

Export default values of chart ``helm-zabbix`` to file ``$HOME/zabbix_values.yaml``:

```bash
helm show values cetic/zabbix > $HOME/zabbix_values.yaml
```

Change the values according to the environment in the file ``$HOME/zabbix_values.yaml``.

See the example of installation in kind in this [tutorial](docs/example/README.md).

Test the installation/upgrade with command:

```bash
helm upgrade --install zabbix cetic/zabbix \
 --dependency-update \
 --create-namespace \
 -f $HOME/zabbix_values.yaml -n monitoring --debug --dry-run
```

Install/upgrade the Zabbix with command:

```bash
helm upgrade --install zabbix cetic/zabbix \
 --dependency-update \
 --create-namespace \
 -f $HOME/zabbix_values.yaml -n monitoring --debug
```

View the pods.

```bash
kubectl get pods -n monitoring
```

# How to access Zabbix

After deploying the chart in your cluster, you can use the following command to access the zabbix frontend service:

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
| ingress.extraLabels | object | `{}` | Ingress extra labels |
| ingress.hosts | list | `[{"host":"chart-example.local","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}]` | Ingress hosts |
| ingress.pathType | string | `"Prefix"` | pathType is only for k8s >= 1.1= |
| ingress.tls | list | `[]` | Ingress TLS configuration |
| ingressroute.annotations | object | `{}` | IngressRoute annotations |
| ingressroute.enabled | bool | `false` | Enables Traefik IngressRoute |
| ingressroute.entryPoints | list | `["websecure"]` | Ingressroute entrypoints |
| ingressroute.extraLabels | object | `{}` | Ingressroute extra labels |
| ingressroute.hostName | string | `"chart-example.local"` | Ingressroute host name |
| nodeSelector | object | `{}` | nodeSelector configurations |
| postgresql.enabled | bool | `true` | Create a database using Postgresql |
| postgresql.extraEnv | list | `[]` | Extra environment variables. A list of additional environment variables. |
| postgresql.image.pullPolicy | string | `"IfNotPresent"` | Pull policy of Docker image |
| postgresql.image.pullSecrets | list | `[]` | List of dockerconfig secrets names to use when pulling images |
| postgresql.image.repository | string | `"postgres"` | Postgresql Docker image name: chose one of "postgres" or "timescale/timescaledb" |
| postgresql.image.tag | int | `14` | Tag of Docker image of Postgresql server, chose "14" for postgres or "latest-pg14" for timescaledb |
| postgresql.max_connections | int | `50` |  |
| postgresql.persistence.enabled | bool | `false` | whether to enable persistent storage for the postgres container or not |
| postgresql.persistence.existing_claim_name | bool | `false` | existing persistent volume claim name to be used to store posgres data |
| postgresql.persistence.storage_size | string | `"5Gi"` | size of the PVC to be automatically generated |
| postgresql.service.annotations | object | `{}` | Annotations for the zabbix-server service |
| postgresql.service.clusterIP | string | `nil` | Cluster IP for Zabbix server |
| postgresql.service.port | int | `5432` | Port of service in Kubernetes cluster |
| postgresql.service.type | string | `"ClusterIP"` | Type of service in Kubernetes cluster |
| tolerations | list | `[]` | Tolerations configurations |
| zabbix_image_tag | string | `"ubuntu-6.0.5"` | zabbix components (server, agent, web frontend, ...) image tag to use. Overwritten by zabbixserver.image.tag etc. |
| zabbixagent.ZBX_ACTIVE_ALLOW | bool | `true` | This variable is boolean (true or false) and enables or disables feature of active checks |
| zabbixagent.ZBX_JAVAGATEWAY_ENABLE | bool | `false` | The variable enable communication with Zabbix Java Gateway to collect Java related checks. By default, value is false. |
| zabbixagent.ZBX_PASSIVESERVERS | string | `"127.0.0.1"` | The variable is comma separated list of allowed Zabbix server or proxy hosts for connections to Zabbix agent container. |
| zabbixagent.ZBX_PASSIVE_ALLOW | bool | `true` | This variable is boolean (true or false) and enables or disables feature of passive checks. By default, value is true |
| zabbixagent.ZBX_SERVER_HOST | string | `"127.0.0.1"` | Zabbix server host |
| zabbixagent.ZBX_SERVER_PORT | int | `10051` | Zabbix server port |
| zabbixagent.ZBX_VMWARECACHESIZE | string | `"128M"` | Cache size |
| zabbixagent.enabled | bool | `true` | Enables use of **Zabbix Agent** |
| zabbixagent.extraEnv | list | `[]` | Extra environment variables. A list of additional environment variables. See example: https://github.com/cetic/helm-zabbix/blob/master/docs/example/kind/values.yaml |
| zabbixagent.image.pullPolicy | string | `"IfNotPresent"` | Pull policy of Docker image |
| zabbixagent.image.pullSecrets | list | `[]` | List of dockerconfig secrets names to use when pulling images |
| zabbixagent.image.repository | string | `"zabbix/zabbix-agent2"` | Zabbix agent Docker image name. Can use zabbix/zabbix-agent or zabbix/zabbix-agent2 |
| zabbixagent.resources | object | `{}` |  |
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
| zabbixproxy.extraEnv | list | `[]` | Extra environment variables. A list of additional environment variables. See example: https://github.com/cetic/helm-zabbix/blob/master/docs/example/kind/values.yaml |
| zabbixproxy.image.pullPolicy | string | `"IfNotPresent"` | Pull policy of Docker image |
| zabbixproxy.image.pullSecrets | list | `[]` | List of dockerconfig secrets names to use when pulling images |
| zabbixproxy.image.repository | string | `"zabbix/zabbix-proxy-sqlite3"` | Zabbix proxy Docker image name |
| zabbixproxy.replicaCount | int | `1` | Number of replicas of ``zabbixproxy`` module |
| zabbixproxy.resources | object | `{}` |  |
| zabbixproxy.service.annotations | object | `{}` | Annotations for the zabbix-proxy service |
| zabbixproxy.service.clusterIP | string | `nil` | Cluster IP for Zabbix proxy |
| zabbixproxy.service.port | int | `10051` | Port to expose service |
| zabbixproxy.service.type | string | `"ClusterIP"` | Type of service for Zabbix proxy |
| zabbixserver.enabled | bool | `true` | Enables use of **Zabbix Server** |
| zabbixserver.extraEnv | list | `[]` | Extra environment variables. A list of additional environment variables. See example: https://github.com/cetic/helm-zabbix/blob/master/docs/example/kind/values.yaml |
| zabbixserver.ha_nodes_autoclean | object | `{"delete_older_than_seconds":3600,"enabled":true,"image":{"pullPolicy":"IfNotPresent","pullSecrets":[],"repository":"postgres","tag":"14"},"schedule":"0 1 * * *"}` | automatically clean orphaned ha nodes from ha_nodes db table |
| zabbixserver.hostIP | string | `"0.0.0.0"` | optional set hostIP different from 0.0.0.0 to open port only on this IP |
| zabbixserver.hostPort | bool | `false` | optional set true open a port direct on node where zabbix server runs  |
| zabbixserver.image.pullPolicy | string | `"IfNotPresent"` | Pull policy of Docker image |
| zabbixserver.image.pullSecrets | list | `[]` | List of dockerconfig secrets names to use when pulling images |
| zabbixserver.image.repository | string | `"zabbix/zabbix-server-pgsql"` | Zabbix server Docker image name |
| zabbixserver.pod_anti_affinity | bool | `true` | set permissive podAntiAffinity to spread replicas over cluster nodes if replicaCount>1 |
| zabbixserver.replicaCount | int | `1` | Number of replicas of ``zabbixserver`` module |
| zabbixserver.resources | object | `{}` |  |
| zabbixserver.service.annotations | object | `{}` | Annotations for the zabbix-server service |
| zabbixserver.service.clusterIP | string | `nil` | Cluster IP for Zabbix server |
| zabbixserver.service.nodePort | int | `31051` | NodePort of service on each node |
| zabbixserver.service.port | int | `10051` | Port of service in Kubernetes cluster |
| zabbixserver.service.type | string | `"ClusterIP"` | Type of service in Kubernetes cluster |
| zabbixweb.enabled | bool | `true` | Enables use of **Zabbix Web** |
| zabbixweb.extraEnv | list | `[]` | Extra environment variables. A list of additional environment variables. See example: https://github.com/cetic/helm-zabbix/blob/master/docs/example/kind/values.yaml |
| zabbixweb.image.pullPolicy | string | `"IfNotPresent"` | Pull policy of Docker image |
| zabbixweb.image.pullSecrets | list | `[]` | List of dockerconfig secrets names to use when pulling images |
| zabbixweb.image.repository | string | `"zabbix/zabbix-web-nginx-pgsql"` | Zabbix web Docker image name |
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
| zabbixweb.replicaCount | int | `1` |  |
| zabbixweb.resources | object | `{}` |  |
| zabbixweb.service | object | `{"annotations":{},"clusterIP":null,"port":80,"type":"ClusterIP"}` | Certificate containing certificates for SAML configuration saml_certs_secret_name: zabbix-web-samlcerts |
| zabbixweb.service.annotations | object | `{}` | Annotations for the zabbix-web service |
| zabbixweb.service.clusterIP | string | `nil` | Cluster IP for Zabbix web |
| zabbixweb.service.port | int | `80` | Port to expose service |
| zabbixweb.service.type | string | `"ClusterIP"` | Type of service for Zabbix web |
| zabbixwebservice.enabled | bool | `true` | Enables use of **Zabbix Web Service** |
| zabbixwebservice.extraEnv | list | `[]` | Extra environment variables. A list of additional environment variables. See example: https://github.com/cetic/helm-zabbix/blob/master/docs/example/kind/values.yaml |
| zabbixwebservice.image.pullPolicy | string | `"IfNotPresent"` | Pull policy of Docker image |
| zabbixwebservice.image.pullSecrets | list | `[]` | List of dockerconfig secrets names to use when pulling images |
| zabbixwebservice.image.repository | string | `"zabbix/zabbix-web-service"` | Zabbix web Docker image name |
| zabbixwebservice.pod_anti_affinity | bool | `true` | set permissive podAntiAffinity to spread replicas over cluster nodes if replicaCount>1 |
| zabbixwebservice.replicaCount | int | `1` |  |
| zabbixwebservice.resources | object | `{}` |  |
| zabbixwebservice.service | object | `{"annotations":{},"clusterIP":null,"port":10053,"type":"ClusterIP"}` | set the IgnoreURLCertErrors configuration setting of Zabbix web service ignore_url_cert_errors=1 |
| zabbixwebservice.service.annotations | object | `{}` | Annotations for the zabbix-web service |
| zabbixwebservice.service.clusterIP | string | `nil` | Cluster IP for Zabbix web |
| zabbixwebservice.service.port | int | `10053` | Port to expose service |
| zabbixwebservice.service.type | string | `"ClusterIP"` | Type of service for Zabbix web |
