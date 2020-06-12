SHELL = /bin/bash

t = time terraform

init plan:
	$t $@

create:
	$t apply --auto-approve

delete:
	$t destroy --auto-approve

describe:
	$f describe $(function_name)

logs:
	$f logs read $(function_name)

invoke:
	$(eval url = $(shell $f describe $(function_name) \
		--format='value(httpsTrigger.url)'))
	curl $(url)?name=foo
