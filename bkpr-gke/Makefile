# https://github.com/bitnami/kube-prod-runtime/blob/master/docs/quickstart-gke.md
SHELL := /bin/bash
tf := time terraform

kubecfg_version := 0.15.3
bkpr_version := 1.5.0

cli:
	-rm -rf kubecfg bkpr-v$(bkpr_version) bkpr-v$(bkpr_version)-linux-amd64.tar.gz
	sudo apt install -qq -y jq
	wget https://github.com/bitnami/kubecfg/releases/download/v$(kubecfg_version)/kubecfg-linux-amd64 -O kubecfg
	wget https://github.com/bitnami/kube-prod-runtime/releases/download/v$(bkpr_version)/bkpr-v$(bkpr_version)-linux-amd64.tar.gz
	tar zxf bkpr-v$(bkpr_version)-linux-amd64.tar.gz
	chmod a+x kubecfg
	cp -a kubecfg bkpr-v$(bkpr_version)/kubeprod ~/.local/bin
	-rm -rf kubecfg bkpr-v$(bkpr_version) bkpr-v$(bkpr_version)-linux-amd64.tar.gz

init:
	$(tf) $@

plan output:
	$(tf) $@

apply destroy:
	$(tf) $@ --auto-approve

create: apply

delete: destroy
	rm -f kubeprod-autogen.json kubeprod-manifest.jsonnet
