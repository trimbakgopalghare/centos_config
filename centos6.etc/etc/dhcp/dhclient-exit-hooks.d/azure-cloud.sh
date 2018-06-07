#!/bin/sh
#
# This script provides support for dynamic DNS update in Microsoft Azure
# cloud. To enable this feature, change the configuration variables below
# and make the script executable.

primary_interface="eth0"
required_domain="mydomain.local"

[ "$interface" == "$primary_interface" ] || exit

case "$reason" in
BOUND|RENEW|REBIND|REBOOT)
    fqdn="`hostname`.$required_domain"
    nsupdate <<EOF
update delete $fqdn a
update add $fqdn 3600 a $new_ip_address
send
EOF
    ;;
esac
