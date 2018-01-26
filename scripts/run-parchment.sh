#!/bin/sh
set -eu
exec 2>&1

exec /sbin/parchment /etc/parchment.conf
