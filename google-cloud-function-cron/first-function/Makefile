SHELL = /bin/bash
function_name = hello_http

f = time gcloud functions
s = time gcloud scheduler jobs

create:
	$f deploy $(function_name) \
		--runtime python37 \
		--trigger-http \
		--allow-unauthenticated

delete:
	$f delete $(function_name) \
		--quiet

describe:
	$f describe $(function_name)

logs:
	$f logs read $(function_name)

invoke:
	$(eval url = $(shell $f describe $(function_name) \
		--format='value(httpsTrigger.url)'))
	curl $(url)?name=foo
