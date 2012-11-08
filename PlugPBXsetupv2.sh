#!/bin/bash
#
# FreePBX/Asterisk/PlugPBX installer for the SheevaPlug Dev Kit
# Designed for Asterisk 1.8.x and Debian Squeeze/Lenny
#
# http://www.plugpbx.org
# http://forums.plugpbx.org
#
# You may need to update the below version numbers from the Asterisk and FreePBX sites to make sure
# the version you prefer is being installed. You may also need to update the download URLs, so you are best to check these
# first before running that the paths / names will work.


VER_ASTERISK="1.8.1.1";  #Latest Release with Static URL for script automation, if you change this, you will have to uncomment below.
VER_DAHDI_COMPLETE="2.2.1.2+2.2.1.1"; #Any release past this has a process,  ksoftirqd, which is taking 35-40% CPU time, unfixed bug as of 7/24/10
VER_FREEPBX="2.8.0";

URL_ASTERISK=http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-${VER_ASTERISK}.tar.gz
URL_DAHDI_COMPLETE=http://downloads.asterisk.org/pub/telephony/dahdi-linux-complete/releases/dahdi-linux-complete-${VER_DAHDI_COMPLETE}.tar.gz
URL_FREEPBX=http://mirror.freepbx.org/freepbx-${VER_FREEPBX}.tar.gz

#Name of Host / Project Name - Determines system Hostname and Branding
HOST_NAME=PlugPBX

clear
echo "+----------------------------------------------------------------+"
echo "|                                                                |"
echo "|             PlugPBX Installer for SheevaPlug Dev Kit           |"
echo "|                                                                |"
echo "|                   originally based on a script by              |"
echo "|               Matt Chipman - matt@corenetworks.com.au 		   |"
echo "|					 contributions from xdm, mattmc97			   |"
echo "|			Developed for PlugPBX by gregwjacobs@gmail.com 		   |"
echo "|                                                                |"
echo "+----------------------------------------------------------------+"
echo "  This script will install and configure the following packages:  "
echo "                                                                  "
echo "                Asterisk..........${VER_ASTERISK}                 "
echo "                Dahdi-Complete....${VER_DAHDI_COMPLETE}           "
echo "                FreePBX...........${VER_FREEPBX}                  "
echo "				  PHP/Apache2										"
echo "				  MySQL												"
echo " 				  WebMin											"
echo "				  Avahi												"
echo " 				  Samba												"
echo "				  ssh 												"
echo "				  postifx											"
echo "+----------------------------------------------------------------+"
echo "|                    Press <ENTER> to continue                   |"
echo "+----------------------------------------------------------------+"
read

echo "This script will install all the tools and components for a working"
echo "PlugPBX implementation, including configuration changes required"
echo "to Debian Linux itself. Debian Lenny or Squeeze supported on SheevaPlug"
echo
echo "Press *ENTER* to continue..."
echo
echo -e '\a\a\a\a'    # Play Bell Alert
echo "NOTE: NEVER run this script TWICE, one time use only then delete"
echo 
echo "Press *ENTER* to start"
read

clear
echo "+----------------------------------------------------------------+"
echo "| Setting up passwords...                                        |"
echo "+----------------------------------------------------------------+"

echo
read -p 'Create a MySQL root password: ' MYSQL_PASS
read -p 'Create an Asterisk Manager password: ' ASTMAN_PASS
read -p 'Create an ARI password: ' ARI_PASS
echo 
echo "Write these down, don't forget them..."
echo


echo "+----------------------------------------------------------------+"
echo "| Fixing Hotplug eth0 issue in Debian...                         |"
echo "+----------------------------------------------------------------+"

sed -i 's/allow-hotplug eth0/#allow-hotplug eth0/' /etc/network/interfaces
sed -i '/#allow-hotplug eth0/aauto eth0' /etc/network/interfaces

echo "+----------------------------------------------------------------+"
echo "| Installing WebMin...                                           |"
echo "+----------------------------------------------------------------+"

