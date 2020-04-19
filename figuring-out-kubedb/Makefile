# https://kubedb.com/docs/0.12.0/setup/install/
SHELL := /bin/bash
release = kubedb
namespace = kube-system
version = 0.12.0

cli:
	wget -O kubedb https://github.com/kubedb/cli/releases/download/$(version)/kubedb-linux-amd64
	chmod +x kubedb
	mv kubedb ~/.local/bin

init:
	helm repo add appscode https://charts.appscode.com/stable
	helm repo update

create:
	helm install $(release)-operator appscode/kubedb \
		--version $(version) \
		--namespace $(namespace)
	kubectl wait --for=condition=Available deployment/$(release)-operator \
		--timeout 300s \
		--namespace $(namespace)
	helm install $(release)-catalog appscode/kubedb-catalog \
		--version $(version) \
		--namespace $(namespace)
	make --directory demo create

status:
	helm status $(release)-operator --namespace $(namespace)
	helm status $(release)-catalog --namespace $(namespace)

delete:
	-make --directory demo delete
	-helm delete $(release)-catalog --namespace $(namespace)
	-helm delete $(release)-operator --namespace $(namespace)
	-kubectl delete crd -l app=kubedb
	-kubectl delete podsecuritypolicy -l app=kubedb-catalog
