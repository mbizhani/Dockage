#!/bin/bash

echo '*****************************'
echo '******** Start Squid ********'
echo '*****************************'

mv -f /etc/squid/squid.conf /etc/squid/orig.squid.conf
cat > /etc/squid/squid.conf << EOF
http_port ${HTTP_PROXY_PORT}

access_log /var/log/squid/access.log squid

#Suggested default:
refresh_pattern ^ftp:		1440	20%	10080
refresh_pattern ^gopher:	1440	0%	1440
refresh_pattern -i (/cgi-bin/|\?) 0 0% 0
refresh_pattern .		0	20%	4320

# Leave coredumps in the first cache dir
coredump_dir /var/spool/squid3

# Allow all machines to all sites
http_access allow all

EOF

echo "'/etc/squid/squid.conf' created"

/usr/sbin/squid

echo "'squid' started"