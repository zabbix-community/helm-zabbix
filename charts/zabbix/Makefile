#---------------------------
#---------------------------
# VARIABLES
#---------------------------
#---------------------------

URL=https://github.com/zabbix-community/helm-zabbix/
REQUIREMENTS_DOC=charts/zabbix/docs/requirements.md
CHART_DIR:=$(abspath $(dir $(lastword $(MAKEFILE_LIST))))
REPO_ROOT:=$(abspath $(CHART_DIR)/../..)
MISE_TOML:=$(REPO_ROOT)/mise.toml
# Versions of the tools are defined only in the mise.toml file
MISE_TOOLS:=$(shell sed -n '/^\[tools\]/,/^\[env\]/s/^\([a-zA-Z0-9_-]*\) *= *".*/\1/p' "$(MISE_TOML)")
ARGOCD_CHART_VERSION:=$(shell sed -n 's/^ARGOCD_CHART_VERSION *= *"\(.*\)"/\1/p' "$(MISE_TOML)")
HELM_VERSION:=$(shell sed -n 's/^helm *= *"\(.*\)"/\1/p' "$(MISE_TOML)")
HELM_DOCS_VERSION:=$(shell sed -n 's/^helm-docs *= *"\(.*\)"/\1/p' "$(MISE_TOML)")
HELM_IMAGE=alpine/helm:$(HELM_VERSION)
HELM_DOCS_IMAGE=jnorwood/helm-docs:v$(HELM_DOCS_VERSION)
# Dependencies that are not installed by mise
SYSTEM_DEPS=git curl docker
MISE:=$(shell command -v mise 2>/dev/null || echo "$(HOME)/.local/bin/mise")
MISE_EXEC=cd "$(REPO_ROOT)" && "$(MISE)" exec --
KNOWN_TARGETS=helm

# These variables can be changed in the command line. Example: make deploy NAMESPACE=zabbix
KIND_CLUSTER_NAME?=helm-zabbix
KIND_CONFIG?=$(CHART_DIR)/docs/example/kind/kind-3nodes.yaml
RELEASE_NAME?=zabbix
NAMESPACE?=monitoring
DEPLOY_TIMEOUT?=10m
# Optional values file used by the deploy target
VALUES_FILE?=
# Values file used by the stack-up target
STACK_VALUES_FILE?=$(CHART_DIR)/docs/example/kind/values.yaml
ARGOCD_TIMEOUT?=15m

# These values are the same defined in the docs/example/argocd/application.yaml file
ARGOCD_NAMESPACE:=argocd
ARGOCD_APP_NAME:=zabbix
ARGOCD_APP_NAMESPACE:=monitoring
ARGOCD_APP_FILE:=$(CHART_DIR)/docs/example/argocd/application.yaml
ARGOCD_SNAPSHOT_DIR:=/tmp/helm-zabbix.git

.PHONY: requirements check-mise check-os check-deps install-deps helm lint package gen-docs kind-create deploy undeploy argocd-install argocd-deploy argocd-undeploy stack-up stack-down help

#----------------------------------------------------------------------------------------------------------




#---------------------------
#---------------------------
# MAIN
#---------------------------
#---------------------------

# References
# https://ryanstutorials.net/bash-scripting-tutorial/bash-input.php
# https://stackoverflow.com/questions/3743793/makefile-why-is-the-read-command-not-reading-the-user-input
# https://stackoverflow.com/questions/60147129/interactive-input-of-a-makefile-variable
# https://makefiletutorial.com/
# https://stackoverflow.com/questions/589276/how-can-i-use-bash-syntax-in-makefile-targets
# https://til.hashrocket.com/posts/k3kjqxtppx-escape-dollar-sign-on-makefiles
# https://stackoverflow.com/questions/5618615/check-if-a-program-exists-from-a-makefile



# Check requirements
requirements:
	@if command -v docker >/dev/null 2>&1; then \
		echo "Found docker"; \
	else \
		echo "ERROR: please install docker. See $(REQUIREMENTS_DOC)" >&2; \
		exit 1; \
	fi

