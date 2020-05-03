#!/bin/bash
#author: JeLank

#This section updates the machine and installs the prerequisites for SeedDMS

yum update -y

yum install -y epel-release

yum install -y httpd mariadb-server mariadb php php-mysql MySQL-python firewalld

#This section enables the firewall and ensures it starts on reboot/start up

systemctl enable firewalld

systemctl start firewalld

#This starts Apache and ensures it starts on reboot/start up of the server

systemctl enable httpd

systemctl start httpd

#This starts MariaDB and ensures it starts on reboot/start up of the server

systemctl enable mariadb

systemctl start mariadb

#This section will set up MariaDB

mysql -u root <<-EOF
UPDATE mysql.user SET Password=PASSWORD('Fullsail1!') WHERE User='root';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.db WHERE Db='test' OR Db='test_%';
FLUSH PRIVILEGES;
EOF

#This section will set up MariaDB database and user for Wordpress

mysql -u root -pFullsail1!   << EOF
CREATE USER 'wpuser' IDENTIFIED BY 'Fullsail1!';
CREATE DATABASE wordpress;
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'localhost' IDENTIFIED BY 'Your Password Here!';
EOF

#This part sets the permissions for the Apache folder, makes Apache the owner of that folder and downward

chown -R apache:apache /var/www

chmod -R 770 /var/www/html/

#This restarts Apache, creates a exception to allow Apache to connect to a remote database, and allows access for SeedDMS to pass through SELinux

systemctl restart httpd

setsebool -P httpd_can_network_connect_db=1

setsebool -P httpd_unified 1

#This last section allows for http and https traffic to pass through Firewalld

firewall-cmd --permanent --add-service=http

firewall-cmd --permanent --add-service=https

firewall-cmd --reload