sudo apt-get update

sudo apt install apache2

sudo apt-get install -y php libapache2-mod-php php-mysql

sudo systemctl restart apache2

sudo systemctl enable apache2 

sudo apt-get install -y phpmyadmin

# Allow access to phpMyAdmin from anywhere

sudo bash -c 'echo "Listen 0.0.0.0:8080" >> /etc/apache2/ports.conf'
sudo bash -c 'echo "ServerName localhost" >> /etc/apache2/apache2.conf'
sudo bash -c 'echo "Include /etc/phpmyadmin/apache.conf" >> /etc/apache2/apache2.conf'


