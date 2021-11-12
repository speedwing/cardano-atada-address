#!/usr/bin/env bash

set -x

OS_ARCH=$(uname -m)
NODE_VERSION="1.30.1"
IMAGE_TAG="${NODE_VERSION}-${OS_ARCH}"

docker run -it --rm \
    -v /Users/MEKES01/tmp/db:/db \
    -v `pwd`/phrase.prv:/root/phrase.prv \
    "atada-scripts:${NODE_VERSION}-${OS_ARCH}" bash
