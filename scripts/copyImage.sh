echo "Loading and copying your distribution"
echo "------------------------------------------------------------------------"

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

umount /mnt > /dev/null
mount ${FILE} /mnt/ -o loop > /dev/null
if [ ! -d "${tftpRoot}/${DISTRO}" ]; then
        mkdir ${tftpRoot}/${DISTRO}
fi

rm -rf  ${tftpRoot}/${DISTRO}/* > /dev/null
cp -a /mnt/casper/ ${tftpRoot}/${DISTRO} > /dev/null
umount /mnt > /dev/null

