echo -n "Copying SYSLinux PXE-Boot-Image and configuration... "

if [ ! -f "/${tftpRoot}/pxelinux.0" ]; then
        cp /usr/lib/syslinux/pxelinux.0 $tftpRoot/ && sudo mkdir $tftpRoot/pxelinux.cfg
fi

echo "done"
echo "------------------------------------------------------------------------"

