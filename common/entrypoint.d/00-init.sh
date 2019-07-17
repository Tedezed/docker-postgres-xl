#!/bin/bash
# By Tedezed

# To avoid errors, it is necessary to change the hostname with a specific format
# It is necessary to create a service for each pod
hostname_format () {
	echo "$1" | tr -d "-"
}

template_to_conf () {
	TO_REPLACE=$1
	CONF_FILE=$2
	for conf_var in $(echo $TO_REPLACE | tr -s "," " "); do
		sed -i "s/$conf_var/${!conf_var}/g" $CONF_FILE
	done
}

template_comment () {
	TO_COMMENT=$1
	CONF_FILE=$2
	for comment_var in $(echo $TO_COMMENT | tr -s "," " "); do
		sed -i "s/$comment_var/#$comment_var/g" $CONF_FILE
	done
}

postgres_gtm_proxy () {
	LIST_TO_REPLACE_GTM_PROXY="POSTGRES_HOSTNAME,GTM_PROXY_PORT,GTM_PROXY_WORKERS,GTM_HOST,GTM_PORT"
	initgtm -D $POSTGRES_DATA -Z gtm_proxy
	cp /mnt/common/conf/postgresql.conf $POSTGRES_DATA/postgresql.conf
	cp /mnt/common/conf/gtm_proxy.conf $POSTGRES_DATA/gtm_proxy.conf
	template_to_conf $LIST_TO_REPLACE_POSTGRES $POSTGRES_DATA/postgresql.conf
	template_to_conf $LIST_TO_REPLACE_GTM_PROXY $POSTGRES_DATA/gtm_proxy.conf
	echo "[INFO] Start GTM Proxy"
	gtm_proxy -D $POSTGRES_DATA
}

postgres_coord () {
	POSTGRES_COMMENT_CONF="shared_queues,shared_queue_size,enforce_two_phase_commit"
	export POSTGRES_MAX_PREPARED_TRANSACTIONS=$((POSTGRES_MAX_CONNECTIONS-(POSTGRES_MAX_CONNECTIONS/100*40)))
	export POSTGRES_SHARED_QUEUES=$((POSTGRES_MAX_CONNECTIONS-(POSTGRES_MAX_CONNECTIONS/100*40)))
	initdb -D $POSTGRES_DATA --nodename $POSTGRES_HOSTNAME
	cp /mnt/common/conf/postgresql.conf $POSTGRES_DATA/postgresql.conf
	template_to_conf $LIST_TO_REPLACE_POSTGRES $POSTGRES_DATA/postgresql.conf
	template_comment $POSTGRES_COMMENT_CONF $POSTGRES_DATA/postgresql.conf
	postgres -D /usr/local/pgsql/data --coordinator
}

postgres_gtm () {
	initgtm -D $POSTGRES_DATA -Z gtm
	cp /mnt/common/conf/postgresql.conf $POSTGRES_DATA/postgresql.conf
	template_to_conf $LIST_TO_REPLACE_POSTGRES $POSTGRES_DATA/postgresql.conf
	echo "[INFO] Start GTM"
	gtm -D /usr/local/pgsql/data -p $GTM_PORT
}

postgres_datanode () {
	POSTGRES_COMMENT_CONF="pooler_port,max_pool_size,pool_conn_keepalive,pool_maintenance_timeout,remote_query_cost,network_byte_cost,max_coordinators,max_datanodes,enforce_two_phase_commit"
	export POSTGRES_MAX_PREPARED_TRANSACTIONS=$POSTGRES_MAX_CONNECTIONS
	export POSTGRES_SHARED_QUEUES=$((POSTGRES_MAX_CONNECTIONS-(POSTGRES_MAX_CONNECTIONS/100*60)))
	initdb -D $POSTGRES_DATA --nodename $POSTGRES_HOSTNAME
	cp /mnt/common/conf/postgresql.conf $POSTGRES_DATA/postgresql.conf
	template_to_conf $LIST_TO_REPLACE_POSTGRES $POSTGRES_DATA/postgresql.conf
	template_comment $POSTGRES_COMMENT_CONF $POSTGRES_DATA/postgresql.conf
	postgres -D /usr/local/pgsql/data --datanode
}

export POSTGRES_HOSTNAME=$(hostname_format $POSTGRES_HOSTNAME)
export GTM_HOST=$(hostname_format $GTM_HOST)
LIST_TO_REPLACE_POSTGRES="POSTGRES_PORT,POSTGRES_MAX_CONNECTIONS,POSTGRES_SHARED_QUEUES_SIZE,GTM_HOST,GTM_PORT,PGXC_NODE_NAME,POOLER_PORT,MAX_POOL_SIZE,POOL_CONN_KEEPALIVE,POOL_MAINTANCE_TIMEOUT,MAX_COORDINATORS,MAX_DATANODES,REMOTE_QUERY_COST,NETWORK_BYTE_COST,POSTGRES_MAX_PREPARED_TRANSACTIONS,POSTGRES_SHARED_QUEUES"

if [ "$MODE" == "gtmproxy" ]; then
	postgres_gtm_proxy
elif [ "$MODE" == "coord" ]; then
	postgres_coord
elif [ "$MODE" == "gtm" ]; then
	postgres_gtm
elif [ "$MODE" == "datanode" ]; then
	postgres_datanode
else
	echo "[ERROR] Not found variable MODE in environment"
	sleep 15
	exit 1
fi

exit 0