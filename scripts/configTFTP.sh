if [ -f "/etc/default/tftpd-hpa" ]; then
        echo -n "Creating Backup of the TFTP-Configuration..."
        mv /etc/default/tftpd-hpa /etc/default/tftpd-hpa.bak
        echo "done"
fi

echo -n "writing TFTP-Configuration... "

if [ ! -d $tftpRoot ]; then
        mkdir -p $tftpRoot
fi

        echo "RUN_DEAMON='yes'" >> /etc/default/tftpd-hpa
        echo "OPTIONS='-l -s $tftpRoot'" >> /etc/default/tftpd-hpa
        echo "TFTP_USERNAME='tftp'" >> /etc/default/tftpd-hpa
        echo "TFTP_DIRECTORY='$tftpRoot'" >> /etc/default/tftpd-hpa
        echo "TFTP_ADDRESS='0.0.0.0:69'" >> /etc/default/tftpd-hpa
        echo "TFTP_OPTIONS='-l -s'" >> /etc/default/tftpd-hpa

echo "done"
echo "Restarting TFTP-Server"
service tftpd-hpa restart
echo "------------------------------------------------------------------------"

