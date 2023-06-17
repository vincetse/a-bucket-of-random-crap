
#export EMAIL=admin@example.com
export DOMAIN=$(shell curl -s http://169.254.169.254/latest/meta-data/public-hostname)
#export USERNAME=scott
#export PASSWORD=tiger
#export HASHED_PASSWORD=$(shell openssl passwd -apr1 $(PASSWORD))

node_id=$(shell docker info -f '{{.Swarm.NodeID}}')
stack_name = portainer

create:
	docker node update --label-add portainer.portainer-data=true $(node_id)
	docker stack deploy -c portainer.yml $(stack_name)
	@echo 'Run:'
	@echo '  - docker stack ps $(stack_name)'
	@echo '  - docker service logs $(stack_name)_traefik'

delete:
	docker stack rm $(stack_name)
	docker node update --label-rm portainer.portainer-data $(node_id)
