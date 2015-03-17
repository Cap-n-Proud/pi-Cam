#!/bin/bash

# to download the latest repository: 
#git clone https://github.com/pfnegrini/time-lapse-server.git /home/pi/time-lapse-server

asd() {
cat <<"EOT"




                         .^.
                         /   \
                        /     \
                *******/       \*******
           ***** *****/         \***** *****
       ***** ********/           \******** *****
      *** **********/             \********** ***
       ***** ******/               \****** *****
           ***** */        _**_     \* *****
                */      _-******\    \*
                /    _-" *****   "\   \
                \__-"              "\_/



EOT
}

asd

echo -n "Want to confgure RaspberryPi? [Y/N]"
read BUILDUP

git clone https://github.com/sarfata/pi-blaster.git /home/pi/pi-blaster


if [ "$BUILDUP" == "Y" ]
then
  git clone https://github.com/pfnegrini/BuildUP.git /home/pi/BuildUP
  sudo bash /home/pi/BuildUP/RPi-init.sh
fi

echo -e "***** Setting up  TLserver *****"
sudo cp TLserver /etc/init.d/TLserver
sudo chmod 0755 /etc/init.d/TLserver
sudo update-rc.d TLserver defaults

mkdir /home/pi/Documents
sudo chmod 0755 /home/pi/Documents

mkdir /home/pi/Documents/TL
sudo chmod 0755 /home/pi/Documents/TL

mkdir /home/pi/Documents/SN
sudo chmod 0755 /home/pi/Documents/SN

#Install PiBlaster
echo -e "***** Installing PiBLaster *****"
sudo apt-get install -y autoconf
git clone https://github.com/sarfata/pi-blaster.git /home/pi/pi-blaster

cd /home/pi/pi-blaster
./autogen.sh
./configure
sudo make
sudo make install
sudo npm install -g pi-blaster.js

exit 0
