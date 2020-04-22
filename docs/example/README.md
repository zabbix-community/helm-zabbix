<!-- TOC -->
- [About](#about)
- [Prerequisites to develop and test Helm Charts](#prerequisites-to-develop-and-test-helm-charts)
- [How to Deploy Zabbix in Kubernetes](#how-to-deploy-zabbix-in-kubernetes)
<!-- TOC -->

# About

This page presents an example to use the [Zabbix Helm Chart](https://github.com/cetic/helm-zabbix). For more informations, see the [README.md](/README.md) file.

# Prerequisites to develop and test Helm Charts
 
Visit the [requirements.md](../requirements.md) file.

# How to Deploy Zabbix in Kubernetes

Create or access your Kubernetes cluster and configure the kubectl client.

Install Helm 3 (Visit the [requirements.md](../requirements.md) file.).

Install the plugin Helm secrets.

```bash
helm plugin install https://github.com/futuresimple/helm-secrets
```

Download and configure the parameters to deploy Zabbix.

```bash
cd ~
git clone https://github.com/cetic/helm-zabbix
```

Edit ``helm-zabbix/docs/example/minikube/values.yaml`` file.

Edit ``helm-zabbix/docs/example/minikube/secrets.yaml`` file with follow command or create your file of secrets and encrypt with ``helm secrets enc PATH_FILE_SECRETS`` command (see https://github.com/zendesk/helm-secrets). Where ``PATH_FILE_SECRETS`` must be replaced with the path to your new secrets file.

```bash
helm secrets edit helm-zabbix/docs/example/minikube/secrets.yaml
```

| Properties in secret.yaml file        | Default Values |
|:--------------------------------------|:---------------|
| zabbixServer.POSTGRES_PASSWORD        | zabbix         |
| zabbixproxy.MYSQL_PASSWORD            | zabbix         |
| postgresql.postgresqlPassword         | zabbix         |
| postgresql.postgresqlPostgresPassword | rootpasswd     |
| zabbixweb.POSTGRES_PASSWORD           | zabbix         |

Download the dependences charts.

```bash
helm repo add stable https://kubernetes-charts-incubator.storage.googleapis.com
helm repo add cetic https://cetic.github.io/helm-charts
helm repo update
```

List the namespaces of cluster.

```bash
kubectl get namespaces
```

Create the namespaces ``monitoring`` if it not exists in cluster.

```bash
kubectl create namespace monitoring
```

Deploy Zabbix in the Kubernetes cluster. (Update the YAML files paths if necessary)

```bash
helm secrets upgrade zabbix \
 -f ~/helm-zabbix/docs/example/minikube/values.yaml \
 -f ~/helm-zabbix/docs/example/minikube/secrets.yaml \
 cetic/zabbix -n monitoring --install
```

View the pods.

```bash
kubectl get pods -n monitoring
```

View informations of pods.

```bash
kubectl describe pods/NAME_POD -n monitoring
```

View all containers of pod.

```bash
kubectl get pods NAME_POD -n monitoring -o jsonpath='{.spec.containers[*].name}*'
```

View the logs container of pods.

```bash
kubectl logs -f pods/NAME_POD -c NAME_CONTAINER -n monitoring
```

Access prompt of container.

```bash
kubectl exec -it pods/NAME_POD -c NAME_CONTAINER -n monitoring -- sh
```

View informations of service Grafana.

```bash
kubectl get svc
kubectl get pods --output=wide -n monitoring
kubectl describe services zabbix -n monitoring
```

Listen on port 8888 locally, forwarding to 80 in the pod

```bash
kubectl port-forward deployment/zabbix-web 8888:80 -n monitoring
```

Access Zabbix in http://localhost:8888. Login ``Admin`` and password ``zabbix``.

To uninstall the zabbix.

```bash
helm delete zabbix -n monitoring
```
