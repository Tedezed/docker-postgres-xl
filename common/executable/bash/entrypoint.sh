#!/bin/bash
# By Tedezed
set -e

if [ "$DEBUG" == "true" ]; then
	echo "[INFO] Debug mode"
	sleep infinity
else
	echo "[INFO] Exec entrypoint.d"
	run-parts --regex="^[a-zA-Z0-9._-]+$" --report /mnt/common/entrypoint.d
fi

exit 0

