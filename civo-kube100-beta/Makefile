SHELL := /bin/bash

cluster_name = c-1
instance_size = g2.medium
instance_count = 3

ck := civo kubernetes

create:
	$(ck) create $(cluster_name) \
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
