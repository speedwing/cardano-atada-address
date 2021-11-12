ARG CARDANO_VERSION="1.30.1"
ARG OS_ARCH

FROM speedwing/cardano-node:${CARDANO_VERSION}-${OS_ARCH} as cardano-node

FROM ubuntu:20.04

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y jq libnuma-dev curl git netbase bc xxd vim socat && \
    rm -rf /var/lib/apt/lists/*

## Libsodium refs
COPY --from=cardano-node /usr/local/lib /usr/local/lib

## Not sure I still need thse
ENV LD_LIBRARY_PATH="/usr/local/lib"
ENV PKG_CONFIG_PATH="/usr/local/lib/pkgconfig"

COPY --from=cardano-node /etc/config/* /etc/config/

COPY --from=cardano-node /usr/local/bin/cardano-cli /usr/local/bin/cardano-cli
COPY --from=cardano-node /usr/local/bin/cardano-node /usr/local/bin/cardano-node

WORKDIR /root
RUN git clone --depth 1 https://github.com/gitmachtl/scripts.git
ENV PATH /root/scripts/cardano/mainnet:$PATH

WORKDIR /data/cardano-address
RUN curl -L https://github.com/input-output-hk/cardano-addresses/releases/download/3.5.0/cardano-addresses-3.5.0-linux64.tar.gz | \
         tar xzv -C /data/cardano-address

# Init ATADA scripts
COPY atada /root/atada/
RUN /root/atada/init-mainnet.sh
COPY *.sh /root

RUN mv /data/cardano-address/cardano-address /usr/local/bin/cardano-address

ENV CARDANO_NODE_SOCKET_PATH /db/node.socket

WORKDIR /root

ENTRYPOINT ["bash", "-c"]