echo '' >> /etc/apt/sources.list
echo '#Webmin Apt Source' >> /etc/apt/sources.list
echo 'deb http://download.webmin.com/download/repository sarge contrib' >> /etc/apt/sources.list
echo 'deb http://webmin.mirror.somersettechsolutions.co.uk/repository sarge contrib' >> /etc/apt/sources.list

cd /tmp
wget http://www.webmin.com/jcameron-key.asc
apt-key add jcameron-key.asc 
rm jcameron-key.asc
apt-get update
apt-get -y install webmin

echo "+----------------------------------------------------------------+"
echo "| Setting DHCP Client to register hostname  ${HOST_NAME}         |"
echo "+----------------------------------------------------------------+"

sed -i 's/#send host-name "andare.fugue.com"/send host-name "${HOST_NAME}"/' /etc/dhcp3/dhcpclient.conf

echo "+----------------------------------------------------------------+"
echo "| Setting up Avahi-Daemon (ZeroConf/Bonjour DNS Services)        |"
echo "+----------------------------------------------------------------+"

apt-get -y install avahi-daemon

echo -e  '<?xml version="1.0" standalone=\047no\047?><!--*-nxml-*-->'  	>  /etc/avahi/services/apache.service
echo '<!DOCTYPE service-group SYSTEM "avahi-service.dtd">' 		>>  /etc/avahi/services/apache.service
echo '<service-group>'											>>  /etc/avahi/services/apache.service
echo '<name replace-wildcards="yes">${HOST_NAME} Web Interface</name>'  >>  /etc/avahi/services/apache.service
echo '<service>' 												>>  /etc/avahi/services/apache.service
echo '<type>_http._tcp</type>'									>>  /etc/avahi/services/apache.service
echo '<port>80</port>'											>>  /etc/avahi/services/apache.service	
echo '</service>'												>>  /etc/avahi/services/apache.service
echo '</service-group>'											>>  /etc/avahi/services/apache.service

echo -e  '<?xml version="1.0" standalone=\047no\047?><!--*-nxml-*-->'   >  /etc/avahi/services/webmin.service
echo '<!DOCTYPE service-group SYSTEM "avahi-service.dtd">' 		>>  /etc/avahi/services/webmin.service
echo '<service-group>'											>>  /etc/avahi/services/webmin.service
echo '<name replace-wildcards="yes">${HOST_NAME} Webmin Interface</name>'  >>  /etc/avahi/services/webmin.service
echo '<service>' 												>>  /etc/avahi/services/webmin.service
echo '<type>_https._tcp</type>'									>>  /etc/avahi/services/webmin.service
echo '<port>10000</port>'											>>  /etc/avahi/services/webmin.service	
echo '</service>'												>>  /etc/avahi/services/webmin.service
echo '</service-group>'											>>  /etc/avahi/services/webmin.service

echo -e  '<?xml version="1.0" standalone=\047no\047?><!--*-nxml-*-->'	>   /etc/avahi/services/ssh.service
echo '<!DOCTYPE service-group SYSTEM "avahi-service.dtd">'		>>  /etc/avahi/services/ssh.service
echo '<service-group>'											>>  /etc/avahi/services/ssh.service
echo '<name replace-wildcards="yes">${HOST_NAME} SSH Server</name>'	>>  /etc/avahi/services/ssh.service
echo '<service>'													>>  /etc/avahi/services/ssh.service
echo '<type>_ssh._tcp</type>'									>>  /etc/avahi/services/ssh.service
echo '<port>22</port>'											>>  /etc/avahi/services/ssh.service
echo '</service>'												>>  /etc/avahi/services/ssh.service
echo '</service-group>'											>>  /etc/avahi/services/ssh.service

sed -i 's/#host-name=foo/host-name=${HOST_NAME}/' /etc/avahi/avahi-daemon.conf

echo "+----------------------------------------------------------------+"
echo "| Setting up SAMBA / Windows File share / Netbios Name           |"
echo "+----------------------------------------------------------------+"

