#!/bin/bash

netAdd="192.168.10.0"
netBroad="192.168.10.255"
netMask="255.255.255.0"
netIP="192.168.10.50"
netRouter="192.168.10.1"
netRangeStart="192.168.10.100"
netRangeStop="192.168.10.110"

tftpRoot="/srv/tftp"

defaultImage="http://releases.ubuntu.com/releases/14.04/ubuntu-14.04-desktop-i386.iso"
#defaultImage="http://releases.ubuntu.com/releases/14.04/ubuntu-14.04-desktop-amd64.iso"


if [[ $defaultImage == *amd64* ]]; then
        usekernel=vmlinuz.efi;
else
        usekernel=vmlinuz
fi

