#!/usr/bin/env bash

set -x

CARDANO_NODE_VERSION=1.34.1

docker build -t atada-scripts:"${CARDANO_NODE_VERSION}" \
  -f "atada-scripts.dockerfile" .