apt-get -y  install samba

#Backup the Original Samba Config before we replace with our own customized version
mv /etc/samba/smb.conf /etc/samba/smb.comf.orig


echo '[global]'		>  /etc/samba/smb.conf
echo '	log file = /var/log/samba/log.%m'	>>  /etc/samba/smb.conf
echo '	passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .' >>  /etc/samba/smb.conf
echo '	include = /etc/samba/dhcp.conf'	>>  /etc/samba/smb.conf
echo '	obey pam restrictions = yes' >>  /etc/samba/smb.conf
echo '	encrypt passwords = true' >>  /etc/samba/smb.conf
echo '	passwd program = /usr/bin/passwd %u' >>  /etc/samba/smb.conf
echo '	passdb backend = tdbsam' >>  /etc/samba/smb.conf
echo '	dns proxy = no' >>  /etc/samba/smb.conf
echo '	server string = %h FreePBX Asterisk Server' >>  /etc/samba/smb.conf
echo '	unix password sync = yes' >>  /etc/samba/smb.conf
echo '	workgroup = WORKGROUP' >>  /etc/samba/smb.conf
echo '	os level = 20' >>  /etc/samba/smb.conf
echo '	syslog = 0' >>  /etc/samba/smb.conf
echo '	security = share' >>  /etc/samba/smb.conf
echo '	panic action = /usr/share/samba/panic-action %d' >>  /etc/samba/smb.conf
echo '	max log size = 1000' >>  /etc/samba/smb.conf
echo '	pam password change = yes' >>  /etc/samba/smb.conf
echo ''
echo '[Temp Files]'  >>  /etc/samba/smb.conf
echo '	comment = Drop Area to copy files to/from ${HOST_NAME} Host  (/tmp in unix system)'  >>  /etc/samba/smb.conf
echo '	writeable = yes'  >>  /etc/samba/smb.conf
echo '	public = yes'  >>  /etc/samba/smb.conf
echo '	path = /tmp'  >>  /etc/samba/smb.conf
echo ''  >>  /etc/samba/smb.conf
echo '[Logs]'  >>  /etc/samba/smb.conf
echo '	force user = root'  >>  /etc/samba/smb.conf
echo '	guest account = root'  >>  /etc/samba/smb.conf
echo '	comment = FreePBX / Asterisk / Linux Host Logs'  >>  /etc/samba/smb.conf
echo '	public = yes'  >>  /etc/samba/smb.conf
echo '	guest only = yes'  >>  /etc/samba/smb.conf
echo '	path = /var/log/'  >>  /etc/samba/smb.conf
echo '	force group = root'  >>  /etc/samba/smb.conf
echo '' >>  /etc/samba/smb.conf 
echo '[Hold Music]'  >>  /etc/samba/smb.conf
echo '	force user = asterisk'  >>  /etc/samba/smb.conf
echo '	guest account = asterisk'  >>  /etc/samba/smb.conf
echo '	writeable = yes'  >>  /etc/samba/smb.conf
echo '	public = yes'  >>  /etc/samba/smb.conf
echo '	path = /var/lib/asterisk/mohmp3/'  >>  /etc/samba/smb.conf
echo '	force group = asterisk'  >>  /etc/samba/smb.conf
echo ''  >>  /etc/samba/smb.conf
echo '[www]'  >>  /etc/samba/smb.conf
echo '	guest account = asterisk'  >>  /etc/samba/smb.conf
echo '	force user = asterisk'  >>  /etc/samba/smb.conf
echo '	comment = Web Server Root Directory (Be Careful!)'  >>  /etc/samba/smb.conf
echo '	writeable = yes'  >>  /etc/samba/smb.conf
echo '	public = yes'  >>  /etc/samba/smb.conf
echo '	path = /var/www/'  >>  /etc/samba/smb.conf
echo '	force group = asterisk'  >>  /etc/samba/smb.conf
echo ''


