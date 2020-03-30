FROM debian:buster-slim

COPY files /

RUN chmod +x /run.sh && \
    apt-get update && \
	apt-get -y upgrade && \
    apt-get install --no-install-recommends -y \
       kmod ssh sshpass net-tools \
       strongswan ike-scan libnl-xfrm-3-200 libstrongswan-standard-plugins \
       xl2tpd

EXPOSE 5511

ENV VPN_HOST='' VPN_PSK='' VPN_USER='' VPN_PASS='' \
    SSH_HOST='' SSH_USER='' SSH_PASS='' \
    IPSEC_IKE='3des-sha1-modp1024!' IPSEC_ESP='3des-md5!'

CMD ["/run.sh"]