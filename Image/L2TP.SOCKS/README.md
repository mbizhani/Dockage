# L2TP/IPSec VPN with SOCKS5 Proxy via Docker

In this example an image is created to connect to an L2TP/IPSec VPN server, 
and then it provides a SOCKS5 proxy service via `ssh -D` to a server in the VPN zone.
So `SSH_HOST` refers to a host in the VPN zone with SSH service enabled. 

## Create Image

The commands to create the image:

```
git clone https://github.com/mbizhani/Dockage.git
cd Dockage/Image/L2TP.SOCK/
docker build -t l2tp-ipsec:01 .
```

## Run

```
docker run -it --rm \
  -e VPN_HOST='' \
  -e VPN_PSK='' \
  -e VPN_USER='' \
  -e VPN_PASS='' \
  -e SSH_HOST='' \
  -e SSH_USER='' \
  -e SSH_PASS='' \
  -p 5511:5511 \
  --cap-add=NET_ADMIN \
  --device=/dev/ppp \
  l2tp-ipsec:01
```

By default, for IPSec, the parameters `ike=3des-sha1-modp1024!` and `esp=3des-md5!` are set. 
It can be altered by passing env variable to Docker (`-e IPSEC_IKE='' -e IPSEC_ESP=''`). 
These two parameters define the encryption algorithms in the IPSec protocol.
The `VPN_PSK` is the pre-shared key.

**Note**: To find supporting encryption algorithms of the server, run the following command:

`docker run l2tp-ipsec:01 ike-scan HOST`

**DeBug-01**: Tonight, unfortunately the ssh client in the image could not connect. I run the ssh with `-v` for debug. 
The process got stuck after `debug1: expecting SSH2_MSG_KEX_DH_GEX_REPLY`.
This post, [ServerFault](https://serverfault.com/questions/210408/cannot-ssh-debug1-expecting-ssh2-msg-kex-dh-gex-reply), 
suggests setting MTU=1400. So I defined an env var `PPP_MTU=1400` in `Dockerfile`.

## About the Process

First, in `Dockerfile` following packages are installed:

- `kmod` - install `modprob` command to load modules for IPSec
- `ssh` & `sshpass` - for ssh connection and SOCKS5 service
- `net-tools` - for `ifconfig` and `route` commands
- `strongswan libnl-xfrm-3-200 libstrongswan-standard-plugins` - StrongSwan Linux packages for IPSec, with `XRFM` module and `standard plugins` to support `3DES`
- `ike-scan` - scan server for supporting encryption protocols
- `xl2tpd` - L2TP service in Linux

Then, in `run.sh` these steps are executed:

1. `run-ipsec.sh` - start `ipsec` service
2. `run-xl2tp.sh` - start `xl2tpd` service
3. `run-socks.sh` - start `ssh -D` and then block the execution to hold the container from exit


## Usage

Using this image, you can connect to your VPN without disturbing your preset network.
The following sections show using the proxy server to access all the servers and services in the VPN zone.

### SSH Connection

The `ssh` command supports `ProxyCommand` option. First you need to install `socat` package, and then call `ssh` as:

`ssh -o ProxyCommand='socat - socks:localhost:%h:%p,socksport=5511' USER@HOST`

In Remmina, edit your SSH connection and then in `Advanced` tab set `ProxyCommand` option like the above.


### Remote Desktop via Remmina

Due to [Remmina@GitLab](https://gitlab.com/Remmina/Remmina/issues/2046) and 
[AskUbuntu](https://askubuntu.com/questions/532676/rdp-client-for-ubuntu-with-proxy), it seems Remmina supports the proxy 
but there is no input field in the GUI. So edit your Remmina connection file in 
`~/.local/share/remmina/CONNECTION.remmina` and add **all** of the following lines:

```
proxy_type=socks5
proxy_hostname=localhost
proxy_port=5511
proxy_username=
proxy_password=
```

**Note**: It worked with Remmina version 1.4.1 (on Debian).


### Database Tools

[DBeaver](https://dbeaver.io/) is one of open source DB tools that supports SOCKS for connection to database. 
In the connection definition window, you can set proxy settings. However, since it is based on Java and it needs
JDBC drive, at the end it really depends on the JDBC drive support for SOCKS.

**Note**: Due to [Oracle](https://support.oracle.com/knowledge/Middleware/2589708_1.html), its JDBC drive support for SOCKS has changed:
> SOCKS proxy no longer works with JDBC 12.2 and up.
  Previously, the "socksProxyHost" and "socksProxyPort" Java Properties were used to allow the JDBC thin driver to 
  connect to a databases through a SOCKS proxy. This worked in versions 11.x and 12.1.x.
  Starting in 12.2.x, these settings no longer take effect, and connections are not sent through the SOCKS proxy. 
  The problem also exists in version 18.x.


### Git

Due to [cstan](https://cstan.io/?p=11673&lang=en), there are two ways to set proxy for `git`:

- Inline - `git -c http.proxy=socks5h://localhost:5511 ...`
- Global - `git config --global http.proxy socks5h://localhost:5511` (to unset `git config --global --unset http.proxy`)

Yes, it is `socks5h`! Totally, there are 4 options for SOCKS:

| Protocol     | Explanation
|--------------|-------------
| `socks4://`  | SOCKS4 proxy, DNS resolution via client
| `socks4h://` | SOCKS4 proxy, DNS resolution via remote system
| `socks5://`  | SOCKS5 proxy, DNS resolution via client
| `socks5h://` | SOCKS5 proxy, DNS resolution via remote system


### Maven

According to [cantara](https://wiki.cantara.no/display/dev/Smoother+Development+with+Maven+FAQ#SmootherDevelopmentwithMavenFAQ-Howtouseasocksproxy),
there are three ways to set SOCKS for maven:

1. Globally - edit `~/.m2/settings.xml` and add proxy
2. Shell Scope - `export MAVEN_OPTS="-DsocksProxyHost=localhost -DsocksProxyPort=5511"`
3. Inline - `mvn -DsocksProxyHost=localhost -DsocksProxyPort=5511 ...`

## Acknowledge

During developing this project, I asked lots of questions from my friend [Saeb](http://sae13.ir/). Thank you Saeb.