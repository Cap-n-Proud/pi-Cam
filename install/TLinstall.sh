#!/bin/bash

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


echo -e "***** Setting up  TLserver *****"
sudo cp TLserver /etc/init.d/TLserver
sudo chmod 0755 /etc/init.d/TLserver
sudo update-rc.d TLserver defaults

mkdir /home/pi/Documents
sudo chmod 0755 /home/pi/Documents

mkdir /home/pi/Documents/TL
sudo chmod 0755 /home/pi/Documents/TL

#Need also to install piblaster https://github.com/sarfata/pi-blaster and the js https://github.com/sarfata/pi-blaster.js.git
exit 0