echo "+----------------------------------------------------------------+"
echo "| Running apt-get update and installing dependencies...          |"
echo "+----------------------------------------------------------------+"

echo mysql-server-5.1 mysql-server/root_password password ${MYSQL_PASS} | debconf-set-selections
echo mysql-server-5.1 mysql-server/root_password_again password ${MYSQL_PASS} | debconf-set-selections
apt-get update
apt-get -y install ssh postfix kernel-package g++ libncurses5-dev linux-libc-dev sqlite libnewt-dev libusb-dev zlib1g-dev libmysqlclient-dev libsqlite0-dev php5 mysql-server-5.1 php-pear php5-mysql php-db php5-gd linux-headers-$(uname -r) bison openssl libssl-dev libeditline0 libeditline-dev libedit-dev gcc make mc php5-cli sox curl libcurl3 libcurl3-dev php5-curl php5-mcrypt


echo "+----------------------------------------------------------------+"
echo "| Downloading and decompressing sources...                       |"
echo "+----------------------------------------------------------------+"

mkdir /tmp/asterisk/
wget -c ${URL_ASTERISK} -O /tmp/asterisk/asterisk-${VER_ASTERISK}.tar.gz
wget -c ${URL_DAHDI_COMPLETE} -O /tmp/asterisk/dahdi-linux-complete-${VER_DAHDI_COMPLETE}.tar.gz
wget -c ${URL_FREEPBX} -O /tmp/asterisk/freepbx-${VER_FREEPBX}.tar.gz

cd /usr/src/
tar zxvf /tmp/asterisk/asterisk-${VER_ASTERISK}.tar.gz
tar zxvf /tmp/asterisk/dahdi-linux-complete-${VER_DAHDI_COMPLETE}.tar.gz
tar zxvf /tmp/asterisk/freepbx-${VER_FREEPBX}.tar.gz


echo "+----------------------------------------------------------------+"
echo "| Compiling Dahdi-linux-complete...                              |"
echo "+----------------------------------------------------------------+"

cd /usr/src/dahdi-linux-complete-${VER_DAHDI_COMPLETE}
make all
make install
make config

mv /etc/dahdi/modules /etc/dahdi/modules.orig
touch /etc/dahdi/modules

service dahdi start


echo "+----------------------------------------------------------------+"
echo "| Installing Asterisk feature dependant components / apps / libs |"
echo "+----------------------------------------------------------------+"

#apt-get -y install alsa
apt-get install libiksemel* # Add Jabber GTALk support in Asterisk
#apt-get install bluetooth  #Bluetooth support?
#apt-get install sqlite*    #SQLite, and Sqlite3 support
apt-get -y install .*resample.* (SLIN re-codec support?)

#To Do?

#spandsp
#jack, resample
#osptk, openssl
#res_odbc
##syslog(e)
#portaudio
#openh323
#isdnnet, misden, suppserv
#nbs
#speexdsp
#vorbis, ogg
#speex, speex_preprocess
#srtp
#kqueue ?
 

echo "+----------------------------------------------------------------+"
echo "| Compiling Asterisk...                                          |"
echo "+----------------------------------------------------------------+"

cd /usr/src/asterisk-${VER_ASTERISK}
./configure --disable-xmldoc
# Downloaded needed libs to get format_mp3 to work
apt-get install subversion   #needed by this following script
echo "Getting mp3 libraries from Asterisk SVN via bundled script (required for format_mp3)..."
contrib/scripts/get_mp3_source.sh
echo ''
echo -e '\a\a\a\a'    # Play Bell Alert
echo ''
echo "You will be now prompted for what Asterisk options to compile / build. Select as desired"
echo "and then select *Save and Exit* button to continue... PRESS ENTER to BEGIN"
read
make menuselect
make
#Experimental, force 'arm' compiling flags to get around issues?
sed -i 's/PROC=armv5tel/PROC=arm/g' /usr/src/asterisk-${VER_ASTERISK}/makeopts     #armv5tel seems to break building?
sed -i 's/HOST_CPU=armv5tel/HOST_CPU=arm/g' /usr/src/asterisk-${VER_ASTERISK}/makeopts     #armv5tel seems to break building?
sed -i 's/BUILD_CPU=armv5tel/BUILD_CPU=arm/g' /usr/src/asterisk-${VER_ASTERISK}/makeopts     #armv5tel seems to break building?
make
make install


