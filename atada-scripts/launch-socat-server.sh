#!/usr/bin/env bash

socat TCP-LISTEN:11111,fork UNIX-CLIENT:"$HOME/Library/Application Support/Daedalus Mainnet/cardano-node.socket",ignoreeof
