# zabbix

![Version: 3.1.7](https://img.shields.io/badge/Version-3.1.7-informational?style=flat-square) ![AppVersion: 6.0.8](https://img.shields.io/badge/AppVersion-6.0.8-informational?style=flat-square)

Zabbix is a mature and effortless enterprise-class open source monitoring solution for network monitoring and application monitoring of millions of metrics.

**Homepage:** <https://www.zabbix.com/>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Aecio Pires | <aeciopires@gmail.com> | <https://github.com/aeciopires> |
| Alexandre Nuttinck | <alexandre.nuttinck@cetic.be> | <https://github.com/alexnuttinck> |
| Amen Ayadi | <amen.ayadi@cetic.be> | <https://github.com/AyadiAmen> |
| Christian Anton | <christian.anton@secadm.de> | <https://secadm.de> |
| Sebastien Dupont | <sebastien.dupont@cetic.be> | <https://github.com/banzo> |

## Source Code

* <https://github.com/cetic/helm-zabbix>

## Values

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
| zabbix_image_tag | string | `"ubuntu-6.0.7"` | Zabbix components (server, agent, web frontend, ...) image tag to use. This helm chart is compatible with non-LTS version of Zabbix, that include important changes and functionalities. But by default this helm chart will install the latest LTS version (example: 6.0.x). See more info in [Zabbix Life Cycle & Release Policy](https://www.zabbix.com/life_cycle_and_release_policy) page When you want use a non-LTS version (example: 6.2.x), you have to set this yourself. You can change version here or overwrite in each component (example: zabbixserver.image.tag, etc). |
| zabbixagent.ZBX_ACTIVE_ALLOW | bool | `true` | This variable is boolean (true or false) and enables or disables feature of active checks |
| zabbixagent.ZBX_JAVAGATEWAY_ENABLE | bool | `false` | The variable enable communication with Zabbix Java Gateway to collect Java related checks. By default, value is false. |
| zabbixagent.ZBX_PASSIVESERVERS | string | `"127.0.0.1"` | The variable is comma separated list of allowed Zabbix server or proxy hosts for connections to Zabbix agent container. |
| zabbixagent.ZBX_PASSIVE_ALLOW | bool | `true` | This variable is boolean (true or false) and enables or disables feature of passive checks. By default, value is true |
| zabbixagent.ZBX_SERVER_HOST | string | `"127.0.0.1"` | Zabbix server host |
| zabbixagent.ZBX_SERVER_PORT | int | `10051` | Zabbix server port |
| zabbixagent.ZBX_VMWARECACHESIZE | string | `"128M"` | Cache size |
| zabbixagent.enabled | bool | `true` | Enables use of **Zabbix Agent** |
| zabbixagent.extraEnv | list | `[]` | Extra environment variables. A list of additional environment variables. See example: https://github.com/cetic/helm-zabbix/blob/master/docs/example/kind/values.yaml |
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
| zabbixproxy.extraEnv | list | `[]` | Extra environment variables. A list of additional environment variables. See example: https://github.com/cetic/helm-zabbix/blob/master/docs/example/kind/values.yaml |
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
| zabbixserver.extraEnv | list | `[]` | Extra environment variables. A list of additional environment variables. See example: https://github.com/cetic/helm-zabbix/blob/master/docs/example/kind/values.yaml |
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
| zabbixweb.extraEnv | list | `[]` | Extra environment variables. A list of additional environment variables. See example: https://github.com/cetic/helm-zabbix/blob/master/docs/example/kind/values.yaml |
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
| zabbixwebservice.extraEnv | list | `[]` | Extra environment variables. A list of additional environment variables. See example: https://github.com/cetic/helm-zabbix/blob/master/docs/example/kind/values.yaml |
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

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
