deployment_name = foo-pgsql
instance_name = foo-pgsql
tier = db-f1-micro
database_name = foodb
cert_name = foocert
user = $(shell gcloud info --format="value(config.account)")

dm = gcloud deployment-manager deployments

create update:
	$(eval home_ip = $(shell curl https://ifconfig.co/))
	$(dm) $@ $(deployment_name) \
		--template database.jinja \
		--properties instance_name:$(instance_name),database_name:$(database_name),cert_name:$(cert_name),tier:$(tier),home_cidr:$(home_ip)/32,user:$(user)

delete:
	$(dm) delete $(deployment_name) \
		--quiet

client:
	$(eval password = $(shell gcloud auth print-access-token))
	$(eval ip = $(shell gcloud sql instances describe $(instance_name) \
		--format="value(ipAddresses[0].ipAddress)"))
	PGSSLMODE=require \
	PGHOST=$(ip) \
	PGUSER=$(user) \
	PGPASSWORD='$(password)' \
	PGDATABASE=$(database_name) \
	psql
