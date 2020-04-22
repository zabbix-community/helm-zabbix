<!-- TOC -->
- [Prerequisites to develop and test Helm Charts](#prerequisites-to-develop-and-test-helm-charts)  
  - [Kubernetes Cluster](#kubernetes-cluster)
  - [Install Docker-CE](#install-docker-ce)
  - [Install Kubectl](#install-kubectl)
  - [Install Helm 3](#install-helm-3)
  - [Install Sops](#install-sops)
- [Basic Commands of Helm 3](#basic-commands-of-helm-3)
  - [More Installation Methods](#more-installation-methods)

<!-- TOC -->

# Prerequisites to develop and test Helm Charts

## Kubernetes Cluster

You will need to create a Kubernetes cluster locally using [minikube](https://kubernetes.io/docs/tasks/tools/install-minikube), [microk8s](https://microk8s.io), [kind](https://kind.sigs.k8s.io), [k3s](https://k3s.io) or other tools.

Or use Kubernetes cluster in [EKS](https://aws.amazon.com/eks), [GKE](https://cloud.google.com/kubernetes-engine), [AKS](https://docs.microsoft.com/en-us/azure/aks), [DOKS](https://www.digitalocean.com/products/kubernetes) or other cloud provider.

## Install Docker-CE

Follow instructions of page for install Docker-CE.

* Ubuntu: https://docs.docker.com/install/linux/docker-ce/ubuntu/
* Debian: https://docs.docker.com/install/linux/docker-ce/debian/
* CentOS: https://docs.docker.com/install/linux/docker-ce/centos/
* MacOS: https://docs.docker.com/docker-for-mac/install/

## Install Kubectl

Simple shell function for Kubectl installation in Linux 64 bits

Kubectl documentation:

https://kubernetes.io/docs/reference/kubectl/overview/

Copy and paste this code:

```bash
sudo su
 
KUBECTL_BIN=kubectl
 
function install_kubectl {
if [ -z $(which $KUBECTL_BIN) ]; then
    curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/$KUBECTL_BIN
    chmod +x ${KUBECTL_BIN}
    sudo mv ${KUBECTL_BIN} /usr/local/bin/${KUBECTL_BIN}
else
    echo "Kubectl is most likely installed"
fi
}
 
install_kubectl
 
which kubectl
 
kubectl version
 
exit
```

---

Credits: Juan Pablo Perez - https://www.linkedin.com/in/juanpabloperezpeelmicro/ 

https://github.com/peelmicro/learn-devops-the-complete-kubernetes-course

---

## Install Helm 3

Execute these commands to install helm 3.

Documentation: https://helm.sh/docs/

```bash
sudo su

HELM_TAR_FILE=helm-v3.0.3-linux-amd64.tar.gz
HELM_URL=https://get.helm.sh
HELM_BIN=helm3

function install_helm3 {

if [ -z $(which $HELM_BIN) ]; then
    wget ${HELM_URL}/${HELM_TAR_FILE}
    tar -xvzf ${HELM_TAR_FILE}
    chmod +x linux-amd64/helm
    sudo cp linux-amd64/helm /usr/local/bin/$HELM_BIN
    sudo ln -sfn /usr/local/bin/$HELM_BIN /usr/local/bin/helm
    rm -rf ${HELM_TAR_FILE} linux-amd64
    echo -e "\nwhich ${HELM_BIN}"
    which ${HELM_BIN}
else
    echo "Helm 3 is most likely installed"
fi
}

install_helm3

which helm3

helm3 version

exit
```

---

Credits: Juan Pablo Perez - https://www.linkedin.com/in/juanpabloperezpeelmicro/ 

https://github.com/peelmicro/learn-devops-the-complete-kubernetes-course

---

# Basic Commands of Helm 3

Add Helm repo official stable charts:

```bash
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo list
```

Repositories can be removed with `helm repo remove` command.

Once this is installed, you will be able to list the charts you can install:

```bash
helm search repo stable
```

Searches the Helm Hub, which comprises helm charts from dozens of different repositories.

```bash
helm search hub
```

Searches the repositories that you have added to your local helm client (with `helm repo add`). This search is done over local data, and no public network connection is needed.

```bash
helm search repo
```

Install chart of MySQL with default config.

```bash
helm repo update
helm install mydatabase stable/mysql
```

To see what options are configurable on a chart, use the command `helm show values`:

```bash
helm show values stable/mysql
```

List installed charts in Kubernetes cluster.

```bash
helm list --all
```

When a new version of a chart is released, or when you want to change the configuration of your release, you can use the `helm upgrade` command.

```bash
helm upgrade -f values.yaml mydatabase stable/mysql
```

Now, if something does not go as planned during a release, it is easy to roll back to a previous release using `helm rollback [RELEASE] [REVISION]`.

```bash
helm rollback mydatabase 1
```

The above rolls back our `mydatabase` to its very first release version. A release version is an incremental revision. Every time an install, upgrade, or rollback happens, the revision number is incremented by 1. The first revision number is always 1. And we can use helm history [RELEASE] to see revision numbers for a certain release.

Uninstall chart of MySQL.

```bash
helm uninstall mydatabase
```

Optionally if you provide the flag `--keep-history` in uninstall command, the release history will be kept. You will be able to request information about that release:

```bash
helm status mydatabase
```

Because Helm tracks your releases even after you’ve uninstalled them, you can audit a cluster’s history, and even undelete a release (with helm rollback).

---

Credits: Helm Doc Community

* https://helm.sh/docs/intro/quickstart
* https://helm.sh/docs/intro/using_helm

---

## More Installation Methods

The helm install command can install from several sources:

* A chart repository (as we’ve seen above)
* A local chart archive (`helm install foo foo-0.1.1.tgz`)
* An unpacked chart directory (`helm install foo path/to/foo`)
* A full URL (`helm install foo https://example.com/charts/foo-1.2.3.tgz`)

---

Credits: Helm Doc Community

* https://helm.sh/docs/intro/quickstart
* https://helm.sh/docs/intro/using_helm
