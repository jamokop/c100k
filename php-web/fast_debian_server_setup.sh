var siteName;
if [ -n "$1" ]; then siteName="wordpress"; else siteName=$1; fi 

# install debian packages
apt-get update
apt-get upgrade
apt-get -y install php5 php5-fpm php-pear php5-common php5-mcrypt php5-mysql php5-cli php5-gd php-apc
apt-get -y install nginx
apt-get -y install redis-server
export DEBIAN_FRONTEND=noninteractive
apt-get -q -y install mysql-server mysql-client

# update php5-fpm's php.ini
echo "extension=apc.so" >> /etc/php5/fpm/php.ini
echo "cgi.fix_pathinfo = 0" >> /etc/php5/fpm/php.ini

mkdir /var/www
mkdir /var/www/$1
wget http://wordpress.org/latest.tar.gz
tar -zxvf latest.tar.gz
mv wordpress/* /var/www/$1
rmdir wordpress
rm latest.tar.gz
echo "CREATE DATABASE wordpress;GRANT ALL PRIVILEGES ON wordpress.* TO admin@localhost IDENTIFIED BY 'pass' WITH GRANT OPTION;" | mysql -u root
