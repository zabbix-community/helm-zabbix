# Helm Chart For Zabbix

[![CircleCI](https://circleci.com/gh/cetic/helm-zabbix.svg?style=svg)](https://circleci.com/gh/cetic/helm-zabbix/tree/master) [![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![version](https://img.shields.io/github/tag/cetic/helm-zabbix.svg?label=release)

## Introduction

This [Helm](https://github.com/cetic/helm-zabbix) chart installs [Zabbix](https://www.zabbix.com) in a Kubernetes cluster.

## Prerequisites

- Kubernetes cluster 1.10+
- Helm 3.0+
- PV provisioner support in the underlying infrastructure.

## Installation

### Add Helm repository

```bash
helm repo add cetic https://cetic.github.io/helm-charts
helm repo update
```

### Configure the chart

The following items can be set via `--set` flag during installation or configured by editing the `values.yaml` directly (you need to download the chart first).

### Importnant note

>**This helm chart is still under developpement and it doesn't work as it's supposed to, yet.**


#### Configure the way how to expose phpLDAPadmin service:

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
helm delete --purge my-release
```

## Configuration

The following table lists the configurable parameters of the zabbix chart and the default values.

| Parameter                                                                   | Description                                                                                                        | Default                         |
| --------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------| ------------------------------- |
| **ReplicaCount**                                                            |
| `replicaCount`                                                              | number of Zabbix images                                                                                               | `3`      |
| **Env**                                                                     |
| `env`                                                                       | See values.yaml                                                                                                           | `nil`      |
| **Image**                                                                   |
| `image.repository`                                                          | Zabbix Image name                                                                                                 | `monitoringartist/zabbix-xxl`      |
| `image.tag`                                                                 | Zabbix Image tag                                                                                                  | `latest`                    |
| `image.pullPolicy`                                                          | Zabbix Image pull policy                                                                                          | `IfNotPresent`             |
| **Service**                                                                 |
| `service.type`                                                              | Type of service for Zabbix frontend                                                                               | `LoadBalancer`             |
| `service.port`                                                              | Port to expose service                                                                                             | `80`                            |
| `service.loadBalancerIP`                                                    | LoadBalancerIP if service type is `LoadBalancer`                                                                   | `nil`                           |
| `service.loadBalancerSourceRanges`                                          | LoadBalancerSourceRanges                                                                                           | `nil`                           |
| `service.annotations`                                                       | Service annotations                                                                                                | `{}`                            |
| **zabbixWeb**                                                                 |
| `ZS_DBUser`                                                           | DB User                                                                                                    | `zabbix`                         |
| `ZS_DBPassword`                                                       | DB password                                                                                                | `my_password`                            |
| `ZS_DBHost`                                                              | Host DB                                                                                            | `fadi-zabbix-db`                             |
| `Zabbix server`                                                             | fadi-zabbix-server                                                                                                      | `fadi-zabbix-server`                           |
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
