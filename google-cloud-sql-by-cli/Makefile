SHELL := /bin/bash
instance_name = foo311
database_name = db1
database_version = MYSQL_5_7
root_password = pa55word
tier = db-g1-small
region = us-central1

sql = time gcloud sql

create:
	$(eval myip = $(shell curl --silent https://ifconfig.me))
	$(sql) instances create $(instance_name) \
		--authorized-networks=$(myip)/32 \
		--assign-ip \
		--availability-type=regional \
		--backup \
		--backup-start-time=07:00 \
		--database-version=$(database_version) \
		--enable-bin-log \
		--maintenance-release-channel=production \
		--maintenance-window-day=SUN \
		--maintenance-window-hour=4 \
		--require-ssl \
		--root-password=$(root_password) \
		--storage-size=1024 \
		--storage-type=HDD \
		--tier=$(tier) \
		--region=$(region)
	$(sql) databases create $(database_name) \
		--instance=$(instance_name)

delete:
	$(sql) instances delete $(instance_name) \
		--quiet

tiers:
	$(sql) tiers list

client:
	$(eval instance_ip = $(shell gcloud sql instances describe $(instance_name) \
		 --format='get(ipAddresses[0].ipAddress)'))
	mysql \
		--user=root \
		--password=$(root_password) \
		--host=$(instance_ip) \
		--compress \
		$(database_name)
