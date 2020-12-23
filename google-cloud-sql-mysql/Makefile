SHELL := /bin/bash
deployment_name = foo-mysql
instance_name_prefix = foo-mysql-4af6
tier = db-f1-micro
database_name = foodb
cert_name = foocert
user = chewie
password = hello123world

dm = gcloud deployment-manager deployments

create update: get_instance_name
	$(eval home_ip = $(shell curl https://ifconfig.co/))
	$(dm) $@ $(deployment_name) \
		--template database.jinja \
		--properties instance_name:$(instance_name),database_name:$(database_name),cert_name:$(cert_name),tier:$(tier),home_cidr:$(home_ip)/32,user:$(user),password:$(password)

delete:
	$(dm) delete $(deployment_name) \
		--quiet

client: get_instance_name
	$(eval ip = $(shell gcloud sql instances describe $(instance_name) \
		--format="value(ipAddresses[0].ipAddress)"))
	mysql \
		--user=$(user) \
		--password=$(password) \
		--host=$(ip) \
		--compress \
		$(database_name)

# find the existing instance, or create a new unique instance name
get_instance_name:
	$(eval existing = $(shell gcloud sql instances list --filter='name:$(instance_name_prefix)-*' --format='value(name)'))
	$(eval instance_name = $(if $(existing),$(existing),$(instance_name_prefix)-$(shell echo $${RANDOM})))
