NAME=proxy
VERSION := $(shell bash -c "echo $$(($$(cat VERSION)+1)) | tee VERSION")
RUN_OPTS ?= -consul=$(shell docker-machine ip swl-consul):8500 -dry -once
ENVS ?= -e DOMAIN=local.auto

dev:
	docker build -t $(NAME):dev .
	docker run --rm $(ENVS) proxy:dev $(RUN_OPTS)

run:
	DOCKER_HOST="" DOCKER_MACHINE_NAME="" DOCKER_TLS_VERIFY="" DOCKER_CERT_PATH="" docker run -v $$(pwd)/config/haproxy.ctmpl:/tmp/haproxy.ctmpl --rm $(ENVS) proxy:dev $(RUN_OPTS)

build:
	mkdir -p build
	DOCKER_HOST="" DOCKER_MACHINE_NAME="" DOCKER_TLS_VERIFY="" DOCKER_CERT_PATH="" docker build -t $(NAME):$(VERSION) .
	DOCKER_HOST="" DOCKER_MACHINE_NAME="" DOCKER_TLS_VERIFY="" DOCKER_CERT_PATH="" docker save $(NAME):$(VERSION) | gzip -9 > build/$(NAME)_$(VERSION).tgz

release: build
	eval $(docker-machine env --swarm swl-demo0)
	docker load  -i build/$(NAME)_$(VERSION).tgz
	docker tag -f $(NAME):$(VERSION) $(NAME):latest
	eval $(docker-machine env --swarm swl-demo1)
	docker load  -i build/$(NAME)_$(VERSION).tgz
	docker tag -f $(NAME):$(VERSION) $(NAME):latest

.PHONY: build release next
