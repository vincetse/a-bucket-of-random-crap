# https://vitess.io/docs/get-started/kubernetes/
# Run on a real Kubernetes 1.16.x cluster instead of Minikube
SHELL := /bin/bash
release = vitess

cli:
	-rm -f vitess-5.20+20200204-17a806ae5*
	wget https://github.com/vitessio/vitess/releases/download/v5.20%2B20200204/vitess-5.20+20200204-17a806ae5.tar.gz
	tar zxf vitess-5.20+20200204-17a806ae5.tar.gz
	cp -a vitess-5.20+20200204-17a806ae5/bin/vtctl ~/.local/bin
	-rm -f vitess-5.20+20200204-17a806ae5*

init:
	rm -rf vitess
	git clone https://github.com/vitessio/vitess

create:
	cd vitess/examples/helm && \
	helm install $(release) ../../helm/vitess -f 101_initial_cluster.yaml

delete:
	helm delete $(release)

client:
	kubectl run client-$$RANDOM -it --rm --restart="Never" \
		--image=percona:8 \
		-- \
		mysql \
			--host=vtgate-zone1

console:
	@echo "Open up a browser and go to http://localhost:8080"
	kubectl port-forward service/vtctld --address  0.0.0.0 8080:15000
