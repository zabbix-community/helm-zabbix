<!-- TOC -->

- [Prerequisites to develop and test Helm Charts](#prerequisites-to-develop-and-test-helm-charts)
- [General Packages](#general-packages)
- [Kubernetes cluster](#kubernetes-cluster)
- [Docker](#docker)
  - [Docker on Linux](#docker-on-linux)
  - [Colima on macOS](#colima-on-macos)
- [mise](#mise)
- [Helm, Helm Docs, Kind, Kubectl and Argo CD CLI](#helm-helm-docs-kind-kubectl-and-argo-cd-cli)
- [Using make](#using-make)
  - [Checking the requirements](#checking-the-requirements)
  - [Testing the chart in a cluster](#testing-the-chart-in-a-cluster)

<!-- TOC -->

# Prerequisites to develop and test Helm Charts

# General Packages

Install the follow packages in your operating system:

- ``git``
- ``make``

# Kubernetes cluster

You will need to create a Kubernetes cluster locally using [minikube](https://kubernetes.io/docs/tasks/tools/install-minikube), [microk8s](https://microk8s.io), [kind](https://kind.sigs.k8s.io), [k3s](https://k3s.io) or other tools.

Or use Kubernetes cluster in [EKS](https://aws.amazon.com/eks), [GKE](https://cloud.google.com/kubernetes-engine), [AKS](https://docs.microsoft.com/en-us/azure/aks), [DOKS](https://www.digitalocean.com/products/kubernetes) or other cloud provider.

# Docker

Docker is not installed by ``mise``. Install it according to your operating system.

## Docker on Linux

Follow instructions of page for install Docker-CE.

- Ubuntu: https://docs.docker.com/engine/install/ubuntu/
- Debian: https://docs.docker.com/engine/install/debian/
- CentOS: https://docs.docker.com/engine/install/centos/

Start the Docker service, configure Docker to boot up with the OS and add your user to the Docker group.

```bash
# Start the Docker service
sudo systemctl start docker

# Configure Docker to boot up with the OS
sudo systemctl enable docker

# Add your user to the Docker group
sudo usermod -aG docker $USER
sudo setfacl -m user:$USER:rw /var/run/docker.sock
```

Source: https://docs.docker.com/engine/install/linux-postinstall/#configure-docker-to-start-on-boot

## Colima on macOS

[Colima](https://github.com/abiosoft/colima) runs Docker in a virtual machine on macOS, on both arm64 and amd64. Install [Homebrew](https://brew.sh) and run the following command to install Colima and the Docker client:

```bash
brew install colima docker
```

Start Colima. The CPU, memory (GiB) and disk (GiB) values are an example, adjust them according to your computer. Colima also configures itself as the active Docker context.

```bash
colima start --cpu 4 --memory 8 --disk 60

# Check
colima status
docker run --rm hello-world
```

**Permissions**: the ``usermod`` and ``setfacl`` commands of the Linux section are not needed. The Docker socket is in your home directory, at ``$HOME/.colima/default/docker.sock``, and your user already has access to it.

If an application shows the error ``Cannot connect to the Docker daemon at unix:///var/run/docker.sock``, it is not using the Docker context. Point it to the Colima socket:

```bash
echo 'export DOCKER_HOST="unix://$HOME/.colima/default/docker.sock"' >> ~/.zshrc
source ~/.zshrc
```

If you also have another Docker installation, select Colima with ``docker context use colima``.

**Start and stop manually**:

```bash
colima start
colima stop
```

**Start automatically**: Colima runs as a service of your user, so it starts when you log in to macOS and not when the computer boots.

```bash
# Start Colima now and at every login
brew services start colima

# Check the service
brew services list

# Stop Colima and remove it from the login
brew services stop colima
```

While the service is enabled, use ``brew services stop colima`` instead of ``colima stop``, because the service can start Colima again after it stops.

Documentation: https://github.com/abiosoft/colima/blob/main/docs/FAQ.md

# mise

[mise](https://mise.jdx.dev) installs the tools used in this repository, in the versions defined in the [mise.toml](../../../mise.toml) file. These instructions work on Ubuntu 22.04, 24.04 and 26.04 (amd64) and on macOS (arm64 and amd64).

Run the following commands to install ``mise`` on Ubuntu or macOS:

```bash
curl -fsSL https://mise.run | sh
```

If your shell is ``bash`` (default on Ubuntu), run:

```bash
echo 'eval "$($HOME/.local/bin/mise activate bash)"' >> ~/.bashrc
source ~/.bashrc
```

If your shell is ``zsh`` (default on macOS), run:

```bash
echo 'eval "$($HOME/.local/bin/mise activate zsh)"' >> ~/.zshrc
source ~/.zshrc
```

To update ``mise``, run:

```bash
mise self-update
```

Documentation: https://mise.jdx.dev/getting-started.html

# Helm, Helm Docs, Kind, Kubectl and Argo CD CLI

Run the following commands in the root directory of this repository to install ``helm``, ``helm-docs``, ``kind``, ``kubectl`` and ``argocd``:

```bash
mise trust
mise install
```

Check the installed versions:

```bash
mise list --current
helm version
helm-docs --version
kind version
kubectl version --client
argocd version --client
```

These versions are only active inside this repository directory. To change a version, edit the ``mise.toml`` file or run the following commands:

```bash
# Show the tools with a newer version available
mise outdated --bump

# Set the version of a tool in the mise.toml file and install it
mise use helm@VERSION
```

Documentation:

- Helm: https://helm.sh/docs
- Helm Docs: https://github.com/norwoodj/helm-docs
- Kind: https://kind.sigs.k8s.io
- Kubectl: https://kubernetes.io/docs/reference/kubectl/overview/
- Argo CD CLI: https://argo-cd.readthedocs.io/en/stable/user-guide/commands/argocd/

The documentation generated by ``helm-docs`` is based on the contents of the ``values.yaml``, ``README.md.gotmpl`` and ``Chart.yaml`` file. It tries to overwrite the contents of the ``README.md`` file within the chart directory.

# Using make

Run the following commands in the ``charts/zabbix`` directory. Use ``make help`` to list all targets.

The Docker images used by the ``lint``, ``package`` and ``gen-docs`` targets use the versions of ``helm`` and ``helm-docs`` defined in the ``mise.toml`` file.

## Checking the requirements

```bash
# Check if the operating system is supported
make check-os

# Check if the dependencies are installed and show the missing ones
make check-deps

# Install mise and the tools of the mise.toml file (Docker is installed separately)
make install-deps
```

The ``make install-deps`` command installs ``mise`` if needed and runs ``mise trust`` and ``mise install``. It only runs on a supported operating system: Ubuntu 22.04, 24.04 and 26.04 (amd64) and macOS (arm64 and amd64). If it installs ``mise``, activate it in your shell as described in the [mise](#mise) section.

## Testing the chart in a cluster

```bash
# Create only the kind cluster and select it as the current cluster
make kind-create

# Install or upgrade the helm chart in the current cluster
make deploy

# Uninstall the helm chart from the current cluster
make undeploy

# Install or upgrade only Argo CD in the current cluster
make argocd-install

# Deploy or remove the local chart using Argo CD in the current cluster (for tests only)
make argocd-deploy
make argocd-undeploy

# Create the kind cluster, install Argo CD and deploy the helm chart with helm
make stack-up

# Remove the complete stack by deleting the kind cluster
make stack-down
```

See more about Argo CD in this [tutorial](example/argocd/README.md).

> Attention!!!
> The ``deploy``, ``undeploy`` and ``argocd-*`` targets act on the current cluster of ``kubectl``, whichever it is. Check it with ``kubectl config current-context`` before running them.

The ``kind-create`` target creates a cluster with 3 nodes using the [kind-3nodes.yaml](example/kind/kind-3nodes.yaml) file. This file maps the ports ``80`` and ``443`` of the computer to the cluster, so these ports must be free.

The ``undeploy`` target keeps the volumes (PVC) of the PostgreSQL database, if any. The ``stack-down`` target deletes the kind cluster and all its data.

The ``deploy`` target uses the default values of the chart and ``stack-up`` uses the [kind example values](example/kind/values.yaml). These variables can be changed in the command line:

| Variable | Default | Used by |
|---|---|---|
| ``KIND_CLUSTER_NAME`` | ``helm-zabbix`` | ``kind-create``, ``stack-up``, ``stack-down`` |
| ``KIND_CONFIG`` | ``docs/example/kind/kind-3nodes.yaml`` | ``kind-create``, ``stack-up`` |
| ``RELEASE_NAME`` | ``zabbix`` | ``deploy``, ``undeploy``, ``stack-up`` |
| ``NAMESPACE`` | ``monitoring`` | ``deploy``, ``undeploy``, ``stack-up`` |
| ``DEPLOY_TIMEOUT`` | ``10m`` | ``deploy``, ``stack-up`` |
| ``VALUES_FILE`` | (empty) | ``deploy`` |
| ``STACK_VALUES_FILE`` | ``docs/example/kind/values.yaml`` | ``stack-up`` |
| ``ARGOCD_TIMEOUT`` | ``15m`` | ``argocd-install``, ``argocd-deploy``, ``argocd-undeploy``, ``stack-up`` |

Example:

```bash
make deploy NAMESPACE=zabbix VALUES_FILE=$HOME/zabbix_values.yaml
```
