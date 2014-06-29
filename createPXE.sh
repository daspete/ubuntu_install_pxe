#!/bin/bash

clear

greenBlack='\E[32;40m'
redBlack='\E[31;40m'

echo -e "$greenBlack"

source ./config.sh

echo "EASY PXE-SERVER-INSTALLER 0.0.1a"
echo "------------------------------------------------------------------------"

echo -e "$redBlack"; source ./scripts/installDep.sh
echo -e "$greenBlack"; source ./scripts/configDHCP.sh
echo -e "$redBlack"; source ./scripts/configTFTP.sh
echo -e "$greenBlack"; source ./scripts/createSyslinux.sh
echo -e "$redBlack"; source ./scripts/copyImage.sh
echo -e "$greenBlack"; source ./scripts/configNFS.sh
echo -e "$redBlack"; source ./scripts/makeBootMenu.sh


