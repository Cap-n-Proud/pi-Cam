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

exit 0