var siteName;
if [ -z "$1" ]; then siteName="testsite.com"; else siteName=$1; fi 

# install debian packages
apt-get update
apt-get upgrade
apt-get -y install php5 php5-fpm php-pear php5-common php5-mcrypt php5-mysql php5-cli php5-gd php-apc
apt-get -y install nginx
apt-get -y install redis-server
export DEBIAN_FRONTEND=noninteractive
apt-get -q -y install mysql-server mysql-client


# get the configured nginx.conf and replace the nginx.conf
wget https://raw.githubusercontent.com/rayhon/c100k/master/php-web/nginx/vps-nginx.conf
wget https://raw.githubusercontent.com/rayhon/c100k/master/php-web/nginx/app-nginx.conf
# sed -i '' "s/DOMAIN/$siteName/g" nginx.conf
mv /etc/nginx/nginx.conf nginx.conf.orig
mv vps-nginx.conf /etc/nginx/nginx.conf
mv app-nginx.conf /etc/nginx/sites-enabled/app.conf
ln -s /etc/nginx/sites-available/app.conf /etc/nginx/sites-enabled/app.conf


# update php5-fpm's php.ini
echo "extension=apc.so" >> /etc/php5/fpm/php.ini
echo "cgi.fix_pathinfo = 0" >> /etc/php5/fpm/php.ini
wget https://raw.githubusercontent.com/rayhon/c100k/master/php-web/php5-fpm/fpm-app.conf
mv fpm_app.conf /etc/php5/fpm/pool.d/app.conf


mkdir /var/www
mkdir /var/www/$1
wget http://wordpress.org/latest.tar.gz
tar -zxvf latest.tar.gz
mv wordpress/* /var/www/$1
rmdir wordpress
rm latest.tar.gz
echo "CREATE DATABASE wordpress;GRANT ALL PRIVILEGES ON wordpress.* TO admin@localhost IDENTIFIED BY 'pass' WITH GRANT OPTION;" | mysql -u root

