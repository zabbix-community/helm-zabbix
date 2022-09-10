# Helm Zabbix

This is the new home of the Zabbix helm chart. It is a fork from the [cetic/helm-zabbix](https://github.com/cetic/helm-zabbix).

In this [issue](https://github.com/cetic/helm-zabbix/issues/68) it was agreed with [Sebastien Dupont](https://github.com/banzothat) that the repository would get a new home.

We are grateful to [Cetic](https://www.cetic.be/) for making the infrastructure available on CircleCI to host the helm chart from the start. Now, the new versions will be hosted on Github.

We are very grateful to [Alexandre Nuttinck](https://github.com/alexnuttinck) and [Amen Ayadi](https://github.com/AyadiAmen), who were the first developers of the helm chart and who worked at Cetic. Your dedication and effort made it possible to install Zabbix on a Kubernetes cluster.

# About this chart

See the [file](charts/helm-zabbix/README.md).

The structure of files and directories had to be changed to make the automatic packaging of helm charts as simple as possible using Github Actions.

References:

* https://blog.bradmccoy.io/linking-helm-charts-in-github-pages-to-artifacthub-46e02e19abfe
* https://github.com/helm/chart-releaser-action
* https://helm.sh/docs/howto/chart_releaser_action/
* https://github.com/helm/chart-releaser-action/issues/36
