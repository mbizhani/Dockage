#!/bin/bash

echo '*****************************'
echo '******** Start IPSec ********'
echo '*****************************'

mv -f /etc/ipsec.conf /etc/orig.ipsec.conf
cat > /etc/ipsec.conf << EOF
config setup

conn myvpn
  auto=add
  authby=secret
  ike=${IPSEC_IKE}
  esp=${IPSEC_ESP}
  keyexchange=ikev1
  left=%defaultroute
  right=${VPN_HOST}
  type=transport
EOF
echo "'/etc/ipsec.conf' created"

mv -f /etc/ipsec.secrets /etc/orig.ipsec.secrets
cat > /etc/ipsec.secrets << EOF
%any ${VPN_HOST} : PSK "${VPN_PSK}"
EOF
echo "'/etc/ipsec.secrets' created"

echo "-------------------------------"

/usr/sbin/ipsec start
sleep 2
/usr/sbin/ipsec up myvpn
sleep 2
/usr/sbin/ipsec status