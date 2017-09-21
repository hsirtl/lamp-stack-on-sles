#!/bin/bash

# Before doing anything, update the system
zypper update -y

# 
echo "waagent ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Install Apache2
zypper install -y apache2
systemctl start apache2
systemctl enable apache2
echo '<html><body><h1>Hello, my name is Apache2!</h1></body></html>' > /srv/www/htdocs/index.html
echo 'Apache2 successfully installed.'

# Install PHP7
zypper install -y php7 php7-mysql apache2-mod_php7
a2enmod php7
systemctl restart apache2
mv /srv/www/htdocs/index.html /srv/www/htdocs/index.html.bak
echo '<?php phpinfo(); ?>' > /srv/www/htdocs/index.php
echo 'PHP7 successfully installed.'

# Install MySQL
wget https://dev.mysql.com/get/mysql57-community-release-sles12-11.noarch.rpm
rpm -Uvh mysql57-community-release-sles12-11.noarch.rpm
rpm --import /etc/RPM-GPG-KEY-mysql
zypper install -y mysql-community-server
systemctl start mysql
systemctl enable mysql
echo 'MySQL 57 successfully installed.'

# Execute mysql_secure_installation
MYSQL_TEMP_PWD=$(grep 'temporary password' /var/log/mysql/mysqld.log | cut -d' ' -f11)
MYSQL_NEW_PWD=$1
SECURE_MYSQL=$(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Enter password for user root:\"
send \"$MYSQL_TEMP_PWD\r\"
expect \"New password:\"
send \"$MYSQL_NEW_PWD\r\" 
expect \"Re-enter new password:\"
send \"$MYSQL_NEW_PWD\r\"
expect \"Change the password for root ? ((Press y|Y for Yes, any other key for No) :\"
send \"n\r\"
expect \"Remove anonymous users? (Press y|Y for Yes, any other key for No) :\"
send \"n\r\"
expect \"Disallow root login remotely? (Press y|Y for Yes, any other key for No) :\"
send \"n\r\"
expect \"Remove test database and access to it? (Press y|Y for Yes, any other key for No) :\"
send \"n\r\"
expect \"Reload privilege tables now? (Press y|Y for Yes, any other key for No) :\"
send \"n\r\"
expect eof
")
echo "$SECURE_MYSQL"

# Install PhpMyAdmin
PHP_MY_ADMIN_DIR=/tools/phpmyadmin
zypper install -y php7-mbstring
wget https://files.phpmyadmin.net/phpMyAdmin/4.7.4/phpMyAdmin-4.7.4-all-languages.tar.gz
tar xzvf phpMyAdmin-4.7.4-all-languages.tar.gz
mkdir -p $PHP_MY_ADMIN_DIR
mv phpMyAdmin-4.7.4-all-languages/* $PHP_MY_ADMIN_DIR
cp $PHP_MY_ADMIN_DIR/config.sample.inc.php $PHP_MY_ADMIN_DIR/config.inc.php
sed -i "s/cfg['blowfish_secret'] = ''/cfg['q1w2e3r4t5z6u7i8o9p0q1w2e3r4t5z6'] = ''/g" $PHP_MY_ADMIN_DIR/config.inc.php
sed -i "s/localhost/127.0.0.1/g" $PHP_MY_ADMIN_DIR/config.inc.php

cat << EOF > /etc/apache2/vhosts.d/tools.conf
Listen 8081

<VirtualHost *:8081>
    DocumentRoot /tools/
    ErrorLog /var/log/apache2/tools-error_log
    CustomLog /var/log/apache2/tools-access_log combined
    <Directory "/tools/">
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

systemctl restart apache2

# set DNS
sed -i '/^nameserver/ d' /etc/resolv.conf
echo "nameserver 10.13.48.77" >> /etc/resolv.conf
echo "nameserver 10.13.16.1" >> /etc/resolv.conf

echo "Server setup complete."