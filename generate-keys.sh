#!/usr/bin/env bash

if [ ! -f ./phrase.prv ]; then
  echo "phrase.prv does not exist. Run:"
  echo "echo \"my mnemonic phrase\" > phrase.prv"
  echo "and try again"
  exit 1
fi

function cardano-address-testnet-init() {

  NETWORK_TAG=testnet
  MAGIC="--testnet-magic 1097911063"

}

function cardano-address-mainnet-init() {

  NETWORK_TAG=mainnet
  MAGIC="--mainnet"

}

function cardano-address-create-wallet() {

  cardano-address-mainnet-init

  WALLET_DIR=${HOME}
  ROOT_PRIV_KEY_FILE=${WALLET_DIR}/root.prv
  MNEMONICS_PRIV_FILE=${WALLET_DIR}/phrase.prv
  STAKE_XPRIV_KEY_FILE=${WALLET_DIR}/stake.xprv
  STAKE_XPUB_KEY_FILE=${WALLET_DIR}/stake.xpub
  STAKE_ADDRESS_FILE=${WALLET_DIR}/many.staking.addr
  STAKE_CERT_FILE=${WALLET_DIR}/many.staking.cert
  STAKE_SKEY_FILE=${WALLET_DIR}/many.staking.skey
  STAKE_EVKEY_FILE=${WALLET_DIR}/many.staking.evkey
  STAKE_VKEY_FILE=${WALLET_DIR}/many.staking.vkey
  PAYMENT_XPRV_KEY_FILE=${WALLET_DIR}/payment.xprv
  PAYMENT_XPUB_KEY_FILE=${WALLET_DIR}/payment.xpub
  PAYMENT_ADDRESS_FILE=${WALLET_DIR}/payment.addr
  PAYMENT_SKEY_FILE=${WALLET_DIR}/many.payment.skey
  PAYMENT_EVKEY_FILE=${WALLET_DIR}/many.payment.evkey
  PAYMENT_VKEY_FILE=${WALLET_DIR}/many.payment.vkey
  DELEGATION_ADDRESS_FILE=${WALLET_DIR}/delegation.addr
  BASE_ADDRESS_CANDIDATE_FILE=${WALLET_DIR}/base.addr_candidate
  BASE_ADDRESS_FILE=${WALLET_DIR}/base.addr

  # Generate mnemonics and root key
  cat ${MNEMONICS_PRIV_FILE} | \
    cardano-address key from-recovery-phrase Shelley > ${ROOT_PRIV_KEY_FILE}
  # Generate account keys
  cat ${ROOT_PRIV_KEY_FILE} | cardano-address key child 1852H/1815H/0H/0/0 > ${PAYMENT_XPRV_KEY_FILE}
  cat ${PAYMENT_XPRV_KEY_FILE} | cardano-address key public --with-chain-code | tee ${PAYMENT_XPUB_KEY_FILE} | \
    cardano-address address payment --network-tag ${NETWORK_TAG} > ${PAYMENT_ADDRESS_FILE}
  cat ${PAYMENT_XPRV_KEY_FILE} | cardano-address key inspect > ${PAYMENT_SKEY_FILE}
  # Generate stake keys
  cat ${ROOT_PRIV_KEY_FILE} | cardano-address key child 1852H/1815H/0H/2/0 > ${STAKE_XPRIV_KEY_FILE}
  cat ${STAKE_XPRIV_KEY_FILE} | \
    cardano-address key public --with-chain-code | tee ${STAKE_XPUB_KEY_FILE} | \
    cardano-address address stake --network-tag ${NETWORK_TAG} > ${STAKE_ADDRESS_FILE}
  cat ${STAKE_XPRIV_KEY_FILE} | cardano-address key inspect > ${STAKE_SKEY_FILE}
  cat ${PAYMENT_XPRV_KEY_FILE} | \
    cardano-address key public --with-chain-code | \
    cardano-address address payment --network-tag ${NETWORK_TAG} | \
    cardano-address address delegation $(cat ${STAKE_XPRIV_KEY_FILE} | cardano-address key public --with-chain-code | tee ${STAKE_XPUB_KEY_FILE}) > ${BASE_ADDRESS_CANDIDATE_FILE}
  # Inspired by https://gist.github.com/ilap/5af151351dcf30a2954685b6edc0039b#script
  SESKEY=$( cat ${STAKE_XPRIV_KEY_FILE} | bech32 | cut -b -128 )$( cat ${STAKE_XPUB_KEY_FILE} | bech32)
  PESKEY=$( cat ${PAYMENT_XPRV_KEY_FILE} | bech32 | cut -b -128 )$( cat ${PAYMENT_XPUB_KEY_FILE} | bech32)

  cat << EOF2 > ${STAKE_SKEY_FILE}
{
    "type": "StakeExtendedSigningKeyShelley_ed25519_bip32",
    "description": "",
    "cborHex": "5880$SESKEY"
}
EOF2

  cat << EOF3 > ${PAYMENT_SKEY_FILE}
{
    "type": "PaymentExtendedSigningKeyShelley_ed25519_bip32",
    "description": "Payment Signing Key",
    "cborHex": "5880$PESKEY"
}
EOF3

  cardano-cli key verification-key --signing-key-file ${STAKE_SKEY_FILE} --verification-key-file ${STAKE_EVKEY_FILE}
  cardano-cli key verification-key --signing-key-file ${PAYMENT_SKEY_FILE} --verification-key-file ${PAYMENT_EVKEY_FILE}

  cardano-cli key non-extended-key --extended-verification-key-file ${STAKE_EVKEY_FILE} --verification-key-file ${STAKE_VKEY_FILE}
  cardano-cli key non-extended-key --extended-verification-key-file ${PAYMENT_EVKEY_FILE} --verification-key-file ${PAYMENT_VKEY_FILE}

  cardano-cli stake-address build --stake-verification-key-file ${STAKE_VKEY_FILE} $MAGIC > ${STAKE_ADDRESS_FILE}
  cardano-cli stake-address registration-certificate --stake-verification-key-file ${STAKE_VKEY_FILE} --out-file ${STAKE_CERT_FILE}
  cardano-cli address build --payment-verification-key-file ${PAYMENT_VKEY_FILE} $MAGIC > ${PAYMENT_ADDRESS_FILE}
  cardano-cli address build \
      --payment-verification-key-file ${PAYMENT_VKEY_FILE} \
      --stake-verification-key-file ${STAKE_VKEY_FILE} \
      $MAGIC > ${BASE_ADDRESS_FILE}

}

cardano-address-create-wallet
