#!/bin/bash

echo "Installing dependencies (DHCP-Server, TFTP-Server, NFS-Server, SYSLINUX)"
echo "------------------------------------------------------------------------"
echo -n "Please hang on a moment... "

apt-get -y install dhcp3-server tftpd-hpa nfs-kernel-server syslinux > /dev/null

echo "ready"
echo "------------------------------------------------------------------------"

