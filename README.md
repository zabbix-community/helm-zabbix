# Helm Zabbix

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) [![Downloads](https://img.shields.io/github/downloads/zabbix-community/helm-zabbix/total?label=Downloads
)](https://tooomm.github.io/github-release-stats/?username=zabbix-community&repository=helm-zabbix) [![Releases ChangeLog](https://img.shields.io/badge/Changelog-8A2BE2
)](https://github.com/zabbix-community/helm-zabbix/releases)

<!-- TOC -->

- [Helm Zabbix](#helm-zabbix)
  - [About this chart](#about-this-chart)
  - [Contributing](#contributing)
  - [Examples](#examples)
  - [Important links](#important-links)
    - [Related to this helm chart](#related-to-this-helm-chart)
    - [Related to Zabbix](#related-to-zabbix)
  - [Contributors](#contributors)
    - [Maintainers](#maintainers)
  - [History](#history)
  - [License](#license)

<!-- TOC -->

## About this chart

See the [charts/zabbix/README.md](charts/zabbix/README.md) file to learn more about this helm chart or access [Artifact Hub](https://artifacthub.io/packages/helm/zabbix-community/zabbix).

> This Helm chart installs [Zabbix](https://www.zabbix.com) in a Kubernetes cluster. It supports only Postgresql/TimescaleDB as a database backend at this point in time, without any plans to extend database support towards MySQL, MariaDB, etc. Also, this Helm Chart supports [Zabbix Server High Availability](charts/zabbix/#native-zabbix-server-high-availability)

## Contributing

See the [CONTRIBUTING.md](CONTRIBUTING.md) file to learn how to contribute to this helm chart.

## Examples

See the [charts/zabbix/docs/example/README.md](charts/zabbix/docs/example/README.md) file to install this helm chart in [kind](https://kind.sigs.k8s.io) cluster.

## Important links

### Related to this helm chart

- Open issue, bug or feature request: https://github.com/zabbix-community/helm-zabbix/issues
- Ask help: https://github.com/zabbix-community/helm-zabbix/discussions
- Releases and Changelog: https://github.com/zabbix-community/helm-zabbix/releases
- Artifact Hub: https://artifacthub.io/packages/helm/zabbix-community/zabbix
- Closed issues: https://github.com/zabbix-community/helm-zabbix/issues?q=is%3Aissue+is%3Aclosed
- Closed PRs: https://github.com/zabbix-community/helm-zabbix/pulls?q=is%3Apr+is%3Aclosed
- Download statistics: https://tooomm.github.io/github-release-stats/?username=zabbix-community&repository=helm-zabbix
- Presentations:
  - Video: [Install and operate Zabbix in Kubernetes and OpenShift by Christian Anton / Zabbix Summit 2022](https://youtu.be/NU3FsXQp_rE?si=LjXsxjjrZd_VDEDU&t=150)
  - Slides: [Install and operate Zabbix in Kubernetes and OpenShift by Christian Anton / Zabbix Summit 2022](https://assets.zabbix.com/files/events/2022/zabbix_summit_2022/Christian_Anton_Install_and_operate_Zabbix_in_Kubernetes_and_OpenShift.pdf)

### Related to Zabbix

- Official page: https://www.zabbix.com
- Documentation: https://www.zabbix.com/manuals
- Community support: https://www.zabbix.com/forum
- Open issues: https://support.zabbix.com/projects/ZBX/issues/ZBX-25876?filter=allopenissues
- Open feature requests: https://support.zabbix.com/projects/ZBXNEXT/issues/ZBXNEXT-8875?filter=allopenissues

## Contributors

<a href = "https://github.com/zabbix-community/helm-zabbix/graphs/contributors">
  <img src = "https://contrib.rocks/image?repo=zabbix-community/helm-zabbix"/>
</a>

Made with [contributors-img](https://contrib.rocks).

<!-- Reference: https://github.com/Tanu-N-Prabhu/myWebsite.io/blob/master/Docs/Displaying%20Contributors%20Image%20on%20README%20files%20with%20no%20Pain!.md#contributors-displayed-by-using-contributors-img-on-the-readmemd-file -->

### Maintainers

- [Aecio dos Santos Pires](https://www.linkedin.com/in/aeciopires/)
- [Christian Anton](https://www.linkedin.com/in/christiananton1/)

## History

See the [HISTORY.md](HISTORY.md) file.

## License

[Apache 2.0 License](https://github.com/zabbix-community/helm-zabbix/blob/main/LICENSE).
