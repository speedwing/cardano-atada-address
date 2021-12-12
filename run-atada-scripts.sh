#!/usr/bin/env bash

set -x

NODE_VERSION="1.31.0"

NETWORK=mainnet
CARDANO_NODE_PORT=3000

#DB_FOLDER=/Users/MEKES01/tmp/db
DB_FOLDER=/Users/giovanni/.cardano/cardano-mainnet

docker run -it --rm \
    --name cardano-node-mainnet \
    -v ${DB_FOLDER}:/db \
    -v `pwd`/phrase.prv:/root/phrase.prv \
    "atada-scripts:${NODE_VERSION}" \
    "cardano-node run \
    --topology /etc/config/${NETWORK}-topology.json \
    --database-path /db \
    --socket-path /db/node.socket \
    --host-addr 0.0.0.0 \
    --port $CARDANO_NODE_PORT \
    --config /etc/config/${NETWORK}-config.json"