echo "+----------------------------------------------------------------+"
echo "| Creating symlinks (Modules)                                    |"
echo "+----------------------------------------------------------------+"

ln -s /lib/modules/`uname -r`/ /lib/modules/`uname -r`/asterisk
depmod


echo "+----------------------------------------------------------------+"
echo "| Changing PHP Settings for FreePBX...                           |"
echo "+----------------------------------------------------------------+"

cp /etc/php5/apache2/php.ini /etc/php5/apache2/php.ini-orig
sed -i 's/upload_max_filesize = .*/upload_max_filesize = 20M/g' /etc/php5/apache2/php.ini
sed -i 's/memory_limit = .*/memory_limit = 128M/' /etc/php5/apache2/php.ini
sed -i 's/;suhosin.memory_limit = 0/suhosin.memory_limit = 134217728/' /etc/php5/conf.d/suhosin.ini

echo "+----------------------------------------------------------------+"
echo "| Setting permissions for the asterisk user...                   |"
echo "+----------------------------------------------------------------+"

adduser asterisk --disabled-password --gecos "asterisk PBX" --home /var/lib/asterisk
chown asterisk:asterisk -R /var/www
chown asterisk:asterisk -R /etc/asterisk


echo "+----------------------------------------------------------------+"
echo "| Setting up MySQL for FreePBX...                                |"
echo "+----------------------------------------------------------------+"

echo "create database asteriskcdrdb;" | mysql -u root -p${MYSQL_PASS}
echo "create database asterisk;" | mysql -u root -p${MYSQL_PASS}
echo "GRANT ALL PRIVILEGES ON asteriskcdrdb.* TO asteriskuser@localhost IDENTIFIED BY '${ASTMAN_PASS}';" | mysql -u root -p${MYSQL_PASS}
echo "GRANT ALL PRIVILEGES ON asterisk.* TO asteriskuser@localhost IDENTIFIED BY '${ASTMAN_PASS}';" | mysql -u root -p${MYSQL_PASS}

mysql -u asteriskuser -p${ASTMAN_PASS} asteriskcdrdb < /usr/src/freepbx-${VER_FREEPBX}/SQL/cdr_mysql_table.sql
mysql -u asteriskuser -p${ASTMAN_PASS} asterisk < /usr/src/freepbx-${VER_FREEPBX}/SQL/newinstall.sql


echo "+----------------------------------------------------------------+"
echo "| Starting asterisk...                                           |"
echo "+----------------------------------------------------------------+"

/usr/sbin/asterisk


echo "+----------------------------------------------------------------+"
echo "| Modifying FreeBBX configuration files...                       |"
echo "+----------------------------------------------------------------+"

cp /usr/src/freepbx-${VER_FREEPBX}/install_amp /usr/src/freepbx-${VER_FREEPBX}/install_amp-orig
sed -i "s/\(^\$webroot*\)\(.*\)/\1 = \"\/var\/www\";/" /usr/src/freepbx-${VER_FREEPBX}/install_amp

LOCAL_IP=`/sbin/ifconfig eth0`
LOCAL_IP=`echo ${LOCAL_IP} | sed -e "s/\ Bcast:\(.*\)//"`
LOCAL_IP=`echo ${LOCAL_IP} | sed -e "s/\(.*\)\ inet addr://"`
sed -i "s/xx.xx.xx.xx/${HOST_NAME}/g" "/usr/src/freepbx-${VER_FREEPBX}/install_amp"

chmod 755 /usr/src/freepbx-${VER_FREEPBX}/install_amp


