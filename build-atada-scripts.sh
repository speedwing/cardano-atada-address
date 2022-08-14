#!/usr/bin/env bash

set -x

echo "$@"

CARDANO_NODE_VERSION=1.35.3

docker build -t atada-scripts:"${CARDANO_NODE_VERSION}" "$@" \
  -f "atada-scripts.dockerfile" .
