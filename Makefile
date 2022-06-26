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

gen-docs:
	docker run --rm --name helm-docs  \
		--user $(shell id -u):$(shell id -g) \
		--mount type=bind,src="$(shell pwd)",dst=/helm-chart \
		-w /helm-chart \
		$(HELM_DOCS_IMAGE) \
		helm-docs

