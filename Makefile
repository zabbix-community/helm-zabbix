URL=https://github.com/cetic/helm-zabbix/
HELM_IMAGE=alpine/helm:3.9.0
HELM_DOCS_IMAGE=jnorwood/helm-docs:v1.10.0
KNOWN_TARGETS=helm


helm:
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
lint:
	CMD="lint ." $(MAKE) helm

# Package chart into zip file
package:
	CMD="package . -d packages" $(MAKE) helm

# Create index file (use only for initial setup)
index:
	CMD="repo index --url ${URL} ." $(MAKE) helm

# Update index file add new version of package into it
merge:
	CMD="repo index --url ${URL} --merge index.yaml ." $(MAKE) helm

gen-docs:
	docker run --rm --name helm-docs  \
		--user $(shell id -u):$(shell id -g) \
		--mount type=bind,src="$(shell pwd)",dst=/helm-chart \
		-w /helm-chart \
		$(HELM_DOCS_IMAGE) \
		helm-docs

