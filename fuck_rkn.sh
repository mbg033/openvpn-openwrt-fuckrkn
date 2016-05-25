#!/bin/sh
# original script location: https://gist.github.com/sourenaraya/f8729694c4bf0ba7cba1


VPN_DEV='tun0'
LOCALNET_DEV='br-lan'
MARK='0xACCE55'
TABLE='410'
IPSET_ADDRLIST_NAME='FuckRKN'
IPSET_FILE='/tmp/ipset.addrlist'
ANTIZAPRET_API_URL="https://api.antizapret.info/group.php"

# quirk..
logger "deleting routes added by openvpn client.."
ip route del 0.0.0.0/1 2>&1 | logger
ip route del 128.0.0.0/1 2>&1 | logger

logger "Starting fuck_rkn..."
IPLIST=$(wget --quiet -O-  $ANTIZAPRET_API_URL | sed -e 's/,/\n/g'| sort | uniq )
#IPLIST="192.230.64.4 185.11.124.4 192.230.65.4"

ipset -! create $IPSET_ADDRLIST_NAME hash:ip hashsize 65536

for ipaddr in $IPLIST
do
   echo "add $IPSET_ADDRLIST_NAME $ipaddr" >> $IPSET_FILE
done

ipset -! restore < $IPSET_FILE

iptables -t raw -A PREROUTING -m set --match-set $IPSET_ADDRLIST_NAME dst -j MARK --set-mark $MARK

# deleting old rules, if any
logger "deleting old rules.."

rc=0; 
while [ $rc -eq 0 ]; do
	ip rule del fwmark $MARK/$MARK lookup $TABLE; rc=$?; 
done


ip route add default dev $VPN_DEV table $TABLE
ip rule add fwmark $MARK/$MARK lookup $TABLE

logger "$IPSET_ADDRLIST_NAME iplist updated. $( cat $IPSET_FILE | wc -l ) addresses in list."


rm $IPSET_FILE