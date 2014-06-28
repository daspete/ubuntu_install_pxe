echo "------------------------------------------------------------------------"
echo -n "Creating NFS Export... "



if grep -q "${tftpRoot}/${DISTRO}" /etc/exports; then
        echo
else
        echo "${tftpRoot}/${DISTRO}   *(ro,sync,no_subtree_check)" >> /etc/exports
fi

echo "Restarting NFS-Server"
/etc/init.d/nfs-kernel-server reload
echo "------------------------------------------------------------------------"
