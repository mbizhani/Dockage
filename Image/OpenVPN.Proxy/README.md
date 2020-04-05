# OpenVPN with HTTP/SOCKS5 Proxy via Docker

In this example an image is created to connect to an OpenVPN server, 
and then it provides a HTTP/SOCKS5 proxy service via `Squid`/`Dante` 
in the container.

## Create Image

The commands to create the image:

```
git clone https://github.com/mbizhani/Dockage.git
cd Dockage/Image/OpenVPN.Proxy
docker build -t localproxy:1 .
```

## Run

In this image you can use only SOCKS5 proxy, or HTTP proxy, or even both of them together.
Now suppose you have a file having openvpn connection information, called `myvpn.ovpn`.
For passing username and password create a file called `myrealm.txt` beside your OVPN file as

```
USERNAME
PASSWORD
```

You can start your vpn/proxy container executing following command 
inside the directory having two previous files:

```
SOCKS_PORT=5511

docker run \
  --rm \
  -it \
  -v $(pwd):/cfg \
  -e OVPN_CFG=myvpn.ovpn \
  -e OVPN_RLM=myrealm.txt \
  -e SOCKS_PROXY_PORT=${SOCKS_PORT} \
  -p ${SOCKS_PORT}:${SOCKS_PORT} \
  --cap-add=NET_ADMIN \
  --name localproxy \
  localproxy:1
```

There are other env variables you can add to the above command:

- `HTTP_PROXY_PORT=PORT` - enables HTTP proxy (you then need another `-p` for this port)
- `DEBUG='Y'` - shows a `multitail` console watching logs of services in the container, good for debug
