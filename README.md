# Helm Chart For Zabbix.

[![CircleCI](https://circleci.com/gh/cetic/helm-zabbix.svg?style=svg)](https://circleci.com/gh/cetic/helm-zabbix/tree/master) [![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![version](https://img.shields.io/github/tag/cetic/helm-zabbix.svg?label=release) ![Version: 0.3.1](https://img.shields.io/badge/Version-0.3.1-informational?style=flat-square)

Zabbix is a mature and effortless enterprise-class open source monitoring solution for network monitoring and application monitoring of millions of metrics.

# Introduction

This [Helm](https://github.com/cetic/helm-zabbix) chart installs [Zabbix](https://www.zabbix.com) in a Kubernetes cluster.

### Important note

>**This helm chart is still under developpement**

# Prerequisites

- Kubernetes cluster 1.10+
- Helm 3.0+
- PV provisioner support in the underlying infrastructure.

# Zabbix components

## Zabbix Server

**Zabbix server** is the central process of Zabbix software.

The server performs the polling and trapping of data, it calculates triggers, sends notifications to users. It is the central component to which Zabbix agents and proxies report data on availability and integrity of systems. The server can itself remotely check networked services (such as web servers and mail servers) using simple service checks.

## Zabbix Agent

**Zabbix agent** is deployed on a monitoring target to actively monitor local resources and applications (hard drives, memory, processor statistics etc).

## Zabbix Web (frontend)

**Zabbix web** interface is a part of Zabbix software. It is used to manage resources under monitoring and view monitoring statistics.

## Zabbix Proxy 

> **Zabbix proxy** is not functional in this helm chart, yet.

**Zabbix proxy** is a process that may collect monitoring data from one or more monitored devices and send the information to the Zabbix server, essentially working on behalf of the server. All collected data is buffered locally and then transferred to the **Zabbix server** the proxy belongs to.

## PostgreSQL

A database is required for zabbix to work, in this helm chart we're using Postgresql.

> to use a different database make sure you use the right docker image, the docker image we're using here is for postgresql only.

## Configure the chart

The items of section [Configuration](#Configuration) can be set via ``--set`` flag during installation or change the values according to the need of the environment in ``helm-zabbix/values.yaml`` file.

### Configure the way how to expose Zabbix service:

- **Ingress**: The ingress controller must be installed in the Kubernetes cluster.
- **ClusterIP**: Exposes the service on a cluster-internal IP. Choosing this value makes the service only reachable from within the cluster.
- **NodePort**: Exposes the service on each Node’s IP at a static port (the NodePort). You’ll be able to contact the NodePort service, from outside the cluster, by requesting ``NodeIP:NodePort``.
- **LoadBalancer**: Exposes the service externally using a cloud provider’s load balancer.

# Installation

Install requirement ``kubectl`` and ``helm`` following the instructions this [tutorial](docs/requirements.md).

Access a Kubernetes cluster.

Create namespace ``monitoring`` in Kubernetes cluster.

```bash
kubectl create namespace monitoring
```

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

Install the Zabbix helm chart with a release name `my-release`:

```bash
helm install zabbix cetic/zabbix --dependency-update -f $HOME/zabbix_values.yaml -n monitoring
```

View the pods.

```bash
kubectl get pods -n monitoring
```

View the logs container of pods.

```bash
kubectl logs -f pods/POD_NAME -n monitoring
```

See the example of installation in minikube in this [tutorial](docs/example/README.md).

See section [Basic Commands of Helm 3](docs/basics-helmv3.md) for more information about commands of helm.

# Uninstallation

To uninstall/delete the ``zabbix`` deployment:

```bash
helm delete zabbix -n monitoring
```

# How to access Zabbix

After deploying the chart in your cluster, you can use the following command to access the zabbix frontend service: 

View informations of ``zabbix`` services.

```bash
kubectl describe services zabbix-web -n monitoring
```

Listen on port 8888 locally, forwarding to 80 in the service ``zabbix-web``.

```bash
kubectl port-forward service/zabbix-web 8888:80 -n monitoring
```

Access Zabbix in http://localhost:8888. Login ``Admin`` and password ``zabbix``.

# License

[Apache License 2.0](/LICENSE)

# Configuration

The following tables lists the configurable parameters of the chart and their default values.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity configurations |
| ingress.annotations | object | `{}` | Ingress annotations |
| ingress.enabled | bool | `false` | Enables Ingress |
| ingress.hosts | list | `[{"host":null,"paths":[]}]` | Ingress hosts |
| ingress.tls | list | `[]` | Ingress TLS configuration |
| livenessProbe.failureThreshold | int | `6` | When a probe fails, Kubernetes will try failureThreshold times before giving up. Giving up in case of liveness probe means restarting the container. In case of readiness probe the Pod will be marked Unready |
| livenessProbe.initialDelaySeconds | int | `30` | Number of seconds after the container has started before liveness |
| livenessProbe.path | string | `"/"` | Path of health check of application |
| livenessProbe.periodSeconds | int | `10` | Specifies that the kubelet should perform a liveness probe every N seconds |
| livenessProbe.successThreshold | int | `1` | Minimum consecutive successes for the probe to be considered successful after having failed |
| livenessProbe.timeoutSeconds | int | `5` | Number of seconds after which the probe times out |
| nodeSelector | object | `{}` | nodeSelector configurations |
| postgresql.enabled | bool | `true` | Create a database using Postgresql |
| postgresql.postgresqlDatabase | string | `"zabbix"` | Name of database |
| postgresql.postgresqlPassword | string | `"zabbix_pwd"` | Password of database |
| postgresql.postgresqlPostgresPassword | string | `"zabbix_pwd"` | Password of``postgres`` user in Postgresql |
| postgresql.postgresqlUsername | string | `"zabbix"` | User of database |
| readinessProbe.failureThreshold | int | `6` | When a probe fails, Kubernetes will try failureThreshold times before giving up. Giving up in case of liveness probe means restarting the container. In case of readiness probe the Pod will be marked Unready |
| readinessProbe.initialDelaySeconds | int | `5` | Number of seconds after the container has started before readiness |
| readinessProbe.path | string | `"/"` | Path of health check of application |
| readinessProbe.periodSeconds | int | `10` | Specifies that the kubelet should perform a readiness probe every N seconds |
| readinessProbe.successThreshold | int | `1` | Minimum consecutive successes for the probe to be considered successful after having failed |
| readinessProbe.timeoutSeconds | int | `5` | Number of seconds after which the probe times out |
| resources | object | `{}` | We usually recommend not to specify default resources and to leave this as a conscious choice for the user. This also increases chances charts run on environments with little resources, such as Minikube. If you do want to specify resources, uncomment the following lines, adjust them as necessary, and remove the curly braces after 'resources:'. |
| tolerations | list | `[]` | Tolerations configurations |
| zabbixServer.DB_SERVER_HOST | string | `"zabbix-postgresql"` | Address of database host |
| zabbixServer.POSTGRES_DB | string | `"zabbix"` | Name of database |
| zabbixServer.POSTGRES_PASSWORD | string | `"zabbix_pwd"` | Password of database |
| zabbixServer.POSTGRES_USER | string | `"zabbix"` | User of database |
| zabbixServer.hostIP | string | `"0.0.0.0"` | optional set hostIP different from 0.0.0.0 to open port only on this IP |
| zabbixServer.hostPort | bool | `false` | optional set true open a port direct on node where zabbix server runs  |
| zabbixServer.image.pullPolicy | string | `"IfNotPresent"` | Pull policy of Docker image |
| zabbixServer.image.pullSecrets | list | `[]` | List of dockerconfig secrets names to use when pulling images |
| zabbixServer.image.repository | string | `"zabbix/zabbix-server-pgsql"` | Zabbix server Docker image name |
| zabbixServer.image.tag | string | `"ubuntu-5.2.0"` | Tag of Docker image of Zabbix server |
| zabbixServer.replicaCount | int | `1` | Number of replicas of ``zabbixServer`` module |
| zabbixServer.service.port | int | `10051` | Port of service in Kubernetes cluster |
| zabbixServer.service.type | string | `"ClusterIP"` | Type of service in Kubernetes cluster |
| zabbixagent.ZBX_ACTIVE_ALLOW | bool | `true` | This variable is boolean (true or false) and enables or disables feature of active checks |
| zabbixagent.ZBX_HOSTNAME | string | `"zabbix-agent"` | Zabbix agent hostname Case sensitive hostname |
| zabbixagent.ZBX_JAVAGATEWAY_ENABLE | bool | `false` | The variable enable communication with Zabbix Java Gateway to collect Java related checks. By default, value is false. |
| zabbixagent.ZBX_PASSIVESERVERS | string | `"127.0.0.1"` | The variable is comma separated list of allowed Zabbix server or proxy hosts for connections to Zabbix agent container. |
| zabbixagent.ZBX_PASSIVE_ALLOW | bool | `true` | This variable is boolean (true or false) and enables or disables feature of passive checks. By default, value is true |
| zabbixagent.ZBX_SERVER_HOST | string | `"127.0.0.1"` | Zabbix server host |
| zabbixagent.ZBX_SERVER_PORT | int | `10051` | Zabbix server port |
| zabbixagent.ZBX_VMWARECACHESIZE | string | `"128M"` | Cache size |
| zabbixagent.enabled | bool | `true` | Enables use of Zabbix agent |
| zabbixagent.image.pullPolicy | string | `"IfNotPresent"` | Pull policy of Docker image |
| zabbixagent.image.pullSecrets | list | `[]` | List of dockerconfig secrets names to use when pulling images |
| zabbixagent.image.repository | string | `"zabbix/zabbix-agent"` | Zabbix agent Docker image name |
| zabbixagent.image.tag | string | `"ubuntu-5.2.0"` | Tag of Docker image of Zabbix agent |
| zabbixagent.service.port | int | `10050` | Port to expose service |
| zabbixagent.service.targetPort | int | `10050` | Port of application pod |
| zabbixagent.service.type | string | `"ClusterIP"` | Type of service for Zabbix agent |
| zabbixproxy.DB_SERVER_HOST | string | `"maria-mariadb"` | Address of database host |
| zabbixproxy.DB_SERVER_PORT | int | `3306` | Port of database |
| zabbixproxy.MYSQL_DATABASE | string | `"my_database"` | default to zabbix ( to be precised later) |
| zabbixproxy.MYSQL_PASSWORD | string | `"password1"` | Password of database |
| zabbixproxy.MYSQL_USER | string | `"admin"` | User of database |
| zabbixproxy.ZBX_HOSTNAME | string | `"zabbix-proxy"` | Zabbix proxy hostname Case sensitive hostname |
| zabbixproxy.ZBX_JAVAGATEWAY_ENABLE | bool | `false` | The variable enable communication with Zabbix Java Gateway to collect Java related checks. By default, value is false. |
| zabbixproxy.ZBX_PROXYMODE | int | `0` | The variable allows to switch Zabbix proxy mode. Bu default, value is 0 - active proxy. Allowed values are 0 and 1. |
| zabbixproxy.ZBX_SERVER_HOST | string | `"zabbix-server"` | Zabbix server host |
| zabbixproxy.ZBX_SERVER_PORT | int | `10051` | Zabbix server port |
| zabbixproxy.ZBX_VMWARECACHESIZE | string | `"128M"` | Cache size |
| zabbixproxy.enabled | bool | `false` | Enables use of **Zabbix proxy** |
| zabbixproxy.image.pullPolicy | string | `"IfNotPresent"` | Pull policy of Docker image |
| zabbixproxy.image.pullSecrets | list | `[]` | List of dockerconfig secrets names to use when pulling images |
| zabbixproxy.image.repository | string | `"zabbix/zabbix-proxy-mysql"` | Zabbix proxy Docker image name |
| zabbixproxy.image.tag | string | `"ubuntu-5.2.0"` | Tag of Docker image of Zabbix proxy |
| zabbixproxy.service.port | int | `10051` | Port to expose service |
| zabbixproxy.service.targetPort | int | `10051` | Port of application pod |
| zabbixproxy.service.type | string | `"ClusterIP"` | Type of service for Zabbix proxy |
| zabbixweb.DB_SERVER_HOST | string | `"zabbix-postgresql"` | Address of database host |
| zabbixweb.DB_SERVER_PORT | int | `5432` | Port of database |
| zabbixweb.POSTGRES_DB | string | `"zabbix"` | Name of database |
| zabbixweb.POSTGRES_PASSWORD | string | `"zabbix_pwd"` | Password of database |
| zabbixweb.POSTGRES_USER | string | `"zabbix"` | User of database |
| zabbixweb.ZBX_SERVER_HOST | string | `"zabbix-server"` | Zabbix server host |
| zabbixweb.ZBX_SERVER_PORT | int | `10051` | Zabbix server port |
| zabbixweb.enabled | bool | `true` | Enables use of Zabbix web |
| zabbixweb.image.pullPolicy | string | `"IfNotPresent"` | Pull policy of Docker image |
| zabbixweb.image.pullSecrets | list | `[]` | List of dockerconfig secrets names to use when pulling images |
| zabbixweb.image.repository | string | `"zabbix/zabbix-web-apache-pgsql"` | Zabbix web Docker image name |
| zabbixweb.image.tag | string | `"ubuntu-5.2.0"` | Tag of Docker image of Zabbix web |
| zabbixweb.service.port | int | `80` | Port to expose service |
| zabbixweb.service.targetPort | int | `8080` | Port of application pod |
| zabbixweb.service.type | string | `"NodePort"` | Type of service for Zabbix web |
