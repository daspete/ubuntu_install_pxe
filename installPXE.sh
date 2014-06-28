#!/bin/bash

netAdd="192.168.10.0"
netBroad="192.168.10.255"
netMask="255.255.255.0"
netIP="192.168.10.50"
netRouter="192.168.10.1"
netRangeStart="192.168.10.100"
netRangeStop="192.168.10.110"

tftpRoot="/srv/tftp"


clear
echo "------------------------------------------------------------------------"
echo "EASY PXE-SERVER Installer 0.0.1a"
echo "------------------------------------------------------------------------"
echo "Installing dependencies (DHCP-Server, TFTP-Server, NFS-Server, SYSLINUX)"
echo "------------------------------------------------------------------------"
echo -n "Please hang on a moment... "
sudo apt-get -y install dhcp3-server tftpd-hpa nfs-kernel-server syslinux > /dev/null
echo "ready"
echo "------------------------------------------------------------------------"
echo "DHCP-Server-Config"
echo "------------------------------------------------------------------------"
echo -n "Your network (default: 192.168.10.0) -> ";
read userNetAdd;
echo -n "Broadcast IP (default: 192.168.10.255) -> ";
read userNetBroad;
echo -n "IP of this PXE-Server (default: 192.168.10.50) -> ";
read userNetIP;
echo -n "Netmask (default: 255.255.255.0) -> ";
read userNetMask;
echo -n "Router (default: 192.168.10.1) -> ";
read userNetRouter;
echo -n "IP Range-Start for the Clients (default: 192.168.10.100) -> ";
read userNetRangeStart;
echo -n "IP Range-Stop for the Clients (default: 192.168.10.110) -> ";
read userNetRangeStop;

if [ "$userNetAdd" != "" ]; then
	netAdd=$userNetAdd
fi
if [ "$userNetBroad" != "" ]; then
	netBroad=$userNetBroad
fi
if [ "$userNetIP" != "" ]; then
	netIP=$userNetIP
fi
if [ "$userNetMask" != "" ]; then
	netMask=$userNetMask
fi
if [ "$userNetRouter" != "" ]; then
	netRouter=$userNetRouter
fi
if [ "$userNetRangeStart" != "" ]; then
	netRangeStop=$userNetRangeStart
fi
if [ "$userNetRangeStop" != "" ]; then
	netRangeStop=$userNetRangeStop
fi


if [ -f "/etc/dhcp/dhcpd.conf" ]; then
	echo "------------------------------------------------------------------------"
	echo -n "creating backup of your DHCP-Configuration... "
	sudo mv /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bak
	echo "done"
fi


echo "------------------------------------------------------------------------"
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
echo -n "Creating NFS Export... "


sudo mkdir -p /srv/nfs/pxe
sudo echo "/srv/nfs/pxe $netAdd/$netMask(rw,no_root_squash,sync,no_subtree_check)" >> /etc/exports

echo "done"
echo "------------------------------------------------------------------------"
echo "Restarting NFS-Server"
echo "------------------------------------------------------------------------"
sudo /etc/init.d/nfs-kernel-server reload
echo "------------------------------------------------------------------------"

if [ -f "/etc/default/tftpd-hpa" ]; then
	echo -n "Creating Backup of the TFTP-Configuration..."
	sudo mv /etc/default/tftpd-hpa /etc/default/tftpd-hpa.bak
	echo "done"
	echo "------------------------------------------------------------------------"
fi

echo -n "writing TFTP-Configuration... "

sudo mkdir $tftpRoot

echo "RUN_DEAMON='yes'" >> /etc/default/tftpd-hpa
echo "OPTIONS='-l -s $tftpRoot'" >> /etc/default/tftpd-hpa
echo "TFTP_USERNAME='tftp'" >> /etc/default/tftpd-hpa
echo "TFTP_DIRECTORY='$tftpRoot'" >> /etc/default/tftpd-hpa
echo "TFTP_ADDRESS='0.0.0.0:69'" >> /etc/default/tftpd-hpa
echo "TFTP_OPTIONS='-l -s'" >> /etc/default/tftpd-hpa

echo "done"
echo "------------------------------------------------------------------------"
echo "Restarting TFTP-Server"
echo "------------------------------------------------------------------------"
service tftpd-hpa restart
echo "------------------------------------------------------------------------"
echo -n "Copying SYSLinux PXE-Boot-Image and configuration... "

sudo cp /usr/lib/syslinux/pxelinux.0 $tftpRoot/ && sudo mkdir $tftpRoot/pxelinux.cfg

echo "done"
echo "------------------------------------------------------------------------"
