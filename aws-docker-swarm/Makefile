# https://aws.plainenglish.io/using-aws-to-create-a-docker-swarm-b48731c850c
account_id = $(shell aws sts get-caller-identity --query 'Account' --output text)
region = $(shell aws configure get region)

export CDK_DEFAULT_ACCOUNT=$(account_id) CDK_DEFAULT_REGION=$(region)
export APP_NAME=AwsDockerSwarmStack

bootstrap:
	cdk bootstrap aws://$(account_id)/$(region)

create update:
	cdk synth
	cdk deploy --require-approval never --all

delete:
	cdk destroy --force --all

recreate:
	make delete
	sleep 60
	make create

ssh_user=ec2-user

ssh:
	$(eval hostname = $(shell aws ec2 describe-instances --instance-id $(instance_id) --query 'Reservations[0].Instances[0].PublicDnsName' --output text))
	ssh $(ssh_user)@$(hostname)

ssh-managers:
	$(eval instances = $(shell aws ec2 describe-instances --filters Name=tag:docker-swarm/role,Values=manager Name=instance-state-name,Values=running --query 'Reservations[].Instances[].InstanceId' --output text))
	for instance in $(instances); do \
		instance_id=$${instance} make ssh; \
	done

ssh-manager:
	$(eval instances = $(shell aws ec2 describe-instances --filters Name=tag:docker-swarm/role,Values=manager Name=instance-state-name,Values=running --query 'Reservations[0].Instances[0].InstanceId' --output text))
	for instance in $(instances); do \
		instance_id=$${instance} make ssh; \
	done

################################################################################
_push_key:
	aws ec2-instance-connect send-ssh-public-key \
		--region $(region) \
		--instance-id $(instance_id) \
		--instance-os-user ec2-user \
		--ssh-public-key file://~/.ssh/id_ed25519.pub
