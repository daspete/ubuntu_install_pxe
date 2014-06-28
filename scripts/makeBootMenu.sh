echo -n "Creating Boot-Menu-Entry... "

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

