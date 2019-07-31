#!make

CONTAINER_REPO:=tedezed

build-base:
	docker build -f Dockerbase \
		--build-arg SOURCE_FROM=${SOURCE_FROM} \
		--build-arg SOURCE=${SOURCE} \
		-t ${CONTAINER_REPO}/postgres-xl-base:${CONTAINER_VERSION} .

build:
	docker build -f Dockerfile -t ${CONTAINER_REPO}/postgres-xl:${CONTAINER_VERSION}  .

push-base:
	docker push ${CONTAINER_REPO}/postgres-xl-base:${CONTAINER_VERSION}

push:
	docker push ${CONTAINER_REPO}/postgres-xl:${CONTAINER_VERSION}

all: build-base push-base build push

