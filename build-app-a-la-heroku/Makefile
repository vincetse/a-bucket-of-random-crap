image ?= app

build:
	docker build --rm -t $(image) .

run:
	docker run --rm -p 8080:8080 -it $(image)

shell:
	docker run --rm -it $(image) /bin/bash

clean:
	-docker rmi $(image)
