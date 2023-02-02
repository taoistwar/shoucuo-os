DOCKER_NAME ?= shoucuo-os
.PHONY: docker build_docker

docker:
	docker run --rm -it -v ${PWD}:/mnt -w /mnt ${DOCKER_NAME} bash

build_docker:
	docker build -t ${DOCKER_NAME} .

fmt:
	cd os ; cargo fmt;  cd ..

run:
	cd os; make run