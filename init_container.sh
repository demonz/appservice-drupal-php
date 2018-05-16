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
                \____ \|  |  \\____ \\
                |  |_> >   Y  \  |_> >
                |   __/|___|  /   __/
                |__|        \/|__|


        A P P   S E R V I C E   O N   L I N U X

Documentation: http://aka.ms/webapp-linux
PHP quickstart: https://aka.ms/php-qs

EOL
cat /etc/motd


# Get environment variables to show up in SSH session
eval $(printenv | awk -F= '{print "export " $1"="$2 }' >> /etc/profile)


# run sshd in background
service ssh start



# PREPARE DRUPAL

# copy app service settings file
cp /var/www/html/sites/default/appservice.settings.php /var/www/html/sites/default/settings.php

# move sites/default/files directory to location on /home which is persisted by app service
if [ ! -d "/home/wwwroot/sites/default/files" ]; then
  mkdir -p /home/wwwroot/sites/default/files
fi
chown -R www-data:www-data /home/wwwroot/sites/default/files
rm -rf /var/www/html/sites/default/files
ln -s /home/wwwroot/sites/default/files /var/www/html/sites/default/files



# PREPARE AND START APACHE

sed -i "s/{WEBSITES_PORT}/${WEBSITES_PORT}/g" /etc/apache2/apache2.conf

mkdir -p /var/lock/apache2
mkdir -p /var/run/apache2

mkdir -p /home/LogFiles
ln -s /home/LogFiles /var/log/apache2


# execute CMD
exec "$@"