# Check if mise is available to run the tools of the mise.toml file
check-mise:
	@if [ ! -x "$(MISE)" ]; then \
		echo "ERROR: mise is not installed. Run 'make install-deps'" >&2; \
		exit 1; \
	fi

# Check if the operating system is supported
check-os: ## Check if the operating system is supported
	@os="$$(uname -s)"; arch="$$(uname -m)"; \
	case "$$os-$$arch" in \
		Darwin-arm64|Darwin-x86_64) \
			system="macOS"; supported=yes ;; \
		Linux-x86_64) \
			system="Linux"; supported=no; \
			if [ -r /etc/os-release ]; then \
				. /etc/os-release; \
				system="$$ID $$VERSION_ID"; \
				case "$$ID-$$VERSION_ID" in \
					ubuntu-22.04|ubuntu-24.04|ubuntu-26.04) supported=yes ;; \
				esac; \
			fi ;; \
		*) \
			system="$$os"; supported=no ;; \
	esac; \
	if [ "$$supported" = yes ]; then \
		echo "Supported operating system: $$system ($$arch)"; \
	else \
		echo "ERROR: unsupported operating system: $$system ($$arch)" >&2; \
		echo "Supported: Ubuntu 22.04, 24.04 and 26.04 (amd64) and macOS (arm64 and amd64)" >&2; \
		exit 1; \
	fi

# Check if all dependencies are installed and show the missing ones
check-deps: ## Check if the dependencies are installed and show the missing ones
	@missing=""; \
	for dep in $(SYSTEM_DEPS); do \
		if command -v "$$dep" >/dev/null 2>&1; then \
			echo "[ok]      $$dep"; \
		else \
			echo "[missing] $$dep"; missing="$$missing $$dep"; \
		fi; \
	done; \
	if [ -x "$(MISE)" ]; then \
		echo "[ok]      mise"; \
	else \
		echo "[missing] mise"; missing="$$missing mise"; \
	fi; \
	for tool in $(MISE_TOOLS); do \
		if [ -x "$(MISE)" ] && (cd "$(REPO_ROOT)" && MISE_TRUSTED_CONFIG_PATHS="$(REPO_ROOT)" "$(MISE)" which "$$tool" >/dev/null 2>&1); then \
			echo "[ok]      $$tool (mise.toml)"; \
		else \
			echo "[missing] $$tool (mise.toml)"; missing="$$missing $$tool"; \
		fi; \
	done; \
	if [ -n "$$missing" ]; then \
		echo "ERROR: missing dependencies:$$missing" >&2; \
		echo "Run 'make install-deps' to install mise and the tools of mise.toml. Install git, curl and docker according to $(REQUIREMENTS_DOC)" >&2; \
		exit 1; \
	fi; \
	echo "All dependencies are installed"

# Install mise and the tools defined in mise.toml
install-deps: check-os ## Install mise and the tools of mise.toml (docker is installed separately)
	@if [ ! -x "$(MISE)" ]; then \
		if ! command -v curl >/dev/null 2>&1; then \
			echo "ERROR: please install curl to install mise" >&2; \
			exit 1; \
		fi; \
		curl -fsSL https://mise.run | sh; \
		echo "Activate mise in your shell. See $(REQUIREMENTS_DOC)"; \
	fi
	@cd "$(REPO_ROOT)" && "$(MISE)" trust mise.toml && "$(MISE)" install
	@command -v docker >/dev/null 2>&1 || echo "WARNING: docker is not installed and must be installed separately. See $(REQUIREMENTS_DOC)"

# Run helm subcommands
helm:
	make requirements

	docker run --rm --name helm-exec  \
		--user $(shell id -u):$(shell id -g) \
		--mount type=bind,src="$(shell pwd)",dst=/helm-chart \
		-w /helm-chart \
		-e HELM_CACHE_HOME=/helm-chart/.helm/cache \
		-e HELM_CONFIG_HOME=/helm-chart/.helm/config \
		-e HELM_DATA_HOME=/helm-chart/.helm/data \
		$(HELM_IMAGE) \
		$(CMD)

