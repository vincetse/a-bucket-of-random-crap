tf = terraform

sts:
	aws --region us-east-1 sts get-caller-identity

plan init:
	$(tf) $@

create: init
	$(tf) apply --auto-approve

delete:
	$(tf) destroy --auto-approve
