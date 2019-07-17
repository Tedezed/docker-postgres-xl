FROM tedezed/postgres-xl-base as build

FROM debian:9-slim
ENV POSTGRES_HOME=/usr/local/pgsql
COPY --from=build $POSTGRES_HOME $POSTGRES_HOME

MAINTAINER Juan Manuel Torres <juanmanuel.torres@aventurabinaria.es>

ENV POSTGRES_HOSTNAME=changeme \
	POSTGRES_USER=postgres \
	POSTGRES_HOME=/usr/local/pgsql \
	POSTGRES_PORT=5432 \
	POSTGRES_MAX_CONNECTIONS=200 \
	POSTGRES_SHARED_QUEUES_SIZE=64kB \
	GTM_HOST=postgresxlgtm \
	GTM_PORT=6666 \
	PGXC_NODE_NAME=changeme \
	POOLER_PORT=6667 \
	POOL_CONN_KEEPALIVE=1500 \
	POOL_MAINTANCE_TIMEOUT=200 \
	MAX_COORDINATORS=16 \
	MAX_DATANODES=16 \
	REMOTE_QUERY_COST=100.0 \
	NETWORK_BYTE_COST=0.002 \
	POSTGRES_MAX_PREPARED_TRANSACTIONS=30 \
	POSTGRES_SHARED_QUEUES=60 \
	GTM_PROXY_PORT=5432 \
	GTM_PROXY_WORKERS=4

ENV	POSTGRES_DATA=$POSTGRES_HOME/data \
	MAX_POOL_SIZE=$POSTGRES_MAX_CONNECTIONS \
	PATH=/usr/local/pgsql/bin:$PATH \
	LD_LIBRARY_PATH=/usr/local/pgsql/lib

RUN apt-get update \
	&& apt-get install -y procps nano \
	&& apt-get install -y \
		libreadline-dev \
	&& rm -rf /var/lib/apt/lists/* \
	&& useradd $POSTGRES_USER -d $POSTGRES_HOME \
	&& mkdir -p $POSTGRES_DATA \
	&& chown -R $POSTGRES_USER $POSTGRES_HOME

ADD common /mnt/common
RUN chown $POSTGRES_USER -R /mnt/common/* \
	&& chmod +x -R /mnt/common/executable/bash/*\
	&& chmod +x -R /mnt/common/entrypoint.d/*

USER $POSTGRES_USER
WORKDIR $POSTGRES_HOME

EXPOSE 5432 6666 6667 6668
VOLUME ["/usr/local/pgsql/data"]
ENTRYPOINT ["/mnt/common/executable/bash/entrypoint.sh"]
