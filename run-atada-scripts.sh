#!/usr/bin/env bash

set -x

OS_ARCH=$(uname -m)
NODE_VERSION="1.27.0"
IMAGE_TAG="${NODE_VERSION}-${OS_ARCH}"

docker run -it --rm \
    -v /Users/MEKES01/tmp/db:/db \
    "atada-scripts:${NODE_VERSION}-${OS_ARCH}" bash
