<!-- TOC -->
- [About](#about)
- [Installation](#installation)
- [How to access Zabbix](#how-to-access-zabbix)
- [Troubleshooting](#troubleshooting)
- [Uninstallation](#uninstallation)
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
 $HOME/mygit/helm-zabbix/charts/zabbix -n monitoring --debug --dry-run=client
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

