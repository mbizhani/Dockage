#!/bin/bash

echo '*****************************'
echo '******** Start Dante ********'
echo '*****************************'

mv /etc/danted.conf /etc/orig.danted.cong

cat > /etc/danted.conf << EOF
debug: 0
logoutput: /var/log/danted.log
internal: 0.0.0.0 port = ${SOCKS_PROXY_PORT}
external: tun0
socksmethod: username none
clientmethod: none
user.privileged: root
user.unprivileged: nobody

client pass {
    from: 0.0.0.0/0 port 1-65535 to: 0.0.0.0/0
    log: error
}

socks pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: error
}
EOF

echo "'/etc/danted.conf' created"

/usr/sbin/danted -D

echo "'danted' started"