SHELL := /bin/bash
namespace = pgo
pgo_admin_password = helloworld
cluster_name = hippo
pgouser = pgouser1
dbuser = rwuser

pgo:
	$(eval profile = ~/.pgo/pgo)
	$(eval envvars = \
		PGOUSER=$(profile)/pgouser \
		PGO_CA_CERT=$(profile)/client.crt \
		PGO_CLIENT_CERT=$(profile)/client.crt \
		PGO_CLIENT_KEY=$(profile)/client.pem \
		PGO_APISERVER_URL=https://127.0.0.1:8443 \
		PGO_NAMESPACE=$(pgouser) \
	)

auth:
	$(eval username = $(shell kubectl get secrets \
		--namespace $(pgouser) \
		$(cluster_name)-$(dbuser)-secret \
		-o jsonpath='{.data.username}' | base64 -d))
	$(eval password = $(shell kubectl get secrets \
		--namespace $(pgouser) \
		$(cluster_name)-$(dbuser)-secret \
		-o jsonpath='{.data.password}' | base64 -d))

# https://access.crunchydata.com/documentation/postgres-operator/4.2.2/pgo-client/common-tasks/
create: pgo
	$(envvars) pgo create cluster -n $(pgouser) $(cluster_name)
	sleep 20
	kubectl wait --for=condition=Available deployment/$(cluster_name) \
		--namespace $(pgouser) \
		--timeout=300s
	sleep 60
	kubectl wait --for=condition=Complete job/backrest-backup-$(cluster_name) \
		--namespace $(pgouser) \
		--timeout=300s
	# add replica
	$(envvars) pgo scale $(cluster_name) --replica-count 2 --no-prompt
	# users
	$(envvars) pgo create user $(cluster_name) --username=$(dbuser) --managed

scale: pgo
	$(envvars) pgo scale $(cluster_name) --no-prompt

list-users: pgo
	$(envvars) pgo show user $(cluster_name)

status: pgo
	$(envvars) pgo show cluster -n $(pgouser) $(cluster_name)

delete: pgo
	$(envvars) pgo delete user $(cluster_name) --username=$(dbuser) --no-prompt
	$(envvars) pgo delete cluster -n $(pgouser) $(cluster_name) \
		--no-prompt
	kubectl wait --for=delete deployment/$(cluster_name)-backrest-shared-repo \
		--namespace $(pgouser) \
		--timeout=300s

client: auth
	kubectl run client-$$RANDOM -it --rm --restart=Never \
		--image=postgres:12-alpine \
		--env PGHOST="$(hostname)" \
		--env PGUSER="$(username)" \
		--env PGPASSWORD="$(password)" \
		--env PGDATABASE=userdb \
		-- \
		psql

primary: hostname=$(cluster_name).$(pgouser)
primary: client

replica: hostname=$(cluster_name)-replica.$(pgouser)
replica: client


shell:
	$(eval pod_name = $(shell kubectl get pods \
		--namespace $(pgouser) --selector service-name=$(cluster_name),role=master \
		-ojsonpath='{.items[0].metadata.name}'\
	))
	kubectl exec -it --namespace $(pgouser) $(pod_name) -- /bin/bash
