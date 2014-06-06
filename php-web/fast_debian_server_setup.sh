#var siteName;
if [ -z "$1" ]; then siteName="testsite.com"; else siteName=$1; fi 

# set the debian sources
echo "deb http://packages.dotdeb.org wheezy-php55 all" >> /etc/apt/sources.list
echo "deb-src http://packages.dotdeb.org wheezy-php55 all" >> /etc/apt/sources.list
curl http://repo.varnish-cache.org/debian/GPG-key.txt | apt-key add -
echo "deb http://repo.varnish-cache.org/debian/ wheezy varnish-3.0" >> /etc/apt/sources.list
wget http://www.dotdeb.org/dotdeb.gpg
cat dotdeb.gpg | sudo apt-key add -

# install debian packages
apt-get -y update
apt-get -y upgrade

#apt-get -y install php5 php5-fpm php-pear php5-common php5-mcrypt php5-mysql php5-cli php5-gd php-apc
apt-get -y install php5 php5-fpm php-pear php5-common php5-mcrypt php5-mysql php5-cli php5-gd
apt-get -y install nginx
#apt-get -y install redis-server
export DEBIAN_FRONTEND=noninteractive
apt-get -q -y install mysql-server mysql-client
apt-get -y install varnish


# ==============================================================
# Nginx configuration
# Get the configured nginx.conf and replace the nginx.conf
# ==============================================================
wget https://raw.githubusercontent.com/rayhon/c100k/master/php-web/nginx/vps-nginx.conf
wget https://raw.githubusercontent.com/rayhon/c100k/master/php-web/nginx/app.conf
wget https://raw.githubusercontent.com/rayhon/c100k/master/php-web/nginx/default-sites-available.conf
sed -i "s/DOMAIN/$siteName/g" vps-nginx.conf 
sed -i "s/DOMAIN/$siteName/g" app.conf 
sed -i "s/DOMAIN/$siteName/g" default-sites-available.conf 
# back up the original file
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig
mv vps-nginx.conf /etc/nginx/nginx.conf
mv app.conf /etc/nginx/sites-available/$siteName.conf 
ln -s /etc/nginx/sites-available/$siteName.conf /etc/nginx/sites-enabled/$siteName.conf
mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.orig
mv default-sites-available.conf /etc/nginx/sites-available/default


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
wget https://raw.githubusercontent.com/rayhon/c100k/master/php-web/varnish/varnish.txt
mv /etc/varnish/default.vcl /etc/varnish/default.vcl.orig
mv wordpress.vcl /etc/varnish/default.vcl

mv /etc/default/varnish /etc/default/varnish.orig
mv varnish.txt /etc/default/varnish


# ==============================================================
# Wordpress Installation
# ==============================================================
# get latest wordpress version
#mkdir -p /var/www/$siteName
#cd /var/www/$siteName
cd /var/www/
wget http://wordpress.org/latest.tar.gz
tar -zxvf latest.tar.gz
mv wordpress $siteName
mkdir -p /var/www/$siteName/logs
rm latest.tar.gz
# set up mysql db for wordpress
echo "CREATE DATABASE IF NOT EXISTS wordpress;GRANT ALL PRIVILEGES ON wordpress.* TO admin@localhost IDENTIFIED BY 'pass' WITH GRANT OPTION;FLUSH PRIVILEGES;" | mysql -u root


# ==============================================================
#set up logging (nginx and varnish)
# ==============================================================
#set up logrotate
wget https://raw.githubusercontent.com/rayhon/c100k/master/php-web/nginx/nginx-logrotate.conf
wget https://raw.githubusercontent.com/rayhon/c100k/master/php-web/varnish/varnish-logrotate.conf
sed -i "s/DOMAIN/$siteName/g" nginx-logrotate.conf 
sed -i "s/DOMAIN/$siteName/g" varnish-logrotate.conf 
mv nginx-logrotate.conf /etc/logrotate.d/nginx
mv varnish-logrotate.conf /etc/logrotate.d/varnish

echo "varnishncsa -a -w /var/www/$siteName/logs/varnish-access.log -D -P /var/run/varnishncsa.pid" >> /etc/rc.local
/etc/init.d/php5-fpm restart
/etc/init.d/nginx restart
/etc/init.d/varnish restart


#start varnish logging:
varnishncsa -a -w /var/www/$siteName/logs/varnish-access.log -D -P /var/run/varnishncsa.pid