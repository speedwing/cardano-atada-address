FROM ubuntu:20.04 as libsodium

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y automake build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev \
    zlib1g-dev make g++ tmux git jq curl libncursesw5 libtool autoconf llvm libnuma-dev

# Install Libsodium
WORKDIR /build/libsodium
RUN git clone https://github.com/input-output-hk/libsodium
RUN cd libsodium && \
    git checkout 66f017f1 && \
    ./autogen.sh && ./configure && make && make install

FROM ubuntu:20.04

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y jq libnuma-dev curl git netbase bc xxd vim socat && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /root
RUN git clone --depth 1 https://github.com/gitmachtl/scripts.git
ENV PATH /root/scripts/cardano/mainnet:$PATH

WORKDIR /data/cardano-address
RUN curl -L https://github.com/input-output-hk/cardano-addresses/releases/download/3.5.0/cardano-addresses-3.5.0-linux64.tar.gz | \
    tar xzv -C /data/cardano-address && \
    mv /data/cardano-address/cardano-address /usr/local/bin/cardano-address

WORKDIR /data/cardano-node
RUN curl -L https://hydra.iohk.io/build/9941151/download/1/cardano-node-1.33.0-linux.tar.gz | \
    tar xzv -C /data/cardano-node && \
    cp /data/cardano-node/cardano-node /usr/local/bin/ && \
    cp /data/cardano-node/cardano-cli /usr/local/bin/ && \
    mkdir -p /etc/config && \
    cp -r /data/cardano-node/configuration/cardano/* /etc/config/

WORKDIR /data/cardano-hw-cli
RUN curl -L https://github.com/vacuumlabs/cardano-hw-cli/releases/download/v1.9.1/cardano-hw-cli-1.9.1_linux-x64.tar.gz | \
    tar xzv -C /data/cardano-hw-cli && \
    cp /data/cardano-hw-cli/cardano-hw-cli/cardano-hw-cli /usr/local/bin/

WORKDIR /data/token-metadata-creator
RUN curl -L https://github.com/input-output-hk/offchain-metadata-tools/releases/download/v0.3.0.0/token-metadata-creator.tar.gz | \
    tar xzv -C /data/token-metadata-creator && \
    cp /data/token-metadata-creator/token-metadata-creator /usr/local/bin/

# Adding ENV vars so
ENV LD_LIBRARY_PATH="/usr/local/lib"
ENV PKG_CONFIG_PATH="/usr/local/lib/pkgconfig"

COPY --from=libsodium /usr/local/lib /usr/local/lib

# Init ATADA scripts
COPY atada /root/atada/
RUN /root/atada/init-mainnet.sh
COPY *.sh /root

RUN mkdir /db
ENV CARDANO_NODE_SOCKET_PATH /db/node.socket

WORKDIR /root

ENTRYPOINT ["bash", "-c"]
