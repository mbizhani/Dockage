FROM debian:bullseye-slim

COPY files/* /

RUN apt-get update &&  \
    apt-get upgrade --yes && \
    apt-get install --no-install-recommends --yes tini procps

ENV TOP_OPTS="-b"

ENTRYPOINT ["tini", "-v","-g", "--"]
CMD ["sh", "-c", "/test.sh"]
