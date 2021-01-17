SHELL := /bin/bash
## config
location = us-central1
zone = $(location)-c
environment_name = foobar
airflow_version = 1.10.12
python_version = 3
machine_type = n1-standard-1
node_count = 3
dag = hello-world-dag.py

## aliases
cenv = time gcloud composer environments \

create:
	$(eval ip = $(shell curl -s https://ifconfig.co))
	$(cenv) create $(environment_name) \
		--location $(location) \
		--zone $(zone) \
		--airflow-version $(airflow_version) \
		--python-version $(python_version) \
		--machine-type $(machine_type) \
		--node-count $(node_count) \
		--disk-size 20GB \
		--web-server-allow-ip=description=home,ip_range=$(ip)/32

delete:
	$(cenv) delete $(environment_name) \
		--location $(location) \
		--quiet

deploy:
	$(cenv) storage dags import \
		--location $(location) \
		--environment $(environment_name) \
		--source $(dag)
