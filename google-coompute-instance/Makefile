SHELL := /bin/bash

gc = gcloud compute

region = us-central1
zone = $(region)-a
template_name = std
machine_type = g1-small
instance_group_name = std
instance_group_size = 1
image_project = ubuntu-os-cloud
image_family = ubuntu-2004-lts

create:
	$(gc) instance-templates create $(template_name) \
		--metadata-from-file user-data=./user-data.yaml \
		--preemptible \
		--image-project $(image_project) \
		--image-family $(image_family) \
		--machine-type $(machine_type) \
		--boot-disk-size 200GB \
		--boot-disk-type pd-standard
	$(gc) instance-groups managed create $(instance_group_name) \
		--template $(template_name) \
		--description "vtse test sandboxes" \
		--size $(instance_group_size) \
		--zone $(zone)
	$(gc) instance-groups managed set-autoscaling $(instance_group_name) \
		--max-num-replicas $(instance_group_size) \
		--min-num-replicas $(instance_group_size) \
		--zone $(zone)

list:
	$(gc) instance-groups list-instances $(instance_group_name) \
		--zone $(zone)
	$(gc) instances list --filter="name~'^$(instance_group_name)-.*'"

delete:
	-$(gc) instance-groups managed delete $(instance_group_name) \
		--zone $(zone) \
		--quiet
	-$(gc) instance-templates delete $(template_name) \
		--quiet
