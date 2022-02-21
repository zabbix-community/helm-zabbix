<!-- TOC -->
- [About](#about)
- [How to Deploy Zabbix in Kubernetes](#how-to-deploy-zabbix-in-kubernetes)
- [Install nginx-ingress for services internal Kubernetes cluster](#install-nginx-ingress-for-services-internal-kubernetes-cluster)
<!-- TOC -->

# About

This page presents an example to use the [Zabbix Helm Chart](https://github.com/cetic/helm-zabbix). For more informations, see the [README.md](/README.md) file.

# How to Deploy Zabbix in Kubernetes

Create or access your Kubernetes cluster and configure the ``kubectl``.

Install Helm 3 (Visit the [requirements.md](../requirements.md) file.).

Clone this repository:

```bash
mkdir ~/mygit
cd ~/mygit
git clone https://github.com/cetic/helm-zabbix
cd ~/mygit/helm-zabbix
```

Edit ``~/mygit/helm-zabbix/docs/example/kind/values.yaml`` file.

Download the dependences charts.

```bash
helm repo add cetic https://cetic.github.io/helm-charts
helm repo update
```

Test the installation/upgrade with command (update the YAML files paths if necessary):

```bash
helm upgrade --install zabbix \
 --dependency-update \
 --create-namespace \
 -f ~/mygit/helm-zabbix/docs/example/kind/values.yaml \
 cetic/zabbix -n monitoring --debug --dry-run
```

Install/upgrade Zabbix in the Kubernetes cluster (update the YAML files paths if necessary).

```bash
helm upgrade --install zabbix \
 --dependency-update \
 --create-namespace \
 -f ~/mygit/helm-zabbix/docs/example/kind/values.yaml \
 cetic/zabbix -n monitoring --debug
```

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

Listen on port 8888 locally, forwarding to 80 in the service ``APPLICATION_NAME-zabbix-web``. Example:

```bash
kubectl port-forward service/zabbix-zabbix-web 8888:80 -n monitoring
```

Access Zabbix in http://localhost:8888. Login ``Admin`` and password ``zabbix``.

To uninstall the zabbix.

```bash
helm uninstall zabbix -n monitoring
```

# Install nginx-ingress for services internal Kubernetes cluster

In the **production** environment to allow external access to Zabbix installed on Kubernetes, you can configure ``nginx-ingress``, but there are other similar approaches that can be used. This was just a suggestion for users new to Kubernetes.

More informations about ``nginx-ingress`` can be found in the following tutorials.

* https://github.com/helm/charts/tree/master/stable/nginx-ingress
* https://github.com/kubernetes/ingress-nginx
* https://kubernetes.github.io/ingress-nginx/
* https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nginx-ingress-on-digitalocean-kubernetes-using-helm
* https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nginx-ingress-with-cert-manager-on-digitalocean-kubernetes
* https://asilearn.org/install-nginx-ingress-controller-on-kubernetes-9efb9765cc7a
* https://docs.nginx.com/nginx-ingress-controller/configuration/virtualserver-and-virtualserverroute-resources/
* https://github.com/nginxinc/kubernetes-ingress
* https://stackoverflow.com/questions/51597410/aws-eks-is-not-authorized-to-perform-iamcreateservicelinkedrole
* https://github.com/kubernetes/ingress-nginx/blob/master/docs/user-guide/nginx-configuration/annotations.md
* https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/
* https://docs.nginx.com/nginx-ingress-controller/configuration/ingress-resources/advanced-configuration-with-annotations/
* https://docs.giantswarm.io/guides/advanced-ingress-configuration/
* https://stackoverflow.com/questions/51874503/kubernetes-ingress-network-deny-some-paths
* https://www.edureka.co/community/19277/access-some-specific-paths-while-using-kubernetes-ingress
* https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/
* https://imti.co/kubernetes-ingress-nginx-cors/
* https://stackoverflow.com/questions/54083179/how-can-i-correctly-setup-custom-headers-with-nginx-ingress
