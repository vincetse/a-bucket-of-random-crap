
export EMAIL=admin@example.com
export DOMAIN=$(shell curl -s http://169.254.169.254/latest/meta-data/public-hostname)
export USERNAME=scott
export PASSWORD=tiger
export HASHED_PASSWORD=$(shell openssl passwd -apr1 $(PASSWORD))

node_id=$(shell docker info -f '{{.Swarm.NodeID}}')
stack_name = traefik

create:
	docker network create --driver=overlay traefik-public
	docker node update --label-add traefik-public.traefik-public-certificates=true $(node_id)
	docker stack deploy -c traefik.yml $(stack_name)
	@echo 'Run:'
	@echo '  - docker stack ps $(stack_name)'
	@echo '  - docker service logs $(stack_name)_traefik'

delete:
	docker stack rm $(stack_name)
	docker node update --label-rm traefik-public.traefik-public-certificates
	docker network rm traefik-public
