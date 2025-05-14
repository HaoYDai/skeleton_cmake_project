IMAGE_NAME ?= g-rdhp3682-docker.pkg.coding.net/builds/docker/ubun22
TAG ?= 1.0.2
CONTAINER_NAME ?= ubun22
WORKDIR ?= $(PWD)

.PHONY: build run stop rm clean log shell pull_docker build_arm64 build_x86_64

pull_docker:
	docker pull $(IMAGE_NAME):$(TAG)

run_docker: stop_docker rm_docker pull_docker
	docker run -it \
		-w $(WORKDIR) \
		-u $(shell id -u):$(shell id -g) \
		--privileged \
		--network host \
		--name $(CONTAINER_NAME) \
		-v /home:/home \
		-v /etc/passwd:/etc/passwd:ro \
    	-v /etc/group:/etc/group:ro \
		-v /etc/shadow:/etc/shadow:ro \
		-v /etc/sudoers:/etc/sudoers:ro \
		$(IMAGE_NAME):$(TAG) /bin/bash

stop_docker:
	docker stop $(CONTAINER_NAME) || true

rm_docker:
	docker rm $(CONTAINER_NAME) || true

clean_docker: stop_docker rm_docker
	docker rmi $(IMAGE_NAME):$(TAG) || true

build_arm64:
	conan install . -pr=./profile/arm64.profile -b=missing
	conan build . -pr=./profile/arm64.profile -b=missing
	rm CMakeUserPresets.json

build_x86_64:
	conan install . -pr=default -b=missing
	conan build . -pr=default -b=missing
	rm CMakeUserPresets.json
