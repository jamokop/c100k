var siteName;
if [ -z "$1" ]; then siteName="testsite.com"; else siteName=$1; fi 

# set the debian sources
echo "deb http://packages.dotdeb.org wheezy-php55 all" >> /etc/apt/sources.list
echo "deb-src http://packages.dotdeb.org wheezy-php55 all" >> /etc/apt/sources.list
curl http://repo.varnish-cache.org/debian/GPG-key.txt | apt-key add -
echo "deb http://repo.varnish-cache.org/debian/ wheezy varnish-3.0" >> /etc/apt/sources.list
wget http://www.dotdeb.org/dotdeb.gpg
cat dotdeb.gpg | sudo apt-key add -

# install debian packages
apt-get update
apt-get upgrade

apt-get -y install php5 php5-fpm php-pear php5-common php5-mcrypt php5-mysql php5-cli php5-gd php-apc
apt-get -y install nginx
apt-get -y install redis-server
export DEBIAN_FRONTEND=noninteractive
apt-get -q -y install mysql-server mysql-client
apt-get install varnish


# ==============================================================
# Nginx configuration
# Get the configured nginx.conf and replace the nginx.conf
# ==============================================================
wget https://raw.githubusercontent.com/rayhon/c100k/master/php-web/nginx/vps-nginx.conf
wget https://raw.githubusercontent.com/rayhon/c100k/master/php-web/nginx/app.conf
sed -i "s/DOMAIN/$siteName/g" vps-nginx.conf 
sed -i "s/DOMAIN/$siteName/g" app.conf 
# back up the original file
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig
mv vps-nginx.conf /etc/nginx/nginx.conf
mv app.conf /etc/nginx/site-available/$siteName.conf
ln -s /etc/nginx/sites-available/$siteName.conf /etc/nginx/sites-enabled/$siteName.conf

# ==============================================================
# php5-fpm configuration
# ==============================================================
wget https://raw.githubusercontent.com/rayhon/c100k/master/php-web/php5-fpm/fpm-app.conf
wget https://raw.githubusercontent.com/rayhon/c100k/master/php-web/php5-fpm/apc.ini
sed -i "s/DOMAIN/$siteName/g" fpm-app.conf 
mv fpm-app.conf /etc/php5/fpm/pool.d/$siteName.conf
mv apc.ini /etc/php5/fpm/conf.d


# ==============================================================
# Varnish configuration
# Get the configured wordpress.vcl and replace the default.vcl
# ==============================================================
wget https://raw.githubusercontent.com/rayhon/c100k/master/php-web/varnish/wordpress.vcl
mv /etc/varnish/default.vcl /etc/varnish/default.vcl.orig
mv wordpress.vcl /etc/varnish/default.vcl


# ==============================================================
# Wordpress Installation
# ==============================================================
# get latest wordpress version
mkdir -p /var/www/$1
wget http://wordpress.org/latest.tar.gz
tar -zxvf latest.tar.gz
mv wordpress/* /var/www/$1
rm -rf wordpress
rm latest.tar.gz
# set up mysql db for wordpress
echo "CREATE DATABASE IF NOT EXIST wordpress;GRANT ALL PRIVILEGES ON wordpress.* TO admin@localhost IDENTIFIED BY 'pass' WITH GRANT OPTION;FLUSH PRIVILEGES;" | mysql -u root


/etc/init.d/php5-fpm restart
/etc/init.d/nginx restart
/etc/init.d/varnish restart