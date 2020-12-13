# https://kubedb.com/docs/0.12.0/setup/install/
SHELL := /bin/bash
namespace = kube-systems
statefulset_name = hot-postgres

create:
	kubectl create -f $(statefulset_name).yaml
	sleep 60
	kubectl wait --for=condition=Ready pod/$(statefulset_name)-0 -n demo

status:
	kubectl get services -n demo myadmin
	kubectl dba describe my -n demo $(statefulset_name)

versions:
	kubectl get postgresversions

delete:
	-kubectl delete -f $(statefulset_name).yaml

auth:
	$(eval username = $(shell kubectl get secrets \
		--namespace demo \
		$(statefulset_name)-auth \
		-o jsonpath='{.data.username}' | base64 -d))
	$(eval password = $(shell kubectl get secrets \
		--namespace demo \
		$(statefulset_name)-auth \
		-o jsonpath='{.data.password}' | base64 -d))
	$(eval hostname0= $(shell kubectl get pods \
		$(statefulset_name)-0 -n demo -ojsonpath='{.status.podIP}'))
	$(eval hostname1= $(shell kubectl get pods \
		$(statefulset_name)-1 -n demo -ojsonpath='{.status.podIP}'))
	$(eval hostname2= $(shell kubectl get pods \
		$(statefulset_name)-2 -n demo -ojsonpath='{.status.podIP}'))

client: auth
	for hostname in $(hostname0) $(hostname1) $(hostname2); do \
		kubectl run client-$$RANDOM -it --rm --restart=Never \
			--image=postgres:11 \
			--env PGUSER=$(username) \
			--env PGPASSWORD='$(password)' \
			--env PGHOST=$${hostname} \
			-- \
			psql; \
	done

shell:
	kubectl exec -it -n demo $(statefulset_name)-0 -- /bin/bash
