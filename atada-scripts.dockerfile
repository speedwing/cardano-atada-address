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
RUN curl -L https://hydra.iohk.io/build/8110920/download/1/cardano-node-1.31.0-linux.tar.gz | \
    tar xzv -C /data/cardano-node && \
    cp /data/cardano-node/cardano-node /usr/local/bin/ && \
    cp /data/cardano-node/cardano-cli /usr/local/bin/ && \
    mkdir -p /etc/config && \
    cp -r /data/cardano-node/configuration/cardano/* /etc/config/

WORKDIR /data/cardano-hw-cli
RUN curl -L https://github.com/vacuumlabs/cardano-hw-cli/releases/download/v1.9.0/cardano-hw-cli-1.9.0_linux-x64.tar.gz | \
    tar xzv -C /data/cardano-hw-cli && \
    cp /data/cardano-hw-cli/cardano-hw-cli/cardano-hw-cli /usr/local/bin/

# Init ATADA scripts
COPY atada /root/atada/
RUN /root/atada/init-mainnet.sh
COPY *.sh /root

RUN mkdir /db
ENV CARDANO_NODE_SOCKET_PATH /db/node.socket

WORKDIR /root

ENTRYPOINT ["bash", "-c"]
