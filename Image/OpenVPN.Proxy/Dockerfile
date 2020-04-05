FROM debian:buster-slim

COPY files /

RUN chmod +x /run.sh && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get install --no-install-recommends -y openvpn squid3 dante-server multitail

ENV OVPN_RLM='' OVPN_CFG='' OVPN_CFG_DIR='/cfg' \
    SOCKS_PROXY_PORT='' HTTP_PROXY_PORT='' \
    DEBUG=''

CMD ["/run.sh"]
