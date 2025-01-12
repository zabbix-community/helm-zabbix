<!-- TOC -->
- [About](#about)
- [Installation](#installation)
- [How to access Zabbix](#how-to-access-zabbix)
- [Troubleshooting](#troubleshooting)
- [Uninstallation](#uninstallation)
- [Install nginx-ingress for services internal Kubernetes cluster](#install-nginx-ingress-for-services-internal-kubernetes-cluster)
<!-- TOC -->

# About

An example to use the [Zabbix Helm Chart](https://github.com/zabbix-community/helm-zabbix) in [kind](https://kind.sigs.k8s.io) cluster.

# Installation

Install the [requirements](../requirements.md).

Access the Kubernetes cluster.

Clone this repository:

```bash
mkdir $HOME/mygit
cd $HOME/mygit
git clone https://github.com/zabbix-community/helm-zabbix
cd $HOME/mygit/helm-zabbix
```

Edit ``$HOME/mygit/helm-zabbix/charts/zabbix/docs/example/kind/values.yaml`` file. The items of section [Configuration](../../README.md#configuration) can be set via ``--set`` flag in installation command or change the values according to the need of the environment in ``$HOME/mygit/helm-zabbix/charts/zabbix/docs/example/kind/values.yaml`` file.

Test the installation/upgrade with the command:

```bash
helm upgrade --install zabbix \
 --dependency-update \
 --create-namespace \
 -f $HOME/mygit/helm-zabbix/charts/zabbix/docs/example/kind/values.yaml \
 $HOME/mygit/helm-zabbix/charts/zabbix -n monitoring --debug --dry-run
```

Install/upgrade Zabbix with the command:

```bash
helm upgrade --install zabbix \
 --dependency-update \
 --create-namespace \
 -f $HOME/mygit/helm-zabbix/charts/zabbix/docs/example/kind/values.yaml \
 $HOME/mygit/helm-zabbix/charts/zabbix -n monitoring --debug
```

# How to access Zabbix

See [README.md](../../README.md#how-to-access-zabbix).

# Troubleshooting

See [README.md](../../README.md#troubleshooting).

# Uninstallation

See [README.md](../../README.md#uninstallation).

# Install nginx-ingress for services internal Kubernetes cluster

In the **production** environment to allow external access to Zabbix installed on Kubernetes, you can configure ``nginx-ingress``, but there are other similar approaches that can be used. This was just a suggestion for users new to Kubernetes.

More information about ``nginx-ingress`` can be found in the following tutorials.

- https://github.com/helm/charts/tree/master/stable/nginx-ingress
- https://github.com/kubernetes/ingress-nginx
- https://kubernetes.github.io/ingress-nginx/
- https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nginx-ingress-on-digitalocean-kubernetes-using-helm
- https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nginx-ingress-with-cert-manager-on-digitalocean-kubernetes
- https://asilearn.org/install-nginx-ingress-controller-on-kubernetes-9efb9765cc7a
- https://docs.nginx.com/nginx-ingress-controller/configuration/virtualserver-and-virtualserverroute-resources/
- https://github.com/nginxinc/kubernetes-ingress
- https://stackoverflow.com/questions/51597410/aws-eks-is-not-authorized-to-perform-iamcreateservicelinkedrole
- https://github.com/kubernetes/ingress-nginx/blob/master/docs/user-guide/nginx-configuration/annotations.md
- https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/
- https://docs.nginx.com/nginx-ingress-controller/configuration/ingress-resources/advanced-configuration-with-annotations/
- https://docs.giantswarm.io/guides/advanced-ingress-configuration/
- https://stackoverflow.com/questions/51874503/kubernetes-ingress-network-deny-some-paths
- https://www.edureka.co/community/19277/access-some-specific-paths-while-using-kubernetes-ingress
- https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/
- https://imti.co/kubernetes-ingress-nginx-cors/
- https://stackoverflow.com/questions/54083179/how-can-i-correctly-setup-custom-headers-with-nginx-ingress
