#!/usr/bin/env bash

if [ $# -eq 0 ]; then
    echo "No IP address supplied"
    exit 1
fi

mkdir -p /root/cardano-node || exit 0

socat UNIX-LISTEN:/db/node.socket,fork TCP:$1:11111,ignoreeof &
