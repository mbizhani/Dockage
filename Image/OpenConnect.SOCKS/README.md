# OpenConnect with SOCKS Proxy via Docker

In this example an image is created to connect to an OpenConnect VPN server,
and then it provides a SOCKS5 proxy service via `ssh -D` to a server in the VPN zone.
So `SSH_HOST` refers to a host in the VPN zone with SSH service enabled.


## Create Image

The commands to create the image:

```
git clone https://github.com/mbizhani/Dockage.git
cd Dockage/Image/OpenConnect.SOCKS/
docker build -t opencon-socks:01 .
```


## Run

```
docker run -it --rm \
  -e VPN_HOST='' \
  -e VPN_USER='' \
  -e VPN_PASS='' \
  -e SSH_HOST='' \
  -e SSH_USER='' \
  -e SSH_PASS='' \
  -p 5511:5511 \
  --cap-add=NET_ADMIN \
  opencon-socks:01
```

Other environment variables
- `VPN_CERT` - the script `run-openconnect.sh` trys to find the `--servercert`. If not, pass it through this env var.
- `VPN_PROTO` (default `anyconnect`) - It can be `anyconnect`, `nc`, `gp`, and `pulse`
  - `anyconnect` - Compatible with Cisco AnyConnect SSL VPN, as well as `ocserv` (default)
  - `nc` - Compatible with Juniper Network Connect
  - `gp` - Compatible with Palo Alto Networks (PAN) GlobalProtect SSL VPN
  - `pulse` - Compatible with Pulse Connect Secure SSL VPN