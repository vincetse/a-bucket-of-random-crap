# https://kubedb.com/docs/0.12.0/setup/install/
SHELL := /bin/bash
namespace = kube-systems
statefulset_name = mysql-quickstart

create:
	kubectl create ns demo
	kubectl create -f demo-1.yaml
	kubectl wait --for=condition=Available deployment/myadmin -n demo
	kubedb create -f demo-2.yaml

status:
	kubectl get services -n demo myadmin
	kubedb describe my -n demo $(statefulset_name)

versions:
	kubectl get mysqlversions

delete:
	-kubedb delete -f demo-2.yaml
	-kubectl delete -f demo-1.yaml
	#-../kill-kube-ns.sh demo
	-kubectl delete ns demo

auth:
	$(eval username = $(shell kubectl get secrets \
		--namespace demo \
		$(statefulset_name)-auth \
		-o jsonpath='{.data.username}' | base64 -d))
	$(eval password = $(shell kubectl get secrets \
		--namespace demo \
		$(statefulset_name)-auth \
		-o jsonpath='{.data.password}' | base64 -d))
	$(eval hostname = $(shell kubectl get pods \
		$(statefulset_name)-0 -n demo -ojsonpath='{.status.podIP}'))

client: auth
	kubectl run client-$$RANDOM -it --rm --restart=Never \
		--image=percona:8 \
		--env MYSQL_PWD=$(password) \
		-- \
		mysql \
			--host=$(hostname) \
			--user=$(username)
