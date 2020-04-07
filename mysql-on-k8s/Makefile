SHELL := /bin/bash
# https://github.com/presslabs/mysql-operator
ns = db
release = db1

init:
	helm repo add presslabs https://presslabs.github.io/charts

# https://github.com/presslabs/mysql-operator/issues/491
create:
	kubectl create namespace $(ns)
	kubectl apply -f https://raw.githubusercontent.com/presslabs/mysql-operator/master/config/crds/mysql_v1alpha1_mysqlcluster.yaml
	kubectl apply -f https://raw.githubusercontent.com/presslabs/mysql-operator/master/config/crds/mysql_v1alpha1_mysqlbackup.yaml
	helm install $(release) presslabs/mysql-operator \
		--namespace $(ns)

up:
	kubectl apply --namespace $(ns) \
		-f my-cluster.yaml

status:
	helm status $(release) --namespace $(ns)
	kubectl get mysql --namespace $(ns)

down:
	-kubectl delete --namespace $(ns) \
		-f my-cluster.yaml

delete:
	-helm delete $(release) --namespace $(ns)
	-kubectl delete -f https://raw.githubusercontent.com/presslabs/mysql-operator/master/config/crds/mysql_v1alpha1_mysqlbackup.yaml
	-kubectl delete -f https://raw.githubusercontent.com/presslabs/mysql-operator/master/config/crds/mysql_v1alpha1_mysqlcluster.yaml
	-kubectl delete namespace $(ns)

client:
	kubectl run client-$$RANDOM -it --rm --restart="Never" \
		--image=percona:8 \
		--env MYSQL_PWD=mypass \
		-- \
		mysql \
			--host=my-cluster-mysql-master.$(ns) \
			--user=root
