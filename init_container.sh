#!/bin/bash
cat >/etc/motd <<EOL

________ __________ ____ _____________  _____  .____
\______ \\______    \    |   \______   \/  _  \ |    |
 |    |  \|       _/    |   /|     ___/  /_\  \|    |
 |    \`   \    |   \    |  / |    |  /    |    \    |___
/_______  /____|_  /______/  |____|  \____|__  /_______ \\
        \/       \/                          \/        \/
                       .__
                ______ |  |__ ______
                \____ \|  |  \\____  \\
                |  |_> >   Y  \  |_> >
                |   __/|___|  /   __/
                |__|        \/|__|


        A P P   S E R V I C E   O N   L I N U X

Documentation: http://aka.ms/webapp-linux
PHP quickstart: https://aka.ms/php-qs

EOL
cat /etc/motd


# Get environment variables to show up in SSH session
#eval $(printenv | awk -F= '{print "export " $1"="$2 }' >> /etc/profile)


# run sshd in background
service ssh start



# PREPARE DRUPAL

# copy appservice settings file
if [ ! -f "/var/www/html/sites/default/settings.php" ]; then
    cp /var/www/html/sites/default/appservice.settings.php /var/www/html/sites/default/settings.php
fi

# move sites/default/files directory to location on /home which is persisted by app service
DRUPAL_SITES_DEFAULT_FILES=/var/www/html/sites/default/files
HOME_SITES_DEFAULT_FILES=/home/wwwroot/sites/default/files

if [ ! -d "$HOME_SITES_DEFAULT_FILES" ]; then
  mkdir -p $HOME_SITES_DEFAULT_FILES
fi
chown -R www-data:www-data $HOME_SITES_DEFAULT_FILES
rm -rf $DRUPAL_SITES_DEFAULT_FILES
ln -s $HOME_SITES_DEFAULT_FILES $DRUPAL_SITES_DEFAULT_FILES



# PREPARE AND START APACHE

sed -i "s/{WEBSITES_PORT}/${WEBSITES_PORT}/g" /etc/apache2/apache2.conf
sed -i "s/{APACHE_REQUIREIP}/${APACHE_REQUIREIP//,/ }/g" /etc/apache2/apache2.conf


mkdir -p /var/lock/apache2
mkdir -p /var/run/apache2

mkdir -p /home/LogFiles
ln -s /home/LogFiles /var/log/apache2

echo "cd /var/www/html" >> ~/.bashrc

# execute CMD
exec "$@"