echo "+----------------------------------------------------------------+"
echo "| Removing AGI scripts installed by Asterisk...                  |"
echo "+----------------------------------------------------------------+"

rm -f /var/lib/asterisk/agi-bin/*


echo "+----------------------------------------------------------------+"
echo "| Changing run user and group for Apache...                      |"
echo "+----------------------------------------------------------------+"

sed -i "s/APACHE_RUN_USER=www-data/APACHE_RUN_USER=asterisk/g" "/etc/apache2/envvars"
sed -i "s/APACHE_RUN_GROUP=www-data/APACHE_RUN_GROUP=asterisk/g" "/etc/apache2/envvars"


echo "+----------------------------------------------------------------+"
echo "| Running FreePBX install script...                              |"
echo "+----------------------------------------------------------------+"
echo "| Press <ENTER> at each question for the default option          |"
echo "+----------------------------------------------------------------+"
echo "| Press <ENTER> to continue                                      |"
echo "+----------------------------------------------------------------+"

read

cd /usr/src/freepbx-${VER_FREEPBX}/
./install_amp  --username=asteriskuser --password=${ASTMAN_PASS}
./install_amp  --username=asteriskuser --password=${ASTMAN_PASS}
sed -i "s/AMPDBPASS=amp109/AMPDBPASS=${ASTMAN_PASS}/g" "/etc/amportal.conf"
sed -i "s/AMPMGRPASS=amp111/AMPMGRPASS=${ASTMAN_PASS}/g" "/etc/amportal.conf"
sed -i "s/ARI_ADMIN_PASSWORD=ari_password/ARI_ADMIN_PASSWORD=${ARI_PASS}/g" "/etc/amportal.conf"
./apply_conf.sh

echo "+----------------------------------------------------------------+"
echo "| Stoping Asterisk...                                            |"
echo "+----------------------------------------------------------------+"

asterisk -rx "core stop now"
killall -9 safe_asterisk


echo "+----------------------------------------------------------------+"
echo "| Removing Apache2 Redirect...                                   |"
echo "+----------------------------------------------------------------+"

sed -i "s/\(RedirectMatch*\)\(.*\)//" /etc/apache2/sites-enabled/000-default


echo "+----------------------------------------------------------------+"
echo "| Changing permissions...                                        |"
echo "+----------------------------------------------------------------+"

chown -R asterisk:asterisk /etc/asterisk
chmod 770 /etc/asterisk/

chown -R asterisk:asterisk /var/lib/asterisk/
chmod 770 /var/lib/asterisk/

chown -R asterisk:asterisk /var/www/


echo "+----------------------------------------------------------------+"
echo "| Restarting Apache...                                           |"
echo "+----------------------------------------------------------------+"

/usr/sbin/apachectl stop
/usr/sbin/apachectl start


echo "+----------------------------------------------------------------+"
echo "| Copying missing images...                                      |"
echo "+----------------------------------------------------------------+"

cp /var/www/admin/modules/dashboard/images/notify_* /var/www/admin/images/


echo "+----------------------------------------------------------------+"
echo "| Startup script (Asterisk+FreePBX)                              |"
echo "| /etc/init.d/freepbx [start|stop|restart]                       |"
echo "+----------------------------------------------------------------+"

STARTUP_SCRIPT="/etc/init.d/freepbx";
echo "Creating file ${STARTUP_SCRIPT} ...";

echo '#!/bin/bash' > ${STARTUP_SCRIPT}
echo '' >> ${STARTUP_SCRIPT}
echo 'AMPORTAL_BIN=/usr/local/sbin/amportal' >> ${STARTUP_SCRIPT}
echo '' >> ${STARTUP_SCRIPT}
echo 'if [ ! -x ${AMPORTAL_BIN} ]; then'  >> ${STARTUP_SCRIPT}
echo '        echo "error : amportal binary can not be found (${AMPORTAL_BIN})"' >> ${STARTUP_SCRIPT}
echo '        exit 0' >> ${STARTUP_SCRIPT}
echo 'fi' >> ${STARTUP_SCRIPT}
echo '' >> ${STARTUP_SCRIPT}
echo '' >> ${STARTUP_SCRIPT}
echo 'start() {' >> ${STARTUP_SCRIPT}
echo '	echo "Starting FreePBX ..."' >> ${STARTUP_SCRIPT}
echo '	${AMPORTAL_BIN} start'  >> ${STARTUP_SCRIPT}
echo '}' >> ${STARTUP_SCRIPT}
echo '' >> ${STARTUP_SCRIPT}
echo 'stop() {' >> ${STARTUP_SCRIPT}
echo '	echo "Stopping FreePBX ..."' >> ${STARTUP_SCRIPT}
echo '	${AMPORTAL_BIN} stop'  >> ${STARTUP_SCRIPT}
echo '}' >> ${STARTUP_SCRIPT}
echo '' >> ${STARTUP_SCRIPT}
echo 'case "$1" in' >> ${STARTUP_SCRIPT}
echo '  start)' >> ${STARTUP_SCRIPT}
echo '        start' >> ${STARTUP_SCRIPT}
echo '        ;;' >> ${STARTUP_SCRIPT}
echo '' >> ${STARTUP_SCRIPT}
echo '  stop)' >> ${STARTUP_SCRIPT}
echo '        stop' >> ${STARTUP_SCRIPT}
echo '        ;;' >> ${STARTUP_SCRIPT}
echo '' >> ${STARTUP_SCRIPT}
echo '  restart)' >> ${STARTUP_SCRIPT}
echo '	stop' >> ${STARTUP_SCRIPT}
echo '        start' >> ${STARTUP_SCRIPT}
echo '        ;;' >> ${STARTUP_SCRIPT}
echo '' >> ${STARTUP_SCRIPT}
echo '  *)' >> ${STARTUP_SCRIPT}
echo '        echo $"Usage: $0 {start|stop|restart}"' >> ${STARTUP_SCRIPT}
echo '        exit 1' >> ${STARTUP_SCRIPT}
echo 'esac' >> ${STARTUP_SCRIPT}
echo '' >> ${STARTUP_SCRIPT}
echo 'exit 0' >> ${STARTUP_SCRIPT}
chmod 755 ${STARTUP_SCRIPT}

echo "Update services loading at boot time..."
update-rc.d freepbx defaults

amportal start


echo "+----------------------------------------------------------------+"
echo "| FreePBX installation is finished...                            |"
echo "| For running asterisk+freepbx you must use this command :       |"
echo "| # /etc/init.d/freepbx start                                    |"
echo "+----------------------------------------------------------------+"
echo
echo
echo "OooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooO"
echo "| It is recommended that you reboot before using this system!    |"
echo "OooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooO"
echo
echo -e '\a\a'    # Play Bell Alert - We're done
echo "Your PBX is ready to configure, visit: http://${LOCAL_IP}/admin"
echo


Add this to cusom scripts!

### BEGIN INIT INFO
# Provides:          apache2
# Required-Start:    $local_fs $remote_fs $network $syslog
# Required-Stop:     $local_fs $remote_fs $network $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# X-Interactive:     true
# Short-Description: Start/stop apache2 web server
### END INIT INFO


Fix These...

insserv: warning: script 'K02sabnzbdplus' missing LSB tags and overrides
insserv: warning: script 'K09flashhybrid' missing LSB tags and overrides
insserv: warning: script 'S20usbdisk' missing LSB tags and overrides
insserv: warning: script 'S22webmin' missing LSB tags and overrides
insserv: warning: script 'flashybrid' missing LSB tags and overrides
insserv: warning: script 'usbdisk' missing LSB tags and overrides
insserv: warning: script 'sabnzbdplus' missing LSB tags and overrides
insserv: warning: script 'webmin' missing LSB tags and overrides
insserv: There is a loop between service Sick and flashybrid if stopped
insserv:  loop involving service flashybrid at depth 2
insserv:  loop involving service Sick at depth 1

