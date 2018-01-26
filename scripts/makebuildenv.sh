#!/bin/bash
#
# Create the alpine bulid environment
#
set -eu

THIS_DIR=$(dirname "${BASH_SOURCE[0]}")

docker build -t parchment/buildenv --file ${THIS_DIR}/Dockerfile-buildenv ${THIS_DIR}
