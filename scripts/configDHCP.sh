source ./config.sh

echo "DHCP-Server-Config"
echo "------------------------------------------------------------------------"
echo -n "Your network (default: $netAdd) -> ";read userNetAdd;
echo -n "Broadcast IP (default: $netBroad) -> ";read userNetBroad;
echo -n "IP of this PXE-Server (default: $netIP) -> ";read userNetIP;
echo -n "Netmask (default: $netMask) -> ";read userNetMask;
echo -n "Router (default: $netRouter) -> ";read userNetRouter;
echo -n "IP Range-Start for the Clients (default: $netRangeStart) -> ";read userNetRangeStart;
echo -n "IP Range-Stop for the Clients (default: $netRangeStop) -> ";read userNetRangeStop;

if [ "$userNetAdd" != "" ]; then netAdd=$userNetAdd; fi
if [ "$userNetBroad" != "" ]; then netBroad=$userNetBroad; fi
if [ "$userNetIP" != "" ]; then netIP=$userNetIP; fi
if [ "$userNetMask" != "" ]; then netMask=$userNetMask; fi
if [ "$userNetRouter" != "" ]; then netRouter=$userNetRouter; fi
if [ "$userNetRangeStart" != "" ]; then netRangeStop=$userNetRangeStart; fi
if [ "$userNetRangeStop" != "" ]; then netRangeStop=$userNetRangeStop; fi

if [ -f "/etc/dhcp/dhcpd.conf" ]; then
        echo "------------------------------------------------------------------------"
        echo -n "creating backup of your DHCP-Configuration... "
        mv /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bak
        echo "done"
fi

echo -n "writing new DHCP-Configuration..."

        echo "authoritative;" >> /etc/dhcp/dhcpd.conf
        echo "allow booting;" >> /etc/dhcp/dhcpd.conf
        echo "allow bootp;"  >> /etc/dhcp/dhcpd.conf
        echo "subnet $netAdd netmask $netMask {" >> /etc/dhcp/dhcpd.conf
        echo "        range $netRangeStart $netRangeStop;" >> /etc/dhcp/dhcpd.conf
        echo "        default-lease-time 600;" >> /etc/dhcp/dhcpd.conf
        echo "        max-lease-time 7200;" >> /etc/dhcp/dhcpd.conf
        echo "        option broadcast-address $netBroad;" >> /etc/dhcp/dhcpd.conf
        echo "        option subnet-mask $netMask;" >> /etc/dhcp/dhcpd.conf
        echo "        option routers $netRouter;" >> /etc/dhcp/dhcpd.conf
        echo "}" >> /etc/dhcp/dhcpd.conf
        echo "next-server $netIP;" >> /etc/dhcp/dhcpd.conf
        echo 'filename "/pxelinux.0";'  >> /etc/dhcp/dhcpd.conf

echo "done"
echo "------------------------------------------------------------------------"
