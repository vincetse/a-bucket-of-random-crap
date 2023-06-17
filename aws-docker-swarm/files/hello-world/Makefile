
stack_name = hello-world

create update:
	docker stack deploy -c hello-world.yml $(stack_name)
	@echo 'Run:'
	@echo '  - docker stack ps $(stack_name)'

delete:
	-docker stack rm $(stack_name)