# Run linter for helm chart
lint: ## Lint the helm chart
	make requirements

	CMD="lint ." $(MAKE) helm

# Package chart into zip file
package: ## Package the helm chart into a .tgz file under packages/
	make requirements

	CMD="package . -d packages" $(MAKE) helm

# Update documentation of helm chart
gen-docs: ## Regenerate README.md from README.md.gotmpl via helm-docs
	make requirements

	docker run --rm --name helm-docs  \
		--user $(shell id -u):$(shell id -g) \
		--mount type=bind,src="$(shell pwd)",dst=/helm-chart \
		-w /helm-chart \
		$(HELM_DOCS_IMAGE) \
		helm-docs

# Create only the kind cluster. It also becomes the current cluster of kubectl and helm
kind-create: requirements check-mise ## Create only the kind cluster (KIND_CLUSTER_NAME) and select it as current cluster
	@if $(MISE_EXEC) kind get clusters 2>/dev/null | grep -qx "$(KIND_CLUSTER_NAME)"; then \
		echo "The kind cluster $(KIND_CLUSTER_NAME) already exists"; \
		$(MISE_EXEC) kind export kubeconfig --name "$(KIND_CLUSTER_NAME)"; \
	else \
		$(MISE_EXEC) kind create cluster --name "$(KIND_CLUSTER_NAME)" --config "$(abspath $(KIND_CONFIG))" --wait 180s; \
	fi

# Install or upgrade the helm chart in the current cluster
deploy: check-mise ## Install or upgrade the helm chart in the current cluster (RELEASE_NAME, NAMESPACE, VALUES_FILE)
	@echo "Deploying release $(RELEASE_NAME) in namespace $(NAMESPACE) of the cluster: $$($(MISE_EXEC) kubectl config current-context)"
	@$(MISE_EXEC) helm upgrade --install "$(RELEASE_NAME)" "$(CHART_DIR)" \
		--namespace "$(NAMESPACE)" --create-namespace \
		--wait --timeout "$(DEPLOY_TIMEOUT)" \
		$(if $(VALUES_FILE),-f "$(abspath $(VALUES_FILE))")

# Uninstall the helm chart from the current cluster
undeploy: check-mise ## Uninstall the helm chart from the current cluster (RELEASE_NAME, NAMESPACE)
	@echo "Removing release $(RELEASE_NAME) in namespace $(NAMESPACE) of the cluster: $$($(MISE_EXEC) kubectl config current-context)"
	@$(MISE_EXEC) helm uninstall "$(RELEASE_NAME)" --namespace "$(NAMESPACE)" --wait

# Install or upgrade only Argo CD in the current cluster
argocd-install: check-mise ## Install or upgrade only Argo CD in the current cluster
	@echo "Installing Argo CD in namespace $(ARGOCD_NAMESPACE) of the cluster: $$($(MISE_EXEC) kubectl config current-context)"
	@$(MISE_EXEC) helm upgrade --install argocd argo-cd \
		--repo https://argoproj.github.io/argo-helm \
		--version "$(ARGOCD_CHART_VERSION)" \
		--namespace "$(ARGOCD_NAMESPACE)" --create-namespace \
		--wait --timeout "$(ARGOCD_TIMEOUT)"

