SHELL := /bin/bash

cluster_name = c-1
k3s_version = 0.9.1
instance_size = g2.medium
instance_count = 3

ck := civo kubernetes

cli:
	sudo apt update
	sudo apt install ruby
	sudo gem install civo_cli

versions:
	$(ck) versions

create:
	$(ck) create $(cluster_name) \
		--version=$(k3s_version) \
		--nodes=$(instance_count) \
		--size=$(instance_size) \
		--wait
	$(ck) config $(cluster_name) \
		--save
	kubectl config use-context $(cluster_name)

delete:
	-kubectl config delete-context $(cluster_name)
	-$(ck) delete $(cluster_name)

list:
	$(ck) list

shell:
	kubectl run shell-$$RANDOM -it --rm --restart="Never" \
		--image=ubuntu:18.04 \
		-- \
		/bin/bash
