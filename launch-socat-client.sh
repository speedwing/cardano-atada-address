#!/usr/bin/env bash

mkdir -p /root/cardano-node || exit 0

socat UNIX-LISTEN:/root/cardano-node/cardano-node.socket,fork TCP:192.168.0.20:11111,ignoreeof &
