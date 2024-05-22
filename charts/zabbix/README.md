# Helm chart for Zabbix.

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![Version: 4.4.0](https://img.shields.io/badge/Version-4.4.0-informational?style=flat-square)  [![Downloads](https://img.shields.io/github/downloads/zabbix-community/helm-zabbix/total?label=Downloads%20All%20Releases
)](https://tooomm.github.io/github-release-stats/?username=zabbix-community&repository=helm-zabbix)

Zabbix is a mature and effortless enterprise-class open source monitoring solution for network monitoring and application monitoring of millions of metrics.

This Helm chart installs [Zabbix](https://www.zabbix.com) in a Kubernetes cluster.

# Prerequisites

- Kubernetes cluster 1.10+
- Helm 3.0+
- Kubectl
- PV provisioner support in the underlying infrastructure (optional).

Install the ``kubectl`` and ``helm`` requirements following the instructions in this [tutorial](docs/requirements.md).

# Installation

> **Attention!!! Read the [Breaking changes of this helm chart](#breaking-changes-of-this-helm-chart).**

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
export ZABBIX_CHART_VERSION='4.3.0'
```

Export default values of ``zabbix`` chart to ``$HOME/zabbix_values.yaml`` file:

```bash
helm show values zabbix-community/zabbix --version $ZABBIX_CHART_VERSION > $HOME/zabbix_values.yaml
```

Change the values according to the environment in the ``$HOME/zabbix_values.yaml`` file. The items of section [Configuration](#configuration) can be set via ``--set`` flag in
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

* URL: http://localhost:8888
* Login: **Admin**
* Password: **zabbix**

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

## Version 4.0.0

* Will be used Postgresql 15.x and Zabbix 6.x.
* Allow install zabbix-agent2 as deployment and sidecar container. More info: https://github.com/zabbix-community/helm-zabbix/issues/20
* This release changes parameter names in preparation for addressing these issues in the future and use [camelCase](https://en.wikipedia.org/wiki/Camel_case) pattern where is possible. More info: https://github.com/zabbix-community/helm-zabbix/issues/18 and https://github.com/zabbix-community/helm-zabbix/issues/21
  * ``db_access`` -> ``postgresAccess``
  * ``db_access.use_unified_secret`` -> ``postgresAccess.useUnifiedSecret``
  * ``db_access.unified_secret_name`` -> ``postgresAccess.unifiedSecretName``
  * ``db_access.unified_secret_autocreate`` -> ``postgresAccess.unifiedSecretAutoCreate``
  * ``db_access.db_server_host`` -> ``postgresAccess.host``
  * ``db_access.db_server_port`` -> ``postgresAccess.port``
  * ``db_access.postgres_user`` -> ``postgresAccess.user``
  * ``db_access.postgres_password`` -> ``postgresAccess.password``
  * ``db_access.postgres_db`` -> ``postgresAccess.database``
  * ``db_access.postgres_password_secret`` -> ``postgresAccess.passwordSecret``
  * ``db_access.postgres_password_secret_key`` -> ``postgresAccess.passwordSecretKey``
  * ``ingressroute`` -> ``ingressRoute``
  * ``postgresql.existing_claim_name`` -> ``postgresql.existingClaimName``
  * ``postgresql.storage_size`` -> ``postgresql.storageSize``
  * ``postgresql.storage_class`` -> ``postgresql.storageClass``
  * ``zabbix_image_tag`` -> ``zabbixImageTag``
  * ``zabbixagent`` -> ``zabbixAgent``
  * ``zabbixproxy`` -> ``zabbixProxy``
  * ``zabbixserver`` -> ``zabbixServer``
  * ``zabbixserver.pod_anti_affinity`` -> ``zabbixServer.podAntiAffinity``
  * ``zabbixserver.ha_nodes_autoclean`` -> ``zabbixServer.haNodesAutoClean``
  * ``zabbixserver.ha_nodes_autoclean.delete_older_than_seconds`` -> ``zabbixServer.haNodesAutoClean.deleteOlderThanSeconds``
  * ``zabbixweb`` -> ``zabbixWeb``
  * ``zabbixweb.pod_anti_affinity`` -> ``zabbixWeb.podAntiAffinity``
  * ``zabbixweb.saml_certs_secret_name`` -> ``zabbixWeb.samlCertsSecretName``
  * ``zabbixwebservice`` -> ``zabbixWebService``
  * ``zabbixwebservice.pod_anti_affinity`` -> ``zabbixWebService.podAntiAffinity``
  * ``zabbixwebservice.ignore_url_cert_errors`` -> ``zabbixWebService.ignoreURLCertErrors``

## Version 3.0.0

* Will be used Postgresql 14.x and Zabbix 6.x.
* This version removes the possibility to specify database username/password per
  subsection in favor of specifying all of them centrally at one place.
* Also, the names of the values have changed from upper to lowercase.
* It is now possible to start the Zabbix Server pods with replicas of more than 1.
  HA functionality of Zabbix will automatically be enabled and it is made sure that
  the database schema publication will only happen once, and not by all of the Zabbix
  Server pods at the same time.
* More info: https://github.com/cetic/helm-zabbix/pull/54

## Version 2.0.0

* Will be used Postgresql 14.x and Zabbix 6.x.
* This version implements a central way of managing database access credentials
using a secret, which then will be respected by all the components
installed by this chart: zabbixServer, zabbixWeb and postgresql.
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

## Version 1.0.0

* Will be used Postgresql 14.x and Zabbix 6.x.
* The installation of any component of chart is optional for easy integration with the official
 chart: https://git.zabbix.com/projects/ZT/repos/kubernetes-helm/
* More info: https://github.com/cetic/helm-zabbix/issues/42

# Zabbix components

> **About the Zabbix version supported**
* This helm chart is compatible with non-LTS version of Zabbix, that include important changes and functionalities.
* But by default this helm chart will install the latest LTS version (example: 6.0.x).
See more info in [Zabbix Life Cycle & Release Policy](https://www.zabbix.com/life_cycle_and_release_policy) page
* When you want use a non-LTS version (example: 6.4.x), you have to set this in ``values.yaml`` yourself.

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

> **zabbix-agent2** is supported in this helm chart.

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

> This helm chart installs Zabbix Proxy with SQLite3 support

**Zabbix Proxy** is a process that may collect monitoring data from one or more monitored devices
and send the information to the Zabbix Server, essentially working on behalf of the server.
All collected data is buffered locally and then transferred to the **Zabbix Server** the
proxy belongs to
[Official documentation](https://www.zabbix.com/documentation/current/en/manual/concepts/proxy).

## PostgreSQL

A database is required for zabbix to work, in this helm chart we're using Postgresql.

> We use plain postgresql database by default WITHOUT persistence. If you want persistence or
would like to use TimescaleDB instead, check the comments in the ``values.yaml`` file.

# Thanks

> **About the new home of helm chart**
* The new home of the Zabbix helm chart is: https://github.com/zabbix-community/helm-zabbix.
It is a fork from the [cetic/helm-zabbix](https://github.com/cetic/helm-zabbix).
* In this [issue](https://github.com/cetic/helm-zabbix/issues/68) it was agreed with [Sebastien Dupont](https://github.com/banzothat) that the repository would get a new home.
* We are grateful to [Cetic](https://www.cetic.be/) for making the infrastructure available on CircleCI to host the helm chart from the start. Now, the new versions will be hosted on Github.
* We are very grateful to [Alexandre Nuttinck](https://github.com/alexnuttinck) and [Amen Ayadi](https://github.com/AyadiAmen), who were the first developers of the helm chart and who worked at Cetic. Your dedication and effort made it possible to install Zabbix on a Kubernetes cluster.

# License

[Apache License 2.0](/LICENSE)

# Configuration

The following tables lists the configurable parameters of the chart and their default values.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity configurations. Reference: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/ |
| global.commonLabels | object | `{}` | Labels to apply to all resources. |
| global.imagePullSecrets | list | `[]` | Reference to one or more secrets to be used when pulling images.  For example:  imagePullSecrets:    - name: "image-pull-secret" |
| ingress.annotations | object | `{}` | Ingress annotations |
| ingress.enabled | bool | `false` | Enables Ingress |
| ingress.hosts | list | `[{"host":"chart-example.local","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}]` | Ingress hosts |
| ingress.pathType | string | `"Prefix"` | pathType is only for k8s >= 1.1= |
| ingress.tls | list | `[]` | Ingress TLS configuration |
| ingressRoute.annotations | object | `{}` | IngressRoute annotations |
| ingressRoute.enabled | bool | `false` | Enables Traefik IngressRoute |
| ingressRoute.entryPoints | list | `["websecure"]` | Ingressroute entrypoints |
| ingressRoute.hostName | string | `"chart-example.local"` | Ingressroute host name |
| karpenter.amiFamily | string | `"Bottlerocket"` | AMIFamily is a required field, dictating both the default bootstrapping logic for nodes provisioned through this EC2NodeClass but also selecting a group of recommended, latest AMIs by default. Currently, Karpenter supports amiFamily values AL2, Bottlerocket, Ubuntu, Windows2019, Windows2022 and Custom. GPUs are only supported by default with AL2 and Bottlerocket. The AL2 amiFamily does not support ARM64 GPU instance type |
| karpenter.clusterName | string | `"CHANGE_HERE"` | Name of cluster. Change the term CHANGE_HERE by EKS cluster name if you want to use Karpenter. Example: testing-my-cluster |
| karpenter.disruption | object | `{"consolidateAfter":"30s","consolidationPolicy":"WhenEmpty","expireAfter":"720h"}` | Disruption section which describes the ways in which Karpenter can disrupt and replace Nodes. Configuration in this section constrains how aggressive Karpenter can be with performing operations like rolling Nodes due to them hitting their maximum lifetime (expiry) or scaling down nodes to reduce cluster cost |
| karpenter.disruption.consolidateAfter | string | `"30s"` | The amount of time Karpenter should wait after discovering a consolidation decision This value can currently only be set when the consolidationPolicy is 'WhenEmpty' You can choose to disable consolidation entirely by setting the string value 'Never' here |
| karpenter.disruption.consolidationPolicy | string | `"WhenEmpty"` | Describes which types of Nodes Karpenter should consider for consolidation. If using 'WhenUnderutilized', Karpenter will consider all nodes for consolidation and attempt to remove or replace Nodes when it discovers that the Node is underutilized and could be changed to reduce cost If using `WhenEmpty`, Karpenter will only consider nodes for consolidation that contain no workload pods |
| karpenter.disruption.expireAfter | string | `"720h"` | The amount of time a Node can live on the cluster before being removed Avoiding long-running Nodes helps to reduce security vulnerabilities as well as to reduce the chance of issues that can plague Nodes with long uptimes such as file fragmentation or memory leaks from system processes You can choose to disable expiration entirely by setting the string value 'Never' here |
| karpenter.enabled | bool | `false` | Enables support provisioner of Karpenter. Reference: https://karpenter.sh/. Tested only using EKS cluster 1.28 in AWS with Karpenter 0.33.0. |
| karpenter.instanceProfile | object | `{"name":"CHANGE_HERE","use":false}` | Name of instanceProfile EKS cluster. Conflicts with karpenter.role. Must specify one of "role" or "instanceProfile" for Karpenter to launch nodes Example: Karpenter-testing-my-cluster-2023120112554517810000001e |
| karpenter.labels | object | `{"app":"zabbix","karpenter":"true"}` | Labels are arbitrary key-values that are applied to all nodes |
| karpenter.limits | object | `{"cpu":"2","memory":"8Gi"}` | Resource limits constrain the total size of the cluster. Limits prevent Karpenter from creating new instances once the limit is exceeded. |
| karpenter.metadataOptions | object | `{"httpEndpoint":"enabled","httpProtocolIPv6":"disabled","httpPutResponseHopLimit":2,"httpTokens":"required"}` | Optional, configures IMDS for the instance |
| karpenter.requirements | list | `[{"key":"karpenter.k8s.aws/instance-category","operator":"In","values":["c","m","r"]},{"key":"karpenter.k8s.aws/instance-cpu","operator":"In","values":["2","4","8","16","32"]},{"key":"kubernetes.io/arch","operator":"In","values":["amd64"]},{"key":"kubernetes.io/os","operator":"In","values":["linux"]},{"key":"karpenter.sh/capacity-type","operator":"In","values":["spot","on-demand"]}]` | Requirements that constrain the parameters of provisioned nodes. These requirements are combined with pod.spec.topologySpreadConstraints, pod.spec.affinity.nodeAffinity, pod.spec.affinity.podAffinity, and pod.spec.nodeSelector rules. Operators { In, NotIn, Exists, DoesNotExist, Gt, and Lt } are supported. https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#operators |
| karpenter.resourceTags | object | `{"Environment":"testing","Scost":"zabbix","product":"zabbix"}` | Karpenter adds tags to all resources it creates, including EC2 Instances, EBS volumes, and Launch Templates. See details: https://karpenter.sh/v0.33/concepts/nodeclasses/#spectags |
| karpenter.role | object | `{"name":"CHANGE_HERE","use":true}` | Name of role EKS cluster. The Karpenter spec.instanceProfile field has been removed from the EC2NodeClass in favor of the spec.role field. Karpenter is also removing support for the defaultInstanceProfile specified globally in the karpenter-global-settings, making the spec.role field required for all EC2NodeClasses. Karpenter will now auto-generate the instance profile in your EC2NodeClass, given the role that you specify. If using the Karpenter Getting Started Guide to deploy Karpenter, you can use the karpenter-irsa-$CLUSTER_NAME-$ID role provisioned by that process (which is limited to 64 characters). Example: karpenter-irsa-testing-my-cluster-2023120421433226760000001e |
| karpenter.tag | string | `"karpenter.sh/discovery"` | Tag of discovery with name of cluster used by Karpenter. Change the term CHANGE_HERE by EKS cluster name if you want to use Karpenter. The cluster name, security group and subnets must have this tag. |
| karpenter.weight | int | `10` | Priority given to the NodePool when the scheduler considers which NodePool to select. Higher weights indicate higher priority when comparing NodePools. Specifying no weight is equivalent to specifying a weight of 0. |
| nodeSelector | object | `{}` | nodeSelector configurations. Reference: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/ |
| postgresAccess.database | string | `"zabbix"` | Name of database |
| postgresAccess.host | string | `"zabbix-postgresql"` | Address of database host - ignored if postgresql.enabled=true |
| postgresAccess.password | string | `"zabbix"` | Password of database - ignored if passwordSecret is set |
| postgresAccess.port | string | `"5432"` | Port of database host - ignored if postgresql.enabled=true |
| postgresAccess.unifiedSecretAutoCreate | bool | `true` | automatically create secret if not already present (works only in combination with postgresql.enabled=true) |
| postgresAccess.unifiedSecretName | string | `"zabbixdb-pguser-zabbix"` | Name of one secret for unified configuration of PostgreSQL access |
| postgresAccess.useUnifiedSecret | bool | `true` | Whether to use the unified PostgreSQL access secret |
| postgresAccess.user | string | `"zabbix"` | User of database |
| postgresql.containerAnnotations | object | `{}` | Annotations to add to the containers |
| postgresql.containerLabels | object | `{}` | Labels to add to the containers |
| postgresql.enabled | bool | `true` | Create a database using Postgresql |
| postgresql.extraContainers | list | `[]` | Additional containers to start within the postgresql pod |
| postgresql.extraEnv | list | `[]` | Extra environment variables. A list of additional environment variables. |
| postgresql.extraInitContainers | list | `[]` | Additional init containers to start within the postgresql pod |
| postgresql.extraPodSpecs | object | `{}` | Additional specifications to the postgresql pod |
| postgresql.extraRuntimeParameters | object | `{"max_connections":50}` | Extra Postgresql runtime parameters ("-c" options) |
| postgresql.extraVolumeMounts | list | `[]` | Additional volumeMounts to the postgresql container |
| postgresql.extraVolumes | list | `[]` | Additional volumes to make available to the postgresql pod |
| postgresql.image.pullPolicy | string | `"IfNotPresent"` | Pull policy of Docker image |
| postgresql.image.pullSecrets | list | `[]` | List of dockerconfig secrets names to use when pulling images |
| postgresql.image.repository | string | `"postgres"` | Postgresql Docker image name: chose one of "postgres" or "timescale/timescaledb" |
| postgresql.image.tag | int | `15` | Tag of Docker image of Postgresql server, choice "15" for postgres "2.11.1-pg15" for timescaledb (Zabbix supports TimescaleDB 2.0.1-2.11.x. More info: https://www.zabbix.com/documentation/6.0/en/manual/installation/requirements) Added support for PostgreSQL versions 15.x since Zabbix 6.0.10 |
| postgresql.livenessProbe | object | `{}` | The kubelet uses liveness probes to know when to restart a container. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| postgresql.persistence.enabled | bool | `false` | Whether to enable persistent storage for the postgres container or not |
| postgresql.persistence.existingClaimName | bool | `false` | Existing persistent volume claim name to be used to store posgres data |
| postgresql.persistence.storageSize | string | `"5Gi"` | Size of the PVC to be automatically generated |
| postgresql.readinessProbe | object | `{}` | The kubelet uses readiness probes to know when a container is ready to start accepting traffic. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| postgresql.resources | object | `{}` | Requests and limits of pod resources. See: [https://kubernetes.io/docs/concepts/configuration/manage-resources-containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers) |
| postgresql.securityContext | object | `{}` | Security Context configurations. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| postgresql.service.annotations | object | `{}` | Annotations for the zabbix-server service |
| postgresql.service.clusterIP | string | `nil` | Cluster IP for Zabbix Server |
| postgresql.service.port | int | `5432` | Port of service in Kubernetes cluster |
| postgresql.service.type | string | `"ClusterIP"` | Type of service in Kubernetes cluster |
| postgresql.startupProbe | object | `{}` | The kubelet uses startup probes to know when a container application has started.  Reference: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| postgresql.statefulSetAnnotations | object | `{}` | Annotations to add to the statefulset |
| postgresql.statefulSetLabels | object | `{}` | Labels to add to the statefulset |
| rbac.additionalRulesForClusterRole | list | `[]` |  |
| rbac.create | bool | `true` | Specifies whether the RBAC resources should be created |
| route.annotations | object | `{}` | Openshift Route extra annotations |
| route.enabled | bool | `false` | Enables Route object for Openshift |
| route.hostName | string | `"chart-example.local"` | Host Name for the route. Can be left empty |
| route.tls | object | `{"termination":"edge"}` | Openshift Route TLS settings |
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
| zabbixAgent.containerAnnotations | object | `{}` | Annotations to add to the containers |
| zabbixAgent.containerLabels | object | `{}` | Labels to add to the containers |
| zabbixAgent.daemonSetAnnotations | object | `{}` | Annotations to add to the daemonSet |
| zabbixAgent.daemonSetLabels | object | `{}` | Labels to add to the daemonSet |
| zabbixAgent.deploymentLabels | object | `{}` | Labels to add to the deployment |
| zabbixAgent.enabled | bool | `true` | Enables use of **Zabbix Agent** |
| zabbixAgent.extraContainers | list | `[]` | Additional containers to start within the Zabbix Agent pod |
| zabbixAgent.extraEnv | list | `[]` | Extra environment variables. A list of additional environment variables. List can be extended with other environment variables listed here: https://github.com/zabbix/zabbix-docker/tree/6.0/Dockerfiles/agent2/alpine#environment-variables. See example: https://github.com/zabbix-community/helm-zabbix/blob/master/charts/zabbix/docs/example/kind/values.yaml |
| zabbixAgent.extraInitContainers | list | `[]` | Additional init containers to start within the Zabbix Agent pod |
| zabbixAgent.extraPodSpecs | object | `{}` | Additional specifications to the Zabbix Agent pod |
| zabbixAgent.extraVolumeMounts | list | `[]` | Additional volumeMounts to the zabbix Agent container |
| zabbixAgent.extraVolumes | list | `[]` | Additional volumes to make available to the Zabbix Agent pod |
| zabbixAgent.hostRootFsMount | bool | `true` | If true, agent pods mounts host / at /host/root |
| zabbixAgent.image.pullPolicy | string | `"IfNotPresent"` | Pull policy of Docker image |
| zabbixAgent.image.pullSecrets | list | `[]` | List of dockerconfig secrets names to use when pulling images |
| zabbixAgent.image.repository | string | `"zabbix/zabbix-agent2"` | Zabbix Agent Docker image name. Can use zabbix/zabbix-agent or zabbix/zabbix-agent2 |
| zabbixAgent.image.tag | string | `nil` | Zabbix Agent Docker image tag, if you want to override zabbixImageTag |
| zabbixAgent.livenessProbe | object | `{"failureThreshold":3,"periodSeconds":10,"successThreshold":1,"tcpSocket":{"port":"zabbix-agent"},"timeoutSeconds":3}` | The kubelet uses liveness probes to know when to restart a container. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| zabbixAgent.livenessProbe.tcpSocket.port | string | `"zabbix-agent"` | Port number/alias name of the container |
| zabbixAgent.readinessProbe | object | `{}` | The kubelet uses readiness probes to know when a container is ready to start accepting traffic. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| zabbixAgent.resources | object | `{}` | Requests and limits of pod resources. See: [https://kubernetes.io/docs/concepts/configuration/manage-resources-containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers) |
| zabbixAgent.runAsDaemonSet | bool | `false` | Enable this mode if you want to run zabbix-agent as daemonSet. The 'zabbixAgent.runAsSidecar' option must be false. |
| zabbixAgent.runAsSidecar | bool | `true` | Its is a default mode. Zabbix-agent will run as sidecar in zabbix-server and zabbix-proxy pods. Disable this mode if you want to run zabbix-agent as daemonSet |
| zabbixAgent.securityContext | object | `{}` | Security Context configurations. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| zabbixAgent.service.annotations | object | `{}` | Annotations for the zabbix-agent service |
| zabbixAgent.service.clusterIP | string | `nil` | Cluster IP for Zabbix Agent |
| zabbixAgent.service.externalIPs | list | `[]` | IPs if use service type LoadBalancer" |
| zabbixAgent.service.listenOnAllInterfaces | bool | `true` | externalTrafficPolicy for Zabbix Agent service. "Local" to preserve sender's IP address. Please note that this might not work on multi-node clusters, depending on your network settings. externalTrafficPolicy: Local |
| zabbixAgent.service.loadBalancerIP | string | `""` |  |
| zabbixAgent.service.port | int | `10050` | Port to expose service |
| zabbixAgent.service.type | string | `"ClusterIP"` | Type of service for Zabbix Agent |
| zabbixAgent.startupProbe | object | `{"failureThreshold":5,"initialDelaySeconds":15,"periodSeconds":5,"successThreshold":1,"tcpSocket":{"port":"zabbix-agent"},"timeoutSeconds":3}` | The kubelet uses startup probes to know when a container application has started.  Reference: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| zabbixAgent.startupProbe.tcpSocket.port | string | `"zabbix-agent"` | Port number/alias name of the container |
| zabbixImageTag | string | `"ubuntu-6.0.30"` | Zabbix components (server, agent, web frontend, ...) image tag to use. This helm chart is compatible with non-LTS version of Zabbix, that include important changes and functionalities. But by default this helm chart will install the latest LTS version (example: 6.0.x). See more info in [Zabbix Life Cycle & Release Policy](https://www.zabbix.com/life_cycle_and_release_policy) page When you want use a non-LTS version (example: 6.2.x), you have to set this yourself. You can change version here or overwrite in each component (example: zabbixserver.image.tag, etc). |
| zabbixJavaGateway.ZBX_DEBUGLEVEL | int | `3` | The variable is used to specify debug level, from 0 to 5 |
| zabbixJavaGateway.ZBX_JAVAGATEWAY | string | `"zabbix-java-gateway"` | Additional arguments for Zabbix Java Gateway. Useful to enable additional libraries and features. ZABBIX_OPTIONS:  Java Gateway Service Name |
| zabbixJavaGateway.ZBX_START_POLLERS | int | `5` | This variable is specified amount of pollers. By default, value is 5 |
| zabbixJavaGateway.ZBX_TIMEOUT | int | `3` | This variable is used to specify timeout for outgoing connections. By default, value is 3. |
| zabbixJavaGateway.containerAnnotations | object | `{}` | Annotations to add to the containers |
| zabbixJavaGateway.containerLabels | object | `{}` | Labels to add to the containers |
| zabbixJavaGateway.deploymentAnnotations | object | `{}` | Annotations to add to the deployment |
| zabbixJavaGateway.deploymentLabels | object | `{}` | Labels to add to the deployment |
| zabbixJavaGateway.enabled | bool | `false` | Enables use of **Zabbix Java Gateway** |
| zabbixJavaGateway.extraContainers | list | `[]` | Additional containers to start within the Zabbix Java Gateway pod |
| zabbixJavaGateway.extraEnv | list | `[]` | Extra environment variables. A list of additional environment variables. List can be extended with other environment variables listed here: https://github.com/zabbix/zabbix-docker/tree/6.0/Dockerfiles/agent2/alpine#environment-variables. See example: https://github.com/zabbix-community/helm-zabbix/blob/master/charts/zabbix/docs/example/kind/values.yaml |
| zabbixJavaGateway.extraInitContainers | list | `[]` | Additional init containers to start within the Zabbix Java Gateway pod |
| zabbixJavaGateway.extraPodSpecs | object | `{}` | Additional specifications to the Zabbix Java Gateway pod |
| zabbixJavaGateway.extraVolumeMounts | list | `[]` | Additional volumeMounts to the Zabbix Java Gateway container |
| zabbixJavaGateway.extraVolumes | list | `[]` | Additional volumes to make available to the Zabbix Java Gateway pod |
| zabbixJavaGateway.image.pullPolicy | string | `"IfNotPresent"` | Pull policy of Docker image |
| zabbixJavaGateway.image.pullSecrets | list | `[]` | List of dockerconfig secrets names to use when pulling images |
| zabbixJavaGateway.image.repository | string | `"zabbix/zabbix-java-gateway"` | Zabbix Java Gateway Docker image name. |
| zabbixJavaGateway.image.tag | string | `nil` | Zabbix Java Gateway Docker image tag, if you want to override zabbixImageTag |
| zabbixJavaGateway.livenessProbe | object | `{"failureThreshold":3,"periodSeconds":10,"successThreshold":1,"tcpSocket":{"port":"zabbix-java-gw"},"timeoutSeconds":3}` | The kubelet uses liveness probes to know when to restart a container. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| zabbixJavaGateway.livenessProbe.tcpSocket.port | string | `"zabbix-java-gw"` | Port number/alias name of the container |
| zabbixJavaGateway.readinessProbe | object | `{}` | The kubelet uses readiness probes to know when a container is ready to start accepting traffic. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| zabbixJavaGateway.replicaCount | int | `1` | Number of replicas of ``Zabbix Java Gateway`` module |
| zabbixJavaGateway.resources | object | `{}` | Requests and limits of pod resources. See: [https://kubernetes.io/docs/concepts/configuration/manage-resources-containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers) |
| zabbixJavaGateway.securityContext | object | `{}` | Security Context configurations. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| zabbixJavaGateway.service.annotations | object | `{}` | Annotations for the zabbix-java-gateway service |
| zabbixJavaGateway.service.clusterIP | string | `nil` | Cluster IP for Zabbix Java Gateway |
| zabbixJavaGateway.service.listenOnAllInterfaces | bool | `true` | externalTrafficPolicy for Zabbix Java Gateway service. "Local" to preserve sender's IP address. Please note that this might not work on multi-node clusters, depending on your network settings. externalTrafficPolicy: Local |
| zabbixJavaGateway.service.port | int | `10052` | Port to expose service |
| zabbixJavaGateway.service.type | string | `"ClusterIP"` | Type of service for Zabbix Java Gateway |
| zabbixJavaGateway.startupProbe | object | `{"failureThreshold":5,"initialDelaySeconds":15,"periodSeconds":5,"successThreshold":1,"tcpSocket":{"port":"zabbix-java-gw"},"timeoutSeconds":3}` | The kubelet uses startup probes to know when a container application has started.  Reference: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| zabbixJavaGateway.startupProbe.tcpSocket.port | string | `"zabbix-java-gw"` | Port number/alias name of the container |
| zabbixProxy.ZBX_DEBUGLEVEL | int | `4` |  |
| zabbixProxy.ZBX_HOSTNAME | string | `"zabbix-proxy"` | Zabbix Proxy hostname Case sensitive hostname |
| zabbixProxy.ZBX_JAVAGATEWAY_ENABLE | bool | `false` | The variable enable communication with Zabbix Java Gateway to collect Java related checks. By default, value is false. |
| zabbixProxy.ZBX_PROXYMODE | int | `0` | The variable allows to switch Zabbix Proxy mode. By default, value is 0 - active proxy. Allowed values are 0 and 1. |
| zabbixProxy.ZBX_SERVER_HOST | string | `"zabbix-zabbix-server"` | Zabbix Server host |
| zabbixProxy.ZBX_SERVER_PORT | int | `10051` | Zabbix Server port |
| zabbixProxy.ZBX_TIMEOUT | int | `4` |  |
| zabbixProxy.ZBX_VMWARECACHESIZE | string | `"128M"` | Cache size |
| zabbixProxy.containerAnnotations | object | `{}` | Annotations to add to the containers |
| zabbixProxy.containerLabels | object | `{}` | Labels to add to the containers |
| zabbixProxy.enabled | bool | `false` | Enables use of **Zabbix Proxy** |
| zabbixProxy.extraContainers | list | `[]` | Additional containers to start within the Zabbix Proxy pod |
| zabbixProxy.extraEnv | list | `[]` | Extra environment variables. A list of additional environment variables. List can be extended with other environment variables listed here: https://github.com/zabbix/zabbix-docker/tree/6.0/Dockerfiles/proxy-sqlite3/alpine#environment-variables. See example: https://github.com/zabbix-community/helm-zabbix/blob/master/charts/zabbix/docs/example/kind/values.yaml |
| zabbixProxy.extraInitContainers | list | `[]` | Additional init containers to start within the Zabbix Proxy pod |
| zabbixProxy.extraPodSpecs | object | `{}` | Additional specifications to the Zabbix Proxy pod |
| zabbixProxy.extraVolumeClaimTemplate | list | `[]` | Extra volumeClaimTemplate for zabbixProxy statefulset |
| zabbixProxy.extraVolumeMounts | list | `[]` | Additional volumeMounts to the Zabbix Proxy container |
| zabbixProxy.extraVolumes | list | `[]` | Additional volumes to make available to the Zabbix Proxy pod |
| zabbixProxy.image.pullPolicy | string | `"IfNotPresent"` | Pull policy of Docker image |
| zabbixProxy.image.pullSecrets | list | `[]` | List of dockerconfig secrets names to use when pulling images |
| zabbixProxy.image.repository | string | `"zabbix/zabbix-proxy-sqlite3"` | Zabbix Proxy Docker image name |
| zabbixProxy.image.tag | string | `nil` | Zabbix Proxy Docker image tag, if you want to override zabbixImageTag |
| zabbixProxy.livenessProbe | object | `{}` | The kubelet uses liveness probes to know when to restart a container. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| zabbixProxy.readinessProbe | object | `{}` | The kubelet uses readiness probes to know when a container is ready to start accepting traffic. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| zabbixProxy.replicaCount | int | `1` | Number of replicas of ``zabbixProxy`` module |
| zabbixProxy.resources | object | `{}` | Requests and limits of pod resources. See: [https://kubernetes.io/docs/concepts/configuration/manage-resources-containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers) |
| zabbixProxy.securityContext | object | `{}` | Security Context configurations. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| zabbixProxy.service.annotations | object | `{}` | Annotations for the zabbix-proxy service |
| zabbixProxy.service.clusterIP | string | `nil` | Cluster IP for Zabbix Proxy |
| zabbixProxy.service.port | int | `10051` | Port to expose service |
| zabbixProxy.service.type | string | `"ClusterIP"` | Type of service for Zabbix Proxy |
| zabbixProxy.startupProbe | object | `{}` | The kubelet uses startup probes to know when a container application has started.  Reference: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| zabbixProxy.statefulSetAnnotations | object | `{}` | Annotations to add to the statefulset |
| zabbixProxy.statefulSetLabels | object | `{}` | Labels to add to the statefulset |
| zabbixServer.containerAnnotations | object | `{}` | Annotations to add to the containers |
| zabbixServer.containerLabels | object | `{}` | Labels to add to the containers |
| zabbixServer.deploymentAnnotations | object | `{}` | Annotations to add to the deployment |
| zabbixServer.deploymentLabels | object | `{}` | Labels to add to the deployment |
| zabbixServer.enabled | bool | `true` | Enables use of **Zabbix Server** |
| zabbixServer.extraContainers | list | `[]` | Additional containers to start within the Zabbix Server pod |
| zabbixServer.extraEnv | list | `[]` | Extra environment variables. A list of additional environment variables. List can be extended with other environment variables listed here: https://github.com/zabbix/zabbix-docker/tree/6.0/Dockerfiles/server-pgsql/alpine#environment-variables. See example: https://github.com/zabbix-community/helm-zabbix/blob/master/charts/zabbix/docs/example/kind/values.yaml |
| zabbixServer.extraInitContainers | list | `[]` | Additional init containers to start within the Zabbix Server pod |
| zabbixServer.extraPodSpecs | object | `{}` | Additional specifications to the Zabbix Server pod |
| zabbixServer.extraVolumeMounts | list | `[]` | Additional volumeMounts to the Zabbix Server container |
| zabbixServer.extraVolumes | list | `[]` | Additional volumes to make available to the Zabbix Server pod |
| zabbixServer.haNodesAutoClean | object | `{"concurrencyPolicy":"Replace","cronjobLabels":{},"deleteOlderThanSeconds":3600,"enabled":true,"extraContainers":[],"extraEnv":[],"extraInitContainers":[],"extraPodSpecs":{},"extraVolumeMounts":[],"extraVolumes":[],"image":{"pullPolicy":"IfNotPresent","pullSecrets":[],"repository":"postgres","tag":15},"resources":{},"schedule":"0 1 * * *","securityContext":{}}` | Automatically clean orphaned ha nodes from ha_nodes db table |
| zabbixServer.haNodesAutoClean.cronjobLabels | object | `{}` | Labels to add to the cronjob for ha nodes autoclean |
| zabbixServer.haNodesAutoClean.extraContainers | list | `[]` | Additional containers to start within the cronjob hanodes autoclean |
| zabbixServer.haNodesAutoClean.extraEnv | list | `[]` | Extra environment variables. A list of additional environment variables. |
| zabbixServer.haNodesAutoClean.extraInitContainers | list | `[]` | Additional init containers to start within the cronjob hanodes autoclean |
| zabbixServer.haNodesAutoClean.extraPodSpecs | object | `{}` | Additional specifications to the cronjob hanodes autoclean |
| zabbixServer.haNodesAutoClean.extraVolumeMounts | list | `[]` | Additional volumeMounts to the cronjob hanodes autoclean |
| zabbixServer.haNodesAutoClean.extraVolumes | list | `[]` | Additional volumes to make available to the cronjob hanodes autoclean |
| zabbixServer.haNodesAutoClean.image.repository | string | `"postgres"` | Postgresql Docker image name: chose one of "postgres" or "timescale/timescaledb" |
| zabbixServer.haNodesAutoClean.image.tag | int | `15` | Tag of Docker image of Postgresql server, choice "15" for postgres "2.10.3-pg15" for timescaledb (Zabbix supports TimescaleDB 2.0.1-2.10.x. More info: https://www.zabbix.com/documentation/6.0/en/manual/installation/requirements) Added support for PostgreSQL versions 15.x since Zabbix 6.0.10 |
| zabbixServer.haNodesAutoClean.resources | object | `{}` | Requests and limits of pod resources. See: [https://kubernetes.io/docs/concepts/configuration/manage-resources-containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers) |
| zabbixServer.haNodesAutoClean.securityContext | object | `{}` | Security Context configurations. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| zabbixServer.hostIP | string | `"0.0.0.0"` | Optional set hostIP different from 0.0.0.0 to open port only on this IP |
| zabbixServer.hostPort | bool | `false` | Optional set true open a port direct on node where Zabbix Server runs |
| zabbixServer.image.pullPolicy | string | `"IfNotPresent"` | Pull policy of Docker image |
| zabbixServer.image.pullSecrets | list | `[]` | List of dockerconfig secrets names to use when pulling images |
| zabbixServer.image.repository | string | `"zabbix/zabbix-server-pgsql"` | Zabbix Server Docker image name |
| zabbixServer.image.tag | string | `nil` | Zabbix Server Docker image tag, if you want to override zabbixImageTag |
| zabbixServer.jobDBSchema.extraContainers | list | `[]` | Additional containers to start within the Zabbix Server Job DB Schema pod |
| zabbixServer.jobDBSchema.extraInitContainers | list | `[]` | Additional init containers to start within the Zabbix Server Job DB Schema pod |
| zabbixServer.jobDBSchema.extraPodSpecs | object | `{}` | Additional specifications to the Zabbix Server Job DB Schema pod |
| zabbixServer.jobDBSchema.extraVolumeMounts | list | `[]` | Additional volumeMounts to the Zabbix Server Job DB Schema pod |
| zabbixServer.jobDBSchema.extraVolumes | list | `[]` | Additional volumes to make available to the  Zabbix Server Job DB Schema pod |
| zabbixServer.jobDBSchema.jobAnnotations | object | `{}` | Annotations to add to the jobs |
| zabbixServer.jobDBSchema.jobLabels | object | `{}` | Labels to add to the jobs |
| zabbixServer.jobDBSchema.securityContext | object | `{}` | Security Context configurations. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| zabbixServer.livenessProbe | object | `{}` | The kubelet uses liveness probes to know when to restart a container. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| zabbixServer.podAntiAffinity | bool | `true` | Set permissive podAntiAffinity to spread replicas over cluster nodes if replicaCount>1 |
| zabbixServer.readinessProbe | object | `{}` | The kubelet uses readiness probes to know when a container is ready to start accepting traffic. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| zabbixServer.replicaCount | int | `1` | Number of replicas of ``zabbixServer`` module |
| zabbixServer.resources | object | `{}` | Requests and limits of pod resources. See: [https://kubernetes.io/docs/concepts/configuration/manage-resources-containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers) |
| zabbixServer.securityContext | object | `{}` | Security Context configurations. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| zabbixServer.service.annotations | object | `{}` | Annotations for the zabbix-server service |
| zabbixServer.service.clusterIP | string | `nil` |  |
| zabbixServer.service.externalIPs | list | `[]` | IPs if use service type LoadBalancer" |
| zabbixServer.service.loadBalancerIP | string | `""` |  |
| zabbixServer.service.nodePort | int | `31051` | NodePort of service on each node |
| zabbixServer.service.port | int | `10051` | Port of service in Kubernetes cluster |
| zabbixServer.service.type | string | `"ClusterIP"` | Type of service in Kubernetes cluster |
| zabbixServer.startupProbe | object | `{}` | The kubelet uses startup probes to know when a container application has started.  Reference: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| zabbixWeb.containerAnnotations | object | `{}` | Annotations to add to the containers |
| zabbixWeb.containerLabels | object | `{}` | Labels to add to the containers |
| zabbixWeb.deploymentAnnotations | object | `{}` | Annotations to add to the deployment |
| zabbixWeb.deploymentLabels | object | `{}` | Labels to add to the deployment |
| zabbixWeb.enabled | bool | `true` | Enables use of **Zabbix Web** |
| zabbixWeb.extraContainers | list | `[]` | Additional containers to start within the Zabbix Web pod |
| zabbixWeb.extraEnv | list | `[]` | Extra environment variables. A list of additional environment variables. List can be extended with other environment variables listed here: https://github.com/zabbix/zabbix-docker/tree/6.0/Dockerfiles/web-apache-pgsql/alpine#environment-variables. See example: https://github.com/zabbix-community/helm-zabbix/blob/master/charts/zabbix/docs/example/kind/values.yaml |
| zabbixWeb.extraInitContainers | list | `[]` | Additional init containers to start within the Zabbix Web pod |
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
| zabbixWeb.securityContext | object | `{}` | Security Context configurations. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| zabbixWeb.service | object | `{"annotations":{},"clusterIP":null,"externalIPs":[],"loadBalancerIP":"","port":80,"type":"ClusterIP"}` | Certificate containing certificates for SAML configuration samlCertsSecretName: zabbix-web-samlcerts |
| zabbixWeb.service.annotations | object | `{}` | Annotations for the Zabbix Web |
| zabbixWeb.service.clusterIP | string | `nil` | Cluster IP for Zabbix Web |
| zabbixWeb.service.externalIPs | list | `[]` | IPs if use service type LoadBalancer" |
| zabbixWeb.service.port | int | `80` | Port to expose service |
| zabbixWeb.service.type | string | `"ClusterIP"` | Type of service for Zabbix Web |
| zabbixWeb.startupProbe | object | `{}` | The kubelet uses startup probes to know when a container application has started.  Reference: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| zabbixWebService.containerAnnotations | object | `{}` | Annotations to add to the containers |
| zabbixWebService.containerLabels | object | `{}` | Labels to add to the containers |
| zabbixWebService.deploymentAnnotations | object | `{}` | Annotations to add to the deployment |
| zabbixWebService.deploymentLabels | object | `{}` | Labels to add to the deployment |
| zabbixWebService.enabled | bool | `true` | Enables use of **Zabbix Web Service** |
| zabbixWebService.extraContainers | list | `[]` | Additional containers to start within the Zabbix Web Service pod |
| zabbixWebService.extraEnv | list | `[]` | Extra environment variables. A list of additional environment variables. List can be extended with other environment variables listed here: https://github.com/zabbix/zabbix-docker/tree/6.0/Dockerfiles/web-service/alpine#environment-variables. See example: https://github.com/zabbix-community/helm-zabbix/blob/master/charts/zabbix/docs/example/kind/values.yaml |
| zabbixWebService.extraInitContainers | list | `[]` | Additional init containers to start within the Zabbix Web Service pod |
| zabbixWebService.extraPodSpecs | object | `{}` | Additional specifications to the Zabbix Web Service pod |
| zabbixWebService.extraVolumeMounts | list | `[]` | Additional volumeMounts to the Zabbix Web Service container |
| zabbixWebService.extraVolumes | list | `[]` | Additional volumes to make available to the Zabbix Web Service pod |
| zabbixWebService.image.pullPolicy | string | `"IfNotPresent"` | Pull policy of Docker image |
| zabbixWebService.image.pullSecrets | list | `[]` | List of dockerconfig secrets names to use when pulling images |
| zabbixWebService.image.repository | string | `"zabbix/zabbix-web-service"` | Zabbix Webservice Docker image name |
| zabbixWebService.image.tag | string | `nil` | Zabbix Webservice Docker image tag, if you want to override zabbixImageTag |
| zabbixWebService.livenessProbe | object | `{}` | The kubelet uses liveness probes to know when to restart a container. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| zabbixWebService.podAntiAffinity | bool | `true` | Set permissive podAntiAffinity to spread replicas over cluster nodes if replicaCount>1 |
| zabbixWebService.readinessProbe | object | `{}` | The kubelet uses readiness probes to know when a container is ready to start accepting traffic. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| zabbixWebService.replicaCount | int | `1` | Number of replicas of ``zabbixWebService`` module |
| zabbixWebService.resources | object | `{}` | Requests and limits of pod resources. See: [https://kubernetes.io/docs/concepts/configuration/manage-resources-containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers) |
| zabbixWebService.securityContext | object | `{}` | Security Context configurations. Reference: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| zabbixWebService.service | object | `{"annotations":{},"clusterIP":null,"port":10053,"type":"ClusterIP"}` | Set the IgnoreURLCertErrors configuration setting of Zabbix Web Service ignoreURLCertErrors=1 |
| zabbixWebService.service.annotations | object | `{}` | Annotations for the Zabbix Web Service |
| zabbixWebService.service.clusterIP | string | `nil` | Cluster IP for Zabbix Web |
| zabbixWebService.service.port | int | `10053` | Port to expose service |
| zabbixWebService.service.type | string | `"ClusterIP"` | Type of service for Zabbix Web |
| zabbixWebService.startupProbe | object | `{}` | The kubelet uses startup probes to know when a container application has started.  Reference: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |

## Configure central database access related settings

All settings referring to how the different components that this Chart installs access the
Zabbix PostgreSQL Database (either an external, already existing database or one deployed within
this Helm chart) are being configured centrally under the ``postgresAccess`` section of the
``values.yaml`` file.

By default, this Chart will deploy it's own very simple PostgreSQL database. All settings
relevant to how to access this database will be held in one central unified secret with the
name configured with the ``postgresAccess.unifiedSecretName`` setting.

Instead of letting the Chart automatically generate such a secret with a random password
(which will NOT be recreated on upgrade/redeploy), you can supply such a secret yourself.
Use ``postgresAccess.unifiedSecretAutoCreate=false`` in such a case and read the comments
in ``values.yaml`` for how the values inside the secret should be set.

If you want to connect your Zabbix installation to a Postgres database deployed using the
[CrunchyData PGO Operator](https://access.crunchydata.com/documentation/postgres-operator/latest/),
you can use the secret that PGO generates for your DB automatically directly to connect Zabbix to it,
by just referring to its name with the ``postgresAccess.unifiedSecretName`` setting to it.

There is also the possibility to set all DB relevant settings directly inside the ``postgresAccess``
section of the ``values.yaml`` file by using the settings noted there
(``postgres_host``, ``postgres_user``, etc). If doing so, you still can use one single secret
to told just and only the database password. If you want to do so, supply the
``postgresAccess.passwordSecret`` and ``postgresAccess.passwordSecretKey``
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

## Configure the way how to expose Zabbix service

- **Ingress**: The ingress controller must be installed in the Kubernetes cluster.
- **IngressRoute**: The custom resource definition if you use the
[Traefik](https://traefik.io/traefik/) ingress controller.
- **Route**: The ingress controller used by Red Hat Openshift, based on HAProxy
- **ClusterIP**: Exposes the service on a cluster-internal IP. Choosing this value makes the
service only reachable from within the cluster.
- **NodePort**: Exposes the service on each Node's IP at a static port (the NodePort).
You'll be able to contact the NodePort service, from outside the cluster, by requesting
``NodeIP:NodePort``.
- **LoadBalancer**: Exposes the service externally using a cloud provider's load balancer.
