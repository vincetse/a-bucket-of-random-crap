SHELL = /bin/bash
tf = time terraform

sts:
	aws sts get-caller-identity

init:
	$(tf) $@

plan output:
	$(tf) $@

apply destroy:
	$(tf) $@ --auto-approve

create: apply

delete: destroy
