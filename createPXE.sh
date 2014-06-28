#!/bin/bash

source ./config.sh

source ./scripts/installDep.sh

source ./scripts/configDHCP.sh

source ./scripts/createSyslinux.sh

source ./scripts/configTFTP.sh

source ./scripts/copyImage.sh

source ./scripts/configNFS.sh

source ./scripts/makeBootMenu.sh


