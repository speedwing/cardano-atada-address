#!/usr/bin/env bash

socat TCP-LISTEN:11111,fork UNIX-CLIENT:"/Users/giovanni/Library/Application Support/Daedalus Mainnet/cardano-node.socket",ignoreeof