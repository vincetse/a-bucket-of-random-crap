SHELL := /bin/bash

# https://kubeless.io/docs/quick-start/
# https://kubeless.io/docs/http-triggers/
ns = kubeless
version = v1.0.6
manifest = https://github.com/kubeless/kubeless/releases/download/$(version)/kubeless-$(version).yaml
hostname = foobar.com

cli:
	-rm -rf bundles $(zipfile)
	$(eval zipfile := kubeless_linux-amd64.zip)
	wget https://github.com/kubeless/kubeless/releases/download/$(version)/$(zipfile)
	unzip $(zipfile)
	cp -a bundles/kubeless_linux-amd64/kubeless ~/.local/bin
	-rm -rf bundles $(zipfile)
	kubeless version

create:
	kubectl create namespace $(ns)
	kubectl create -f $(manifest)
	kubectl get pods -n $(ns)

status:
	kubectl get pods -n $(ns)

delete: undeploy
	-kubectl delete -f $(manifest)
	-kubectl delete namespace $(ns)

deploy:
	kubeless function deploy hello \
		--runtime python2.7 \
		--from-file test.py \
		--handler test.hello
	@sleep 3
	kubectl get functions
	@sleep 3
	kubeless trigger http create hello \
		--function-name hello \
		--hostname $(hostname) \
		--gateway kong
	@sleep 3
	kubectl get ingress

call:
	kubeless function call hello --data '{"Another": "Echo"}'
	$(eval lb = $(shell kubectl get ingress hello -ojsonpath='{.status.loadBalancer.ingress[0].ip}'))
	curl --data '{"Another": "Echo"}' \
		--header "Host: $(hostname)" \
		--header "Content-Type: application/json" \
		$(lb)

undeploy:
	-kubeless trigger http delete hello
	-kubeless function delete hello
