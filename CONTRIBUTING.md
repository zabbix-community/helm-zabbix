<!-- TOC -->

- [Contributing](#contributing)
  - [For code mainteners only](#for-code-mainteners-only)
- [About Visual Code (VSCode)](#about-visual-code-vscode)

<!-- TOC -->

# Contributing

- Configure authentication on your Github account to use the SSH protocol instead of HTTP. Watch this tutorial to learn how to set up: https://help.github.com/en/github/authenticating-to-github/adding-a-new-ssh-key-to-your-github-account
- Have the ``make`` and ``docker`` commands installed on your system. With this, you don't need the below mentioned ``helm`` and use containers for the needed steps instead. See this [tutorial](charts/zabbix/docs/requirements.md).
- Create a fork this repository.
- Clone the forked repository to your local system:

```bash
git clone FORKED_REPOSITORY
```

- Add the address for the remote original repository:

```bash
git remote -v
git remote add upstream git@github.com:zabbix-community/helm-zabbix.git
git remote -v
```

- Create a branch. Example:

```bash
git checkout -b BRANCH_NAME
```

- Make sure you are on the correct branch using the following command. The branch in use contains the '*' before the name.

```bash
git branch
```

- Make your changes and tests to the new branch.
- Keep the ``charts/zabbix/values.yaml`` file updated with working default values ​​in case any variables are referenced in the helm chart template files
- Verify your changes do not introduce syntactical/semantic errors:
- Do NOT change ``version`` in ``charts/zabbix/chart.yaml`` nor in ``charts/zabbix/artifacthub-pkg.yml``, as this is now part of the release process issued by the code owners
- Make any changes you want in ``charts/zabbix/README.md`` in ``charts/zabbix/README.md.gotmpl``, out of which ``charts/zabbix/README.md`` will be generated using ``helm-docs`` during the version release process by the code owners

Method to check for syntactical/semantic errors using ``make`` and ``docker``:

```bash
cd charts/zabbix
make lint
```

- Method using locally installed ``helm`` command:

```bash
cd charts/zabbix
helm lint .
```

- Commit the changes to the branch.
- Push files to repository remote with command:

```bash
git push --set-upstream origin BRANCH_NAME
```

- Create Pull Request (PR) to the `main` branch. See this [tutorial](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request-from-a-fork)
- Update the content with the suggestions of the reviewer (if necessary).
- After your pull request is merged to the `main` branch, update your local clone:

```bash
git checkout main
git pull upstream main
```

- Clean up after your pull request is merged with command:

```bash
git branch -d BRANCH_NAME
```

- Then you can update the ``main`` branch in your forked repository.

```bash
git push origin main
```

- And push the deletion of the feature branch to your GitHub repository with command:

```bash
git push --delete origin BRANCH_NAME
```

- To keep your fork in sync with the original repository, use these commands:

```bash
git pull upstream main
git pull upstream main --tags

git push origin main
git push origin main --tags
```

References:

- https://blog.scottlowe.org/2015/01/27/using-fork-branch-git-workflow/

## For code mainteners only

To generate a new release of the helm chart, follow these instructions:

- Review and merge the opened PRs
- Run local tests
- Create a branch. Example:

```bash
git checkout -b BRANCH_NAME
```

Make sure you are on the correct branch using the following command. The branch in use will show with a '*' before the name.

```bash
git branch
```

- Make your changes and tests to the new branch
- Verify the syntax errors using the follow commands:

```bash
cd charts/zabbix
make lint
```

- Analyse the changes of the PRs merged and set a new release using the follow approach:

A **major** version" should be the "dot-release". Example: *6.0.2* -> *6.1.0* is be a **major release update**. Users have to check whether they have to modify their values.yaml, and we need to write a short explanation of what has changed in the ``chart/zabbix/README.md.gotmpl``.

A **minor** is the "dot-dot" release. Example: *6.0.2* -> *6.0.3* is **minor upgrade**, no changes in any APIs, interfaces etc. should be necessary.

- Change the ``version`` and ``appVersion`` parameters (helm chart and Zabbix version, respectively) in ``charts/zabbix/Chart.yaml`` and ``charts/zabbix/artifacthub-pkg.yml`` files.
- Change the ``zabbixImageTag`` value (Zabbix version) in ``charts/zabbix/values.yaml`` file.
- Change the ``createdAt`` parameter in ``charts/zabbix/artifacthub-pkg.yml`` file using the output of the command ``date +%Y-%m-%dT%TZ`` command.
- Change the ``ZABBIX_CHART_VERSION`` variable in ``charts/zabbix/artifacthub-pkg.yml`` file.
- Run the following commands to update the documentation of the helm chart.

```bash
cd charts/zabbix
make gen-docs
```

- Commit the changes to the branch.
- Push files to repository remote with command:

```bash
git push --set-upstream origin BRANCH_NAME
```

- Create Pull Request (PR) to the main branch. See this [tutorial](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request-from-a-fork)
- Update the content with the suggestions of the reviewer (if necessary).
- After your pull request is merged to the main branch, update your local clone:

```bash
git checkout main
git pull upstream main
```

- Clean up after your pull request is merged with command:

```bash
git branch -d BRANCH_NAME
```

Then you can update the main branch in your forked repository.

```bash
git push origin main
```

And push the deletion of the feature branch to your GitHub repository with command:

```bash
git push --delete origin BRANCH_NAME
```

- Create a new tag to generate a new release of the helm chart using the following commands:

```bash
git tag -a 7.0.8 -m "New release" #example
git push upstream --tags
```

- The before commands will start the pipeline and will generate a new release and tag in standard ``zabbix-x.y.z``.
- To keep your fork in sync with the original repository, use these commands:

```bash
git pull upstream main
git pull upstream main --tags

git push origin main
git push origin main --tags
```

- After this, edit and adjust the text generated automatically for new release and adjust the release notes follow the examples the other releases published in https://github.com/zabbix-community/helm-zabbix/releases

References:

- https://blog.scottlowe.org/2015/01/27/using-fork-branch-git-workflow/

# About Visual Code (VSCode)

Use a IDE (Integrated Development Environment) or text editor of your choice. By default, the use of VSCode is recommended.

VSCode (https://code.visualstudio.com), combined with the following plugins, helps the editing/review process, mainly allowing the preview of the content before the commit, analyzing the Markdown syntax and generating the automatic summary, as the section titles are created/changed.

Plugins to Visual Code:

- docker: https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker (require docker-ce package)
- gitlens: https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens (require git package)
- gotemplate-syntax: https://marketplace.visualstudio.com/items?itemName=casualjim.gotemplate
- Markdown-all-in-one: https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one
- Markdown-lint: https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint
- Markdown-toc: https://marketplace.visualstudio.com/items?itemName=AlanWalk.markdown-toc
- shellcheck: https://marketplace.visualstudio.com/items?itemName=timonwong.shellcheck (require shellcheck package)
- YAML: https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml
- Helm Intellisense: https://marketplace.visualstudio.com/items?itemName=Tim-Koehler.helm-intellisense

Theme for VSCode:

- https://code.visualstudio.com/docs/getstarted/themes
- https://dev.to/thegeoffstevens/50-vs-code-themes-for-2020-45cc
- https://vscodethemes.com/
