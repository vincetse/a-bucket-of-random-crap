# https://kubedb.com/docs/0.12.0/setup/install/
SHELL := /bin/bash
release = pgops
namespace = default
chart = postgres-operator/charts/postgres-operator

cli:
	wget -O kubedb https://github.com/kubedb/cli/releases/download/$(version)/kubedb-linux-amd64
	chmod +x kubedb
	mv kubedb ~/.local/bin

init:
	-rm -rf postgres-operator
	git clone https://github.com/zalando/postgres-operator

create:
	helm install $(release) $(chart) \
		--namespace $(namespace)
	kubectl wait --for=condition=Available deployment/$(release)-postgres-operator \
		--timeout 300s \
		--namespace $(namespace)
	helm install $(release)-ui $(chart)-ui \
		--namespace $(namespace) \
		--set service.type=ClusterIP \
		--set service.port=8080
	kubectl wait --for=condition=Available deployment/$(release)-ui-postgres-operator-ui \
		--timeout 300s \
		--namespace $(namespace)

ui:
	$(eval port := 5000)
	@echo "Visit http://localhost:$(port)"
	kubectl port-forward service/$(release)-ui-postgres-operator-ui --address 0.0.0.0 $(port):8080

status:
	helm status $(release) --namespace $(namespace)
	helm status $(release)-ui --namespace $(namespace)

delete:
	-helm delete $(release)-ui --namespace $(namespace)
	-helm delete $(release) --namespace $(namespace)

client:
	kubectl run client-$$RANDOM -it --rm --restart=Never \
		--image=postgres:12-alpine \
		-- \
		/bin/sh

shell:
	kubectl exec -it -n demo $(statefulset_name)-0 -- /bin/bash
