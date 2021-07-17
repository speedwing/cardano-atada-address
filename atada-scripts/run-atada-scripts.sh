#!/usr/bin/env bash

set -x

OS_ARCH=$(uname -m)
NODE_VERSION="1.27.0"
IMAGE_TAG="${NODE_VERSION}-${OS_ARCH}"

# Network
NETWORK=mainnet

## The folder, on the actual Raspberry Pi where to download the blockchain
NODE_SOCKET_FOLDER="$HOME/Library/Application Support/Daedalus Mainnet"

docker run -it --rm \
    -v "NODE_SOCKET_FOLDER:/home/ubuntu/cardano-node/" \
    "atada-scripts:${NODE_VERSION}-${OS_ARCH}" bash
