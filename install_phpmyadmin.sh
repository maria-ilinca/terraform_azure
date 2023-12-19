#!/bin/bash

sudo apt-get update

sudo apt-get install -y apache2 php php-mbstring php-gettext libapache2-mod-php php-mysql

sudo apt-get install -y phpmyadmin

echo "Include /etc/phpmyadmin/apache.conf" | sudo tee -a /etc/apache2/apache2.conf

sudo systemctl restart apache2
sudo systemctl enable apache2

