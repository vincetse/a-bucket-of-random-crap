SHELL := /bin/bash

cluster_name = c-1
k3s_version = 1.0.0
instance_size = g2.medium
instance_count = 3

ck := civo kubernetes
ca := $(ck) applications

cli:
	$(eval version = v0.6.8)
	$(eval rpm = civo_amd64.deb)
	wget https://github.com/civo/cli/releases/download/$(version)/$(rpm)
	sudo apt-get install -y ./$(rpm)
	rm $(rpm)

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
	-$(ck) delete $(cluster_name) --yes

list:
	$(ck) list

shell:
	kubectl run shell-$$RANDOM -it --rm --restart="Never" \
		--image=ubuntu:18.04 \
		-- \
		/bin/bash

# https://www.civo.com/learn/kubernetes-cluster-administration-using-civo-cli
# civo k8s applications  ls
apps:
	$(eval apps = Longhorn KubeDB)
	for app in $(apps); do \
		$(ca) add $${app} --cluster=$(cluster_name); \
	done
