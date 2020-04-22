<!-- TOC -->

- [Contributing](#contributing)

<!-- TOC -->

# Contributing

* Install the follow packages: git, kubectl, helm. See this [tutorial](docs/requirements.md)
* Create a fork this repository.
* Clone the forked repository to your local system.
* Add a Git remote for the original repository.

```bash
git remote -v
git remote add upstream https://github.com/cetic/helm-zabbix
git remote -v
```

* Create a branch using the pattern: `git checkout -b US-${DEV_NAME}`. Example: *git checkout -b US-AECIO*
* Make your changes to the new branch.
* Test your changes in 'development' environment
* Commit the changes to the branch.
* Push files to repository remote with command `git push --set-upstream origin US-${DEV_NAME}`. Example: *git push --set-upstream origin US-AECIO*
* Create Pull Request (PR) to the `master` branch. See [tutorial](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request-from-a-fork)
* Update the content with the suggestions of the reviewer (if necessary)
* After your pull request is merged, update your local clone.

```bash
git pull upstream master
```

* Clean up after your pull request is merged with command `git branch -d <branch name>`. Example: *git branch -d US-AECIO*
* Then you can update the master branch in your forked repository.

```bash
git push origin master
```

* And push the deletion of the feature branch to your GitHub repository with command `git push --delete origin <branch name>`. Example: *git push --delete origin US-AECIO*
* To keep your fork in sync with the original repository, use these commands:

```bash
git pull upstream master
git push origin master
```

Reference: 
* https://blog.scottlowe.org/2015/01/27/using-fork-branch-git-workflow/