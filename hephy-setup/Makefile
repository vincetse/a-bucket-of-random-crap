# https://docs.teamhephy.com/installing-workflow/
ns = deis
release = rx

cli:
	wget https://raw.githubusercontent.com/teamhephy/workflow-cli/master/install-v2.sh
	chmod +x install-v2.sh
	./install-v2.sh
	rm ./install-v2.sh
	mv deis ~/.local/bin

init:
	helm repo add hephy https://charts.teamhephy.com
	helm inspect values hephy/workflow


create:
	kubectl create namespace $(ns)
	helm install $(release) hephy/workflow \
		--namespace $(ns) \
		--set global.use_rbac=true,global.use_cni=true

status:
	helm status $(release) \
		--namespace $(ns)
	kubectl get all --namespace $(ns)
	$(eval lb = $(shell kubectl get service deis-router \
		--namespace $(ns) \
		-ojsonpath="{.status.loadBalancer.ingress[0].ip}"))
	@echo LoadBalancer IP: $(lb)
	@echo Deis Router: http://deis.$(lb).nip.io

delete:
	-helm delete $(release) --namespace $(ns)
	-kubectl delete namespace $(ns)
