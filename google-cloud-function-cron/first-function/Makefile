# https://cloud.google.com/functions/docs/calling/pubsub#functions_calling_pubsub-python
SHELL = /bin/bash
entrypoint = hello_pubsub
function_name = $(entrypoint)_xiydkz
trigger_topic = $(function_name)
trigger_job = $(function_name)

p = time gcloud pubsub topics
f = time gcloud functions
s = time gcloud scheduler jobs

create:
	#$p create $(trigger_topic)
	$f deploy $(function_name) \
		--runtime python37 \
		--source ./src \
		--entry-point $(entrypoint) \
		--trigger-topic $(trigger_topic) \
		--allow-unauthenticated
	$s create pubsub $(trigger_job) \
		--schedule "*/2 * * * *" \
		--topic $(trigger_topic) \
		--message-body 'foo'

update:
	$f deploy $(function_name) \
		--runtime python37 \
		--source ./src \
		--entry-point $(entrypoint) \
		--trigger-topic $(trigger_topic) \
		--allow-unauthenticated
	$s update pubsub $(trigger_job) \
		--schedule "*/2 * * * *" \
		--topic $(trigger_topic) \
		--message-body 'foo'

delete:
	-$s delete $(trigger_job) \
		--quiet
	-$f delete $(function_name) \
		--quiet
	-$p delete $(trigger_topic) \
		--quiet

describe:
	$f describe $(function_name)

logs:
	$f logs read $(function_name)

invoke:
	$(eval url = $(shell $f describe $(function_name) \
		--format='value(httpsTrigger.url)'))
	curl $(url)?name=foo
