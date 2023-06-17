
export EMAIL=admin@example.com
export DOMAIN=$(shell curl -s http://169.254.169.254/latest/meta-data/public-hostname)
export USERNAME=scott
export PASSWORD=tiger
export HASHED_PASSWORD=$(shell openssl passwd -apr1 $(PASSWORD))

node_id=$(shell docker info -f '{{.Swarm.NodeID}}')
stack_name = swarmpit
network_name = traefik-public

create:
	docker node update --label-add swarmpit.db-data=true $(node_id)
	docker node update --label-add swarmpit.influx-data=true $(node_id)
	docker stack deploy -c swarmpit.yml $(stack_name)
	@echo 'Run:'
	@echo '  - docker stack ps $(stack_name)'

delete:
	-docker stack rm $(stack_name)
	-docker node update --label-rm swarmpit.influx-data $(node_id)
	-docker node update --label-rm swarmpit.db-data $(node_id)
	-docker network rm traefik-public
