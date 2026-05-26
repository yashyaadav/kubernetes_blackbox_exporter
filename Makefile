NS ?= monitoring

.PHONY: help apply delete port-forward probe validate

help: ## Show this help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

apply: ## kubectl apply manifests/ to namespace $(NS).
	kubectl apply -f manifests/ -n $(NS)

delete: ## Delete the resources from namespace $(NS).
	kubectl delete -f manifests/ -n $(NS) --ignore-not-found

port-forward: ## Port-forward the exporter to localhost:9115.
	kubectl -n $(NS) port-forward svc/blackbox-exporter 9115:9115

probe: ## Run a manual probe against example.com via the local port-forward.
	curl -sf 'http://localhost:9115/probe?target=https://example.com&module=http_2xx' \
		| grep -E '^probe_success 1$$' \
		&& echo "OK: probe_success 1" \
		|| (echo "FAIL: expected probe_success 1"; exit 1)

validate: ## Validate manifests with kubeconform (must be installed locally).
	@command -v kubeconform >/dev/null 2>&1 || { \
		echo "kubeconform not found. Install: brew install kubeconform"; exit 1; }
	kubeconform -strict -ignore-missing-schemas \
		-schema-location default \
		-schema-location 'https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json' \
		manifests/
