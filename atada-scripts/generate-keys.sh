#!/usr/bin/env bash

if [ ! -f ./phrase.prv ]; then
  echo "phrase.prv does not exist. Run:"
  echo "echo \"my mnemonic phrase\" > phrase.prv"
  echo "and try again"
  exit 1
fi

cardano-address key from-recovery-phrase Shelley < phrase.prv > root.xsk

cardano-address key child 1852H/1815H/0H/0/0 < root.xsk | cardano-address key public --with-chain-code > addr.xvk

cardano-address key child 1852H/1815H/0H/2/0 < root.xsk | cardano-address key public --with-chain-code > stake.xvk

cardano-address address payment --network-tag testnet < addr.xvk > many.payment.addr

cardano-address address delegation $(cat stake.xvk) < many.payment.addr > payment-delegated.addr

cardano-address address stake --network-tag testnet < stake.xvk > many.stake.addr

cardano-cli key convert-cardano-address-key --shelley-payment-key --signing-key-file root.xsk --out-file many.payment.skey
cardano-cli key verification-key --signing-key-file many.payment.skey --verification-key-file many.payment.vkey

## Maybe not required
# cardano-cli key non-extended-key --extended-verification-key-file payment.vkey --verification-key-file payment-non-extended.vkey

cardano-cli key convert-cardano-address-key --shelley-stake-key --signing-key-file root.xsk --out-file many.stake.skey
cardano-cli key verification-key --signing-key-file many.stake.skey --verification-key-file many.stake.vkey

## Maybe not required
# cardano-cli key non-extended-key --extended-verification-key-file stake.vkey --verification-key-file stake-non-extended.vkey
