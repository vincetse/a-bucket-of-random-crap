SHELL = /bin/bash
tf = time terraform

init:
	$(tf) $@

plan output:
	$(tf) $@

apply destroy:
	$(tf) $@ --auto-approve

create: apply

delete: destroy
