FROM debian:bullseye-slim

ENV ADMINER_VERSION=4.8.1 MEMORY=256M UPLOAD=2048M LD_LIBRARY_PATH="/usr/local/lib;/usr/local/instantclient" \
    WORKERS=4 PHP_CLI_SERVER_WORKERS=${WORKERS}

COPY files /tmp

# DEPENDENCIES #################################################################
RUN apt-get update && \
    apt install -y apt-transport-https lsb-release ca-certificates curl && \
    mkdir -p /etc/apt/trusted.gpg.d && \
    curl -L -o /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list' && \
    apt-get update && \
    apt-get install -y \
        make \
        autoconf \
        g++ \
        unzip \
        libaio1 \
        ca-certificates \
        php8.1 \
        php8.1-dev \
        php8.1-xml \
    		php8.1-mongodb \
        php8.1-mysql \
        php8.1-pgsql \
        php-pear \
        tini && \
    curl -L -o /srv/index.php https://github.com/vrana/adminer/releases/download/v$ADMINER_VERSION/adminer-$ADMINER_VERSION.php && \
    # OCI8 (ORACLE) ################################################################
    unzip /tmp/instantclient-basic-linux.x64-12.2.0.1.0.zip -d /usr/local/ && \
    unzip /tmp/instantclient-sdk-linux.x64-12.2.0.1.0.zip -d /usr/local/ && \
    ln -s /usr/local/instantclient_12_2 /usr/local/instantclient && \
    ln -s /usr/local/instantclient/libclntsh.so.12.1 /usr/local/instantclient/libclntsh.so && \
    echo 'instantclient,/usr/local/instantclient' | pecl install oci8 && \
    echo "extension=oci8.so" > /etc/php/8.1/cli/conf.d/00-oci8.ini && \
    # CLEAN UP #####################################################################
    apt-get clean -y && \
    apt-get autoclean -y && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /var/lib/log/* /tmp/* /var/tmp/*

WORKDIR /srv

EXPOSE 80

ENTRYPOINT ["/usr/bin/tini", "--"]

CMD /usr/bin/php \
    -d memory_limit=$MEMORY \
    -d upload_max_filesize=$UPLOAD \
    -d post_max_size=$UPLOAD \
    -S 0.0.0.0:80