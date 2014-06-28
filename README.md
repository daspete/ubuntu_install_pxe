ubuntu_install_pxe
==================

easy install script for a Ubuntu-PXE-Server

# HowTo

Clone the repo with git in your current folder

`git clone https://github.com/daspete/ubuntu_install_pxe.git`

get into the new folder

`cd ubuntu_install_pxe`

edit config.sh to your needs (network configuration and directory config)

start 'createPXE.sh'

`sudo ./createPXE.sh`

*Note: if you get an no permission error, you have to `chmod -R a+x *` in the root folder of the createPXE script*




