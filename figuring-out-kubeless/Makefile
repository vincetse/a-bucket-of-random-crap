SHELL := /bin/bash

# https://kubeless.io/docs/quick-start/
ns = kubeless
version = v1.0.6
manifest = https://github.com/kubeless/kubeless/releases/download/$(version)/kubeless-$(version).yaml

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

delete:
	-kubectl delete -f $(manifest)
	-kubectl delete namespace $(ns)

deploy:
	kubeless function deploy hello \
		--runtime python2.7 \
		--from-file test.py \
		--handler test.hello
	kubectl get functions

call:
	kubeless function call hello --data 'Hello world!'

undeploy:
	kubeless function delete hello
