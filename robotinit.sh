#!/bin/bash
# Cleanup, version 3

#  Warning:
#  -------
#  This script uses quite a number of features that will be explained
#+ later on.
#  By the time you've finished the first half of the book,
#+ there should be nothing mysterious about it.



LOG_DIR=/var/log
ROOT_UID=0     # Only users with $UID 0 have root privileges.
LINES=50       # Default number of lines saved.
E_XCD=86       # Can't change directory?
E_NOTROOT=87   # Non-root exit error.


# Run as root, of course.
if [ "$UID" -ne "$ROOT_UID" ]
then
  echo "Must be root to run this script."
  exit $E_NOTROOT
fi  

if [ -n "$1" ]
# Test whether command-line argument is present (non-empty).
then
  lines=$1
else  
  lines=$LINES # Default, if not specified on command-line.
fi  


#  Stephane Chazelas suggests the following,
#+ as a better way of checking command-line arguments,
#+ but this is still a bit advanced for this stage of the tutorial.
#
#    E_WRONGARGS=85  # Non-numerical argument (bad argument format).
#
#    case "$1" in
#    ""      ) lines=50;;
#    *[!0-9]*) echo "Usage: `basename $0` lines-to-cleanup";
#     exit $E_WRONGARGS;;
#    *       ) lines=$1;;
#    esac
#
#* Skip ahead to "Loops" chapter to decipher all this.


cd $LOG_DIR

if [ `pwd` != "$LOG_DIR" ]  # or   if [ "$PWD" != "$LOG_DIR" ]
                            # Not in /var/log?
then
  echo "Can't change to $LOG_DIR."
  exit $E_XCD
fi  # Doublecheck if in right directory before messing with log file.

# Far more efficient is:
#
# cd /var/log || {
#   echo "Cannot change to necessary directory." >&2
#   exit $E_XCD;
# }




tail -n $lines messages > mesg.temp # Save last section of message log file.
mv mesg.temp messages               # Rename it as system log file.


#  cat /dev/null > messages
#* No longer needed, as the above method is safer.

cat /dev/null > wtmp  #  ': > wtmp' and '> wtmp'  have the same effect.
echo "Log files cleaned up."
#  Note that there are other log files in /var/log not affected
#+ by this script.

#  A zero return value from the script upon exit indicates success
#+ to the shell.

echo -e "***** Updating system packages *****"
sudo apt-get update
sudo apt-get upgrade

echo -e "***** Enabling Turbo *****"
#700Mhz-1000Mhz dynamic: Scales the cpu frequency according to the load
echo -e "force_turbo=0" >> /boot/config.txt

echo -e "***** Replace syslog *****"
#Replace rsyslogd with inetutils-syslogd and remove useless logs
#Reduce memory and cpu usage. We just need a simple vanilla syslogd. Also there is no need to log so many files. Just dump them into /var/log/(cron/mail/messages)
sudo apt-get -y remove --purge rsyslog
sudo apt-get -y install inetutils-syslogd
sudo service inetutils-syslogd stop

for file in /var/log/*.log /var/log/mail.* /var/log/debug /var/log/syslog; do [ -f "$file" ] && rm -f "$file"; done
for dir in fsck news; do [ -d "/var/log/$dir" ] && rm -rf "/var/log/$dir"; done
sudo mkdir -p /etc/logrotate.d
echo -e "/var/log/cron\n/var/log/mail\n/var/log/messages {\n\trotate 4\n\tweekly\n\tmissingok\n\tnotifempty\n\tcompress\n\tsharedscripts\n\tpostrotate\n\t/etc/init.d/inetutils-syslogd reload >/dev/null\n\tendscript\n}" > /etc/logrotate.d/inetutils-syslogd
sudo service inetutils-syslogd start



echo -e "***** Installing mjpg-streamer *****"
#https://miguelmota.com/blog/raspberry-pi-camera-board-video-streaming/

# Install dev version of libjpeg
sudo apt-get install libjpeg62-dev

# Install cmake
sudo apt-get install cmake

# Download mjpg-streamer with raspicam plugin
git clone https://github.com/jacksonliam/mjpg-streamer.git ~/mjpg-streamer

# Change directory
cd ~/mjpg-streamer/mjpg-streamer-experimental

# Compile
make clean all

# Replace old mjpg-streamer
sudo rm -rf /opt/mjpg-streamer
sudo mv ~/mjpg-streamer/mjpg-streamer-experimental /opt/mjpg-streamer
sudo rm -rf ~/mjpg-streamer

# Begin streaming
#LD_LIBRARY_PATH=/opt/mjpg-streamer/ /opt/mjpg-streamer/mjpg_streamer -i "input_raspicam.so -fps 15 -q 50 -x 640 -y 480" -o "output_http.so -p 9000 -w /opt/mjpg-streamer/www" &

#This is supposed to enable SSH, untested...
#for i in 2 3 4 5; do sudo ln -s /etc/init.d/ssh etc/rc$i.d/S02ssh; done

echo -e "***** Installing node *****"
wget http://node-arm.herokuapp.com/node_latest_armhf.deb 
sudo dpkg -i node_latest_armhf.deb

echo -e "Test"
node -v

echo -e "***** Installing socket.io *****"

npm install -g socket.io
#/usr/local/lib/node_modules/socket.io

echo -e "***** Installing express *****"
npm install -g express
npm install -g express-generator


#sudo apt-get purge desktop-base desktop-file-utils gnome-icon-theme gnome-themes-standard leafpad menu-xdg omxplayer scratch xarchiver zenity
#sudo apt-get purge lxappearance lxde lxde-common lxde-core lxde-icon-theme lxinput lxpanel lxpolkit lxrandr lxsession-edit lxshortcut lxtask lxterminal xinit xserver-xorg xserver-xorg-video-fbdev
#sudo aptitude purge lxappearance lxde lxde-common lxde-core lxde-icon-theme lxinput lxmenu-data lxpanel lxpolkit lxrandr lxsession lxsession-edit  lxshortcut lxtask  lxterminal  xinit xserver-xorg lightdm scratch midori desktop-base desktop-file-utils gnome-icon-theme gnome-themes-standard leafpad menu-xdg omxplayer xarchiver zenity tk8.5 pcmanfm blt idle idle3 python-tk python3-tk dillo openbox


sudo apt-get autoremove

exit 0