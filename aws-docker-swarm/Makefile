# https://aws.plainenglish.io/using-aws-to-create-a-docker-swarm-b48731c850c
account_id = $(shell aws sts get-caller-identity --query 'Account' --output text)
region = $(shell aws configure get region)
ssh_user = ec2-user
docker_context_name = swarm

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

ssh-manager: _get_manager_instance_id _instance_id_to_public_dns_name
	ssh $(ssh_user)@$(hostname)

context: _get_manager_instance_id _instance_id_to_public_dns_name
	docker context rm $(docker_context_name) -f
	docker context create --docker host=ssh://$(ssh_user)@$(hostname) $(docker_context_name)
	docker --context $(docker_context_name) node ls
	docker --context $(docker_context_name) ps

ps:
	docker --context $(docker_context_name) ps

ls:
	docker --context $(docker_context_name) node ls

deploy-files: _get_manager_public_dns_names
	for hostname in $(hostnames); do \
		rsync -e 'ssh -l $(ssh_user)' -avz files $${hostname}:. ; \
	done

get-managers: _get_manager_public_dns_names
	@echo $(hostnames) | tr " " "\n"

################################################################################
_push_key:
	aws ec2-instance-connect send-ssh-public-key \
		--region $(region) \
		--instance-id $(instance_id) \
		--instance-os-user ec2-user \
		--ssh-public-key file://~/.ssh/id_ed25519.pub

_instance_id_to_public_dns_name:
	$(eval hostname = $(shell aws ec2 describe-instances --instance-id $(instance_id) --query 'Reservations[0].Instances[0].PublicDnsName' --output text))

_get_manager_instance_id:
	$(eval instance_id = $(shell aws ec2 describe-instances --filters Name=tag:docker-swarm/role,Values=manager Name=instance-state-name,Values=running --query 'Reservations[0].Instances[0].InstanceId' --output text))

_get_manager_instance_ids:
	$(eval instance_ids = $(shell aws ec2 describe-instances --filters Name=tag:docker-swarm/role,Values=manager Name=instance-state-name,Values=running --query 'Reservations[].Instances[].InstanceId' --output text))

_get_manager_public_dns_names:
	$(eval hostnames = $(shell aws ec2 describe-instances --filters Name=tag:docker-swarm/role,Values=manager Name=instance-state-name,Values=running --query 'Reservations[].Instances[].PublicDnsName' --output text))