# Deploy a snapshot of the local chart using Argo CD. For tests only.
# Argo CD reads charts from repositories and can't see the local files, so this target commits the
# current files of the chart (including uncommitted changes) to a temporary Git repository and
# copies it to the repo-server pod, without changing the Git repository of this project.
argocd-deploy: check-mise ## Deploy the local chart with Argo CD in the current cluster (for tests only)
	@set -e; \
	echo "Deploying Application $(ARGOCD_APP_NAME) in namespace $(ARGOCD_APP_NAMESPACE) of the cluster: $$($(MISE_EXEC) kubectl config current-context)"; \
	if ! $(MISE_EXEC) kubectl get crd applications.argoproj.io >/dev/null 2>&1; then \
		echo "ERROR: Argo CD is not installed in the current cluster. Run 'make argocd-install'" >&2; \
		exit 1; \
	fi; \
	if $(MISE_EXEC) helm status "$(ARGOCD_APP_NAME)" --namespace "$(ARGOCD_APP_NAMESPACE)" >/dev/null 2>&1; then \
		echo "ERROR: the helm release $(ARGOCD_APP_NAME) already exists in namespace $(ARGOCD_APP_NAMESPACE). Run 'make undeploy' first" >&2; \
		exit 1; \
	fi; \
	tmp="$$(mktemp -d)"; \
	trap 'rm -rf "$$tmp"' EXIT; \
	mkdir -p "$$tmp/charts"; \
	cp -R "$(CHART_DIR)" "$$tmp/charts/zabbix"; \
	git -C "$$tmp" init -q -b main; \
	git -C "$$tmp" add -A; \
	git -C "$$tmp" -c user.name=make -c user.email=make@localhost -c commit.gpgsign=false commit -q -m "Snapshot of the local chart"; \
	git -C "$$tmp" config core.bare true; \
	revision="$$(git -C "$$tmp" rev-parse HEAD)"; \
	pod="$$($(MISE_EXEC) kubectl -n "$(ARGOCD_NAMESPACE)" get pods -l app.kubernetes.io/name=argocd-repo-server -o jsonpath='{.items[0].metadata.name}')"; \
	COPYFILE_DISABLE=1 tar -C "$$tmp/.git" -cf - . | ( $(MISE_EXEC) kubectl -n "$(ARGOCD_NAMESPACE)" exec -i "$$pod" -c repo-server -- \
		sh -c 'rm -rf "$(ARGOCD_SNAPSHOT_DIR)" && mkdir -p "$(ARGOCD_SNAPSHOT_DIR)" && tar -xf - -C "$(ARGOCD_SNAPSHOT_DIR)"' ); \
	$(MISE_EXEC) kubectl apply -f "$(ARGOCD_APP_FILE)"; \
	$(MISE_EXEC) kubectl -n "$(ARGOCD_NAMESPACE)" annotate application "$(ARGOCD_APP_NAME)" argocd.argoproj.io/refresh=hard --overwrite; \
	for condition in "{.status.sync.revision}=$$revision" "{.status.sync.status}=Synced" "{.status.health.status}=Healthy"; do \
		echo "Waiting for $$condition"; \
		$(MISE_EXEC) kubectl -n "$(ARGOCD_NAMESPACE)" wait application "$(ARGOCD_APP_NAME)" --for="jsonpath=$$condition" --timeout="$(ARGOCD_TIMEOUT)"; \
	done

# Remove the Application and the resources managed by it
argocd-undeploy: check-mise ## Remove the Zabbix Application from Argo CD in the current cluster
	@echo "Removing Application $(ARGOCD_APP_NAME) of the cluster: $$($(MISE_EXEC) kubectl config current-context)"
	@$(MISE_EXEC) kubectl delete -f "$(ARGOCD_APP_FILE)" --ignore-not-found --wait --timeout="$(ARGOCD_TIMEOUT)"

# Create the kind cluster, install Argo CD and deploy the helm chart
stack-up: ## Create the kind cluster, install Argo CD and deploy the helm chart with helm (STACK_VALUES_FILE)
	@$(MAKE) kind-create
	@$(MAKE) argocd-install
	@$(MAKE) deploy VALUES_FILE="$(STACK_VALUES_FILE)"

# Remove the kind cluster and everything deployed on it
stack-down: requirements check-mise ## Remove the complete stack by deleting the kind cluster (KIND_CLUSTER_NAME)
	@$(MISE_EXEC) kind delete cluster --name "$(KIND_CLUSTER_NAME)"

# Show this help message
help: ## Show this help message
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
