FROM debian:bullseye-slim

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install --no-install-recommends -y dnsmasq procps

EXPOSE 53/tcp 53/udp

VOLUME ["/etc/dnsmasq.d"]

CMD ["dnsmasq", "-d", "-7", "/etc/dnsmasq.d/,*.conf", "--local-service"]