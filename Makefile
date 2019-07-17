#!make

CONTAINER_REPO:=tedezed
CONTAINER_VERSION:=10beta3-10alpha2

build-base:
	docker build -f Dockerbase -t ${CONTAINER_REPO}/postgres-xl-base:${CONTAINER_VERSION} .

build:
	docker build -f Dockerfile -t ${CONTAINER_REPO}/postgres-xl:${CONTAINER_VERSION}  .

push-base:
	docker push ${CONTAINER_REPO}/postgres-xl-base:${CONTAINER_VERSION}

push:
	docker push ${CONTAINER_REPO}/postgres-xl:${CONTAINER_VERSION}

all: build-base push-base build push

