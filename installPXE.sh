#!/bin/bash

netAdd="192.168.10.0"
netBroad="192.168.10.255"
netMask="255.255.255.0"
netIP="192.168.10.50"
netRouter="192.168.10.1"
netRangeStart="192.168.10.100"
netRangeStop="192.168.10.110"

tftpRoot="/srv/tftp"

#defaultImage="http://releases.ubuntu.com/releases/14.04/ubuntu-14.04-desktop-amd64.iso"
defaultImage="http://ftp5.gwdg.de/pub/linux/debian/ubuntu/iso/14.04/ubuntu-14.04-desktop-i386.iso"


if [[ $defaultImage == *amd64* ]]; then
	usekernel=vmlinuz.efi;
else
	usekernel=vmlinuz
fi

clear

echo "------------------------------------------------------------------------"
echo "EASY PXE-SERVER Installer 0.0.1a"
echo "------------------------------------------------------------------------"
echo "Installing dependencies (DHCP-Server, TFTP-Server, NFS-Server, SYSLINUX)"
echo "------------------------------------------------------------------------"
echo -n "Please hang on a moment... "
apt-get -y install dhcp3-server tftpd-hpa nfs-kernel-server syslinux > /dev/null
echo "ready"
echo "------------------------------------------------------------------------"
echo "DHCP-Server-Config"
echo "------------------------------------------------------------------------"
echo -n "Your network (default: 192.168.10.0) -> ";read userNetAdd;
echo -n "Broadcast IP (default: 192.168.10.255) -> ";read userNetBroad;
echo -n "IP of this PXE-Server (default: 192.168.10.50) -> ";read userNetIP;
echo -n "Netmask (default: 255.255.255.0) -> ";read userNetMask;
echo -n "Router (default: 192.168.10.1) -> ";read userNetRouter;
echo -n "IP Range-Start for the Clients (default: 192.168.10.100) -> ";read userNetRangeStart;
echo -n "IP Range-Stop for the Clients (default: 192.168.10.110) -> ";read userNetRangeStop;

if [ "$userNetAdd" != "" ]; then; netAdd=$userNetAdd; fi
if [ "$userNetBroad" != "" ]; then; netBroad=$userNetBroad; fi
if [ "$userNetIP" != "" ]; then; netIP=$userNetIP; fi
if [ "$userNetMask" != "" ]; then; netMask=$userNetMask; fi
if [ "$userNetRouter" != "" ]; then; netRouter=$userNetRouter; fi
if [ "$userNetRangeStart" != "" ]; then; netRangeStop=$userNetRangeStart; fi
if [ "$userNetRangeStop" != "" ]; then; netRangeStop=$userNetRangeStop; fi


if [ -f "/etc/dhcp/dhcpd.conf" ]; then
	echo "------------------------------------------------------------------------"
	echo -n "creating backup of your DHCP-Configuration... "
	mv /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bak
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

if [ ! -d "/srv/nfs/pxe" ]; then
	mkdir -p /srv/nfs/pxe
fi

if grep -q "/srv/nfs/pxe $netAdd/$netMask(rw,no_root_squash,sync,no_subtree_check)" /etc/exports; then
	echo
else
	echo "/srv/nfs/pxe $netAdd/$netMask(rw,no_root_squash,sync,no_subtree_check)" >> /etc/exports
fi

echo "done"
echo "------------------------------------------------------------------------"

echo "Restarting NFS-Server"
echo "------------------------------------------------------------------------"
/etc/init.d/nfs-kernel-server reload
echo "------------------------------------------------------------------------"

if [ -f "/etc/default/tftpd-hpa" ]; then
	echo -n "Creating Backup of the TFTP-Configuration..."
	mv /etc/default/tftpd-hpa /etc/default/tftpd-hpa.bak
	echo "done"
	echo "------------------------------------------------------------------------"
fi

echo -n "writing TFTP-Configuration... "

if [ ! -d $tftpRoot ]; then
	mkdir $tftpRoot
fi

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

if [ ! -f "/${tftpRoot}/pxelinux.0" ]; then
	cp /usr/lib/syslinux/pxelinux.0 $tftpRoot/ && sudo mkdir $tftpRoot/pxelinux.cfg
fi

echo "done"
echo "------------------------------------------------------------------------"

echo "Loading and copying your distribution"

if [ ! -z $1 ]; then
	FILE=$1

	if [ ! -f ${FILE} ]; then
		echo "File ${FILE} not found"
		exit 0
	fi
else
	URL=${defaultImage}
	FILE=/tmp/${URL##*/}
fi

ISO=${FILE##*/}
DISTRO=${ISO%.*}
DISTRO=${DISTRO//desktop/live}

if [ ! -f ${FILE} ]; then
	wget ${URL} -P /tmp
fi

mount ${FILE} /mnt/ -o loop
mkdir ${tftpRoot}/${DISTRO}
cp -a /mnt/casper/ ${tftpRoot}/${DISTRO}
umount /mnt

if grep -q "${tftpRoot}/${DISTRO}" /etc/exports; then
	echo
else
	echo "${tftpRoot}/${DISTRO}   *(ro,sync,no_subtree_check)" >> /etc/exports
fi

/etc/init.d/nfs-kernel-server restart

echo "------------------------------------------------------------------------"

echo -n "Creating Boot-Menu-Entry"

if [ ! -f "${tftpRoot}/pxelinux.cfg/${DISTRO}.conf" ]; then

cat <<EOF> ${tftpRoot}/pxelinux.cfg/${DISTRO}.conf
LABEL linux
   MENU LABEL Ubuntu Live (${DISTRO}) 
   KERNEL /${DISTRO}/casper/${usekernel}
   APPEND initrd=/${DISTRO}/casper/initrd.lz boot=casper netboot=nfs nfsroot=${netIP}:${tftpRoot}/${DISTRO} quiet splash locale=de_DE bootkbd=de console-setup/layoutcode=de --
   IPAPPEND 2
EOF

echo "MENU INCLUDE pxelinux.cfg/${DISTRO}.conf" >> ${tftpRoot}/pxelinux.cfg/default

fi

echo "done"
echo "------------------------------------------------------------------------"

echo "Congratulation :) you have now a PXE-Server running"
