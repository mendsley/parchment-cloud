#!/bin/sh
set -eu
exec 2>&1

echo "Securly tunneling to ${PARCHMENT_REMOTE_ADDR}"
exec /sbin/spiped \
	-F -e \
	-s '/var/run/remote.sock' \
	-t "${PARCHMENT_REMOTE_ADDR}" \
	-k /etc/spipedkey \
	;
