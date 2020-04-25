SHELL := /bin/bash
release = cpgops
namespace = pgo
version = v4.2.2
pgo_admin_password = helloworld
deployment_name = postgres-operator

cli:
	pip install ansible jmespath
	-rm -f pgo
	wget https://github.com/CrunchyData/postgres-operator/releases/download/$(version)/pgo
	chmod +x pgo
	mv pgo ~/.local/bin

init:
	-rm -rf postgres-operator
	git clone https://github.com/CrunchyData/postgres-operator.git

kubectl_context:
	$(eval context = $(shell kubectl config current-context))

install update uninstall: kubectl_context
	cd postgres-operator && \
	git checkout $(version) && \
	cd ansible && \
	ansible-playbook \
		--inventory inventory \
		--extra-vars kubernetes_context="$(context)" \
		--extra-vars pgo_admin_password="$(pgo_admin_password)" \
		--extra-vars backrest_storage="gce" \
		--extra-vars backup_storage="gce" \
		--extra-vars primary_storage="gce" \
		--extra-vars replica_storage="gce" \
		--extra-vars pgo_operator_namespace="$(namespace)" \
		--tags=$@ \
		main.yml

create: install
	kubectl wait --for=condition=Available deployment/$(deployment_name) \
		--namespace $(namespace) \
		--timeout=300s

status:
	kubectl --namespace $(namespace) get all

delete: uninstall

tunnel:
	kubectl port-forward service/$(deployment_name) --address 0.0.0.0 8443:8443 \
		--namespace $(namespace)
