FROM debian:bullseye-slim

COPY files /

RUN chmod +x /run.sh && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get install --no-install-recommends -y openconnect ssh sshpass net-tools

EXPOSE 5511

ENV VPN_HOST='' VPN_USER='' VPN_PASS='' VPN_CERT='' VPN_PROTO='anyconnect' \
    SSH_HOST='' SSH_USER='' SSH_PASS='' SLEEP=5

CMD ["/run.sh"]