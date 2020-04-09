SHELL := /bin/bash

release := k2g
chart := kong/kong

init:
	helm repo add kong https://charts.konghq.com
	helm repo update

create:
	helm install $(release) $(chart) \
		--set ingressController.installCRDs=false

status:
	helm status $(release)
	kubectl get service $(release)-kong-proxy

delete: echo_down
	helm delete $(release)

echo: echo_down
	kubectl apply -f echo-service.yaml
	@sleep 5
	$(eval lb := $(shell kubectl get service $(release)-kong-proxy \
		-ojsonpath='{.status.loadBalancer.ingress[0].ip}'))
	curl -i http://$(lb)/echo

echo_down:
	-kubectl delete -f echo-service.yaml
