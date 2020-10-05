# Basic Commands of Helm 3

Help of ``helm`` command:

```bash
helm --help
```

Add Helm repo official stable charts:

```bash
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
```

Update the list helm chart available for installation (like ``apt-get update``). This is recommend before install/upgrade a helm chart:

```bash
helm repo update
```

List the helm repositories installed in your local environment:

```bash
helm repo list
```

Repositories can be removed with command:

```bash
helm repo remove
```

Once this is installed, you will be able to list the charts you can install:

```bash
helm search repo stable
```

Searches in the Helm Hub, which comprises helm charts from dozens of different repositories.

```bash
helm search hub
```

Searches the repositories that you have added to your local environment. This search is done over local data and no network connection is needed.

```bash
helm search repo
```

Use the command to see informations of chart :

```bash
helm show chart HELM_REPO_NAME/CHART_NAME
```

Use the command to see documentation of chart:

```bash
helm show readme HELM_REPO_NAME/CHART_NAME
```

Use the command to see what default options of a chart:

```bash
helm show values HELM_REPO_NAME/CHART_NAME
```

List installed charts in Kubernetes cluster:

```bash
helm list --all-namespaces

# or

helm list -n NAMESPACE
```

Use the command if you want to see what the default values were used for this installation:

```bash
helm get values APPLICATION_NAME -n NAMESPACE
```

View the change history of the application installed with ``helm``. You will see revision number for each change/upgrade of application:

```bash
helm history APPLICATION_NAME -n NAMESPACE
```

Use the commando to do rollback of application to specific revision number:

```bash
helm rollback APPLICATION_NAME REVISION_NUMBER -n NAMESPACE
```

Remove a application installed with ``helm`` in Kubernetes cluster:

```bash
helm uninstall APPLICATION_NAME -n NAMESPACE
```

More informations and commands about helm:

* https://helm.sh/docs/intro/quickstart
* https://helm.sh/docs/intro/using_helm