#!/bin/bash
# By Tedezed
set -e

echo "[INFO] Exec entrypoint.d"
run-parts --regex="^[a-zA-Z0-9._-]+$" --report /mnt/common/entrypoint.d

exit 0

