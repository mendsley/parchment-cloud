#!/bin/sh
set -eu
exec 2>&1

echo "Listening for secure connections at ${PARCHMENT_LISTEN_ADDR}"
exec /sbin/spiped \
	-F -d \
	-s "${PARCHMENT_LISTEN_ADDR}" \
	-t /var/run/remote.sock \
	-k /etc/spipedkey \
	-n 500 \
	;
