# MacOS ATADA with Daedalus

Launch Daedalus 

## Build the docker image

```bash
./build-atada-scripts.sh
```

## Launch Socat Host Side

Unfortunately docker cannot pass sockets to containers. We need to use socat.

### Find host ip

```bash
ifconfig -a
```

Once we find out what the ip is, we can launch socat host side.

```bash
./launch-socat-client.sh
```

## Launch ATADA container

./run-atada-scripts.sh

### Launch Socat client side

