Helm Chart For Zabbix.
=======

[![CircleCI](https://circleci.com/gh/cetic/helm-zabbix.svg?style=svg)](https://circleci.com/gh/cetic/helm-zabbix/tree/master) [![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![version](https://img.shields.io/github/tag/cetic/helm-zabbix.svg?label=release)

## Introduction

This [Helm](https://github.com/cetic/helm-zabbix) chart installs [Zabbix](https://www.zabbix.com) in a Kubernetes cluster.

### Important note

>**This helm chart is still under developpement and it still lacks some functionalities such as the zabbix-proxy ( it doesn't work for now ).**

## Prerequisites

- Kubernetes cluster 1.10+
- Helm 3.0+
- PV provisioner support in the underlying infrastructure.

## Zabbix components

### Zabbix Server

Zabbix server is the central process of Zabbix software.

The server performs the polling and trapping of data, it calculates triggers, sends notifications to users. It is the central component to which Zabbix agents and proxies report data on availability and integrity of systems. The server can itself remotely check networked services (such as web servers and mail servers) using simple service checks.

### Zabbix Agent

Zabbix agent is deployed on a monitoring target to actively monitor local resources and applications (hard drives, memory, processor statistics etc).

### Zabbix Web ( frontend )

Zabbix web interface is a part of Zabbix software. It is used to manage resources under monitoring and view monitoring statistics.

### Zabbix Proxy 
> Zabbix proxy is not functional in this helm chart, yet.

Zabbix proxy is a process that may collect monitoring data from one or more monitored devices and send the information to the Zabbix server, essentially working on behalf of the server. All collected data is buffered locally and then transferred to the Zabbix server the proxy belongs to.

### PostgreSQL

A database is required for zabbix to work, in this helm chart we're using Postgresql.
> to use a different databse make sure you use the right docker image, the docker image we're using here is for postgresql only.


## Installation

### Add Helm repository

```bash
helm repo add cetic https://cetic.github.io/helm-charts
helm repo update
```

### Configure the chart

The following items can be set via `--set` flag during installation or configured by editing the `values.yaml` directly (you need to download the chart first).


#### Configure the way how to expose Zabbix service:

- **Ingress**: The ingress controller must be installed in the Kubernetes cluster.
- **ClusterIP**: Exposes the service on a cluster-internal IP. Choosing this value makes the service only reachable from within the cluster.
- **NodePort**: Exposes the service on each Node’s IP at a static port (the NodePort). You’ll be able to contact the NodePort service, from outside the cluster, by requesting `NodeIP:NodePort`.
- **LoadBalancer**: Exposes the service externally using a cloud provider’s load balancer.


### Install the chart

Install the Zabbix helm chart with a release name `my-release`:

```bash
helm install --name my-release cetic/helm-zabbix
```

## Uninstallation

To uninstall/delete the `my-release` deployment:

```bash
helm delete my-release
```

## How to access

After deploying the chart in your cluster, forward the port 80 to a different port like 8080 ( you can't use the port 80 ) using: 

```bash
kubectl port-forward zabbix-0 8080:80
```

then on your browser go to `localhost:8080`, the default username/password are `Admin`/`zabbix`

## Configuration

The following table lists the configurable parameters of the zabbix chart and the default values.

| Parameter                                                                   | Description                                                                                                        | Default                         |
| --------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------| ------------------------------- |
| **ReplicaCount**                                                            |
| `replicaCount`                                                              | number of Zabbix images                                                                                               | `1`      |
| **Env**                                                                     |
| `env`                                                                       | See values.yaml                                                                                                           | `nil`      |
| **Image**                                                                   |
| `zabbixServer.image.repository`                                                          | Zabbix server Image name                                                                                                 | `zabbix/zabbix-server-pgsql`      |
| `image.tag`                                                                 | Zabbix server Image tag                                                                                                  | `ubuntu-4.4.5`                    |
| `image.pullPolicy`                                                          | Pull policy                                                                                          | `IfNotPresent`             |
| `zabbixServer.image.repository`                                                          | Zabbix agent Image name                                                                                                 | `zabbix/zabbix-agent`      |
| `image.tag`                                                                 | Zabbix Image tag                                                                                                  | `ubuntu-4.4.5`                    |
| `image.pullPolicy`                                                          | Pull policy                                                                                          | `IfNotPresent`             |
| `zabbixagent.image.repository`                                                          | Zabbix web Image name                                                                                                 | `zabbix/zabbix-web-apache-pgsql`      |
| `image.tag`                                                                 | Zabbix Image tag                                                                                                  | `ubuntu-4.4.5`                    |
| `image.pullPolicy`                                                          | Pull policy                                                                                          | `IfNotPresent`             |                                                
| **Service**                                                                 |
| `zabbixweb.service.type`                                                              | Type of service for Zabbix frontend                                                                               | `NodePort`             |
| `zabbixweb.service.port`                                                              | Port to expose service                                                                                             | `80`                            |
| `zabbixagent.service.type`                                                              | Type of service for Zabbix Agent                                                                               | `ClusterIP`             |
| `zabbixagent.service.port`                                                              | Port to expose service                                                                                             | `10050`                            |
| `zabbixServer.service.type`                                                              | Type of service for Zabbix Server                                                                               | `NodePort`             |
| `zabbixServer.service.port`                                                              | Port to expose service                                                                                             | `10051`                            |
| **zabbixServer**                                                                 |
| `POSTGRES_USER`                                                           | DB User                                                                                                    | `zabbix`                         |
| `POSTGRES_PASSWORD`                                                       | DB password                                                                                                | `my_password`                            |
| `DB_SERVER_HOST`                                                              | Host DB                                                                                            | `fadi-zabbix-db`                             |
| `POSTGRES_DB`                                                             | The DB name                                                                                                      | `fadi-zabbix-server`                           |
| **zabbixAgent**                                                                 |
| `ZBX_HOSTNAME`                                                           | Case sensitive hostname                                                                                                    | `zabbix-agent`                         |
| `ZBX_SERVER_HOST`                                                       | Zabbix-server host name                                                                                                | `zabbix-server`                            |
| `ZBX_SERVER_PORT`                                                              | Zabbix server port                                                                                            | `10051`                             |
| `ZBX_PASSIVE_ALLOW`                                                             | passive checks                                                                                               | `true`                           |
| `ZBX_PASSIVESERVERS`                                                           | list of allowed Zabbix server or proxy hosts                                                                                                    | `127.0.0.1`                         |
| `ZBX_ACTIVE_ALLOW`                                                       | active checks                                                                                                | `true`                            |
| `ZBX_DEBUGLEVEL`                                                              | debug level, from 0 to 5                                                                                           | `3`                             |
| `ZBX_VMWARECACHESIZE`                                                             | Cache size                                                                                               | `128M`                           |
| **zabbixWeb**                                                                 |
| `ZBX_SERVER_HOST`                                                           | Zabbix server host                                                                                                  | `zabbix-server`                         |
| `ZBX_SERVER_PORT`                                                       | Zabbix server port                                                                                               | `10051`                            |
| `DB_SERVER_HOST`                                                              | Host DB                                                                                            | `zabbix-postgresql`                             |
| `DB_SERVER_PORT`                                                             | The DB port                                                                                                      | `5432`                           |
| `POSTGRES_USER`                                                           | DB User                                                                                                    | `zabbix`                         |
| `POSTGRES_PASSWORD`                                                       | DB password                                                                                                | `zabbix_pwd`                            |
| `POSTGRES_DB`                                                              | database name                                                                                            | `zabbix`                             |
| **ReadinessProbe**                                                          |
| `readinessProbe`                                                            | Rediness Probe settings                                                                                            | `{}`|
| **LivenessProbe**                                                           |
| `livenessProbe`                                                             | Liveness Probe settings                                                                                            | `{}`|
| **Ingress**                                                                 |
| `ingress.enabled`                                                           | Enables Ingress                                                                                                    | `false`                         |
| `ingress.annotations`                                                       | Ingress annotations                                                                                                | `{}`                            |
| `ingress.path`                                                              | Path to access frontend                                                                                            | `/`                             |
| `ingress.hosts`                                                             | Ingress hosts                                                                                                      | `nil`                           |
| `ingress.tls`                                                               | Ingress TLS configuration                                                                                          | `[]`                            |
| **Resources**                                                               |
| `resources`                                                                 | CPU/Memory resource requests/limits                                                                                | `{}`                            |
| **nodeSelector**                                                            |
| `nodeSelector`                                                              | nodeSelector                                                                                                       | `{}`                            |
| **tolerations**                                                             |
| `tolerations`                                                               | tolerations                                                                                                        | `{}`                            |
| **affinity**                                                                |
| `affinity`                                                                  | affinity                                                                                                           | `{}`                            |

## Credits

Initially inspired from https://github.com/monitoringartist/kubernetes-zabbix.


## License

[Apache License 2.0](/LICENSE)
