# https://kubevault.com/docs/v0.3.0/setup/operator/install/
SHELL := /bin/bash
release = vault
namespace = kube-system
version = v0.3.0

cli:
	wget -O kubedb https://github.com/kubedb/cli/releases/download/$(version)/kubedb-linux-amd64
	chmod +x kubedb
	mv kubedb ~/.local/bin

init:
	helm repo add appscode https://charts.appscode.com/stable
	helm repo update

create:
	helm install $(release)-operator appscode/vault-operator \
		--version $(version) \
		--namespace $(namespace)
	kubectl wait --for=condition=Available deployment/$(release)-operator \
		--timeout 300s \
		--namespace $(namespace)
	helm install $(release)-catalog appscode/vault-catalog \
		--version $(version) \
		--namespace $(namespace)

status:
	helm status $(release)-operator --namespace $(namespace)
	helm status $(release)-catalog --namespace $(namespace)

delete:
	-helm delete $(release)-catalog --namespace $(namespace)
	-helm delete $(release)-operator --namespace $(namespace)
	-kubectl delete crd -l app=kubevault
