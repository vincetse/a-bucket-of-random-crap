# https://kubedb.com/docs/0.12.0/setup/install/
SHELL := /bin/bash
release = kubedb
namespace = kube-system
version = 0.15.2

cli:
	cd $(shell mktemp -d) && \
	curl -o kubectl-dba.tar.gz -fsSL https://github.com/kubedb/cli/releases/download/v0.15.2/kubectl-dba-linux-amd64.tar.gz && \
	tar zxvf kubectl-dba.tar.gz && \
	chmod +x kubectl-dba-linux-amd64 && \
	mv kubectl-dba-linux-amd64 ~/.local/bin/kubectl-dba

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
	make --directory pg-ha create
	make --directory pg-hot create
	make --directory mysql-clustering create

status:
	helm status $(release)-operator --namespace $(namespace)
	helm status $(release)-catalog --namespace $(namespace)

delete:
	-make --directory mysql-clustering delete
	-make --directory pg-hot delete
	-make --directory pg-ha delete
	-make --directory demo delete
	-helm delete $(release)-catalog --namespace $(namespace)
	-helm delete $(release)-operator --namespace $(namespace)
	-kubectl delete crd -l app=kubedb
	-kubectl delete podsecuritypolicy -l app=kubedb-catalog

mysql postgres redis mongodb elasticsearch memcached:
	kubectl get $@versions

versions: mysql postgres redis mongodb elasticsearch memcached
