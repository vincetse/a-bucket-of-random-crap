deployment_name = foo-mysql
instance_name = foo-mysql
tier = db-f1-micro
database_name = foodb
cert_name = foocert
user = chewie
password = hello123world

dm = gcloud deployment-manager deployments

create update:
	$(eval home_ip = $(shell curl https://ifconfig.co/))
	$(dm) $@ $(deployment_name) \
		--template database.jinja \
		--properties instance_name:$(instance_name),database_name:$(database_name),cert_name:$(cert_name),tier:$(tier),home_cidr:$(home_ip)/32,user:$(user),password:$(password)

delete:
	$(dm) delete $(deployment_name) \
		--quiet

client:
	$(eval ip = $(shell gcloud sql instances describe $(instance_name) \
		--format="value(ipAddresses[0].ipAddress)"))
	mysql \
		--user=$(user) \
		--password=$(password) \
		--host=$(ip) \
		--compress \
		$(database_name)
