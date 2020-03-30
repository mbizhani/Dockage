#!/bin/bash

echo '*****************************'
echo '******** Start XL2TP ********'
echo '*****************************'

cat > /etc/xl2tpd/xl2tpd.conf << EOF
[lac myvpn]
lns = ${VPN_HOST}
ppp debug = yes
pppoptfile = /etc/ppp/options.myvpn.client
length bit = yes
refuse pap = yes
refuse chap = yes

EOF
echo "'/etc/xl2tpd/xl2tpd.conf' created"

cat > /etc/ppp/options.myvpn.client << EOF
ipcp-accept-local
ipcp-accept-remote
refuse-eap
require-mschap-v2
noccp
noauth
idle 1800
mtu 1464
mru 1464
defaultroute
debug
connect-delay 5000
name ${VPN_USER}
password ${VPN_PASS}

EOF
echo "'/etc/ppp/options.myvpn.client' created"

echo "-------------------------------"

#ORIG_GW=$(ip r | grep 'default' | awk '{print $3 }')
#ORIG_LK=$(ip r | grep 'default' | awk '{print $5 }')
export ORIG_GW=$(route -n | grep -m 1 "^0\.0\.0\.0" | awk '{print $2}')
export ORIG_LK=$(route -n | grep -m 1 "^0\.0\.0\.0" | awk '{print $8}')
echo "GW=${ORIG_GW} Link=${ORIG_LK} VPN=${VPN_HOST}"

mkdir -p /var/run/xl2tpd
touch /var/run/xl2tpd/l2tp-control

/etc/init.d/xl2tpd start
sleep 2
echo "c myvpn" > /var/run/xl2tpd/l2tp-control

while [ ! "${PPP0_ADDR}" ]
do
#  PPP0_ADDR=$(ip a show ppp0 | grep "inet " | awk '{ print $2 }' | awk -F '/' '{print $1}')
  sleep 1
  PPP0_ADDR=$(ifconfig ppp0 | grep "inet " | awk '{print $2}')
done
echo "PPP0=${PPP0_ADDR}"

sleep 1

route add ${VPN_HOST} gw ${ORIG_GW} dev ${ORIG_LK}
echo "route 1/3: ok"
sleep 1

route add default gw ${PPP0_ADDR}
echo "route 2/3: ok"
sleep 1

route del default gw ${ORIG_GW}
echo "route 3/3: ok"
sleep 1

echo "-------------------------------"
route -n