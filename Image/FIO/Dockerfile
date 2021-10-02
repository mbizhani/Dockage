FROM debian:buster

COPY fio-fs.sh /bin/

RUN chmod +x /bin/fio-fs.sh && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y --no-install-recommends fio

CMD ["bash"]