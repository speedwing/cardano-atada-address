#!/usr/bin/env bash

socat UNIX-LISTEN:/root/cardano-node/cardano-node.socket,fork TCP:192.168.0.20:11111,ignoreeof