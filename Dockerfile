# FROM ubuntu:latest
FROM ubuntu:trusty

MAINTAINER Richard Hoffmann "r.hoffmann@crolla-lowis.de"

RUN apt-get update

RUN apt-get -y install software-properties-common
# RUN apt-get -y install python3-software-properties
# RUN add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) main universe restricted multiverse"
# RUN add-apt-repository -y ppa:ufirst/php5
RUN add-apt-repository -y ppa:ondrej/php
RUN apt-get update

RUN apt-get -y install apache2 php5.6-fpm php5.6-mysql php5.6-imagick php5.6-imap php5.6-mcrypt php5.6-curl php5.6-cli php5.6-gd php5.6-pgsql php5.6-sqlite php5.6-common php-pear curl php5.6-json memcached php5.6-memcache php5.6-xdebug

# RUN sed -i "s/variables_order.*/variables_order = \"EGPCS\"/g" /etc/php5/apache2/php.ini
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/
RUN mv /usr/bin/composer.phar /usr/bin/composer

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD run.sh /run.sh
RUN chmod 755 /*.sh

# Add our fpm configuration
COPY fpm.conf /etc/php5/fpm/pool.d/www.conf
# Add our apache configuration

COPY apache2.conf /etc/apache2/apache2.conf

# Enable required modules
RUN ln -s /etc/php5/mods-available/mcrypt.ini /etc/php5/fpm/conf.d/20-mcrypt.ini
RUN ln -s /etc/php5/mods-available/mcrypt.ini /etc/php5/cli/conf.d/20-mcrypt.ini

# Enable Xdebug remote_connect_back
RUN echo "xdebug.remote_connect_back=on" >> /etc/php5/mods-available/xdebug.ini
RUN echo "xdebug.remote_enable=on" >> /etc/php5/mods-available/xdebug.ini
RUN echo "xdebug.remote_autostart=on" >> /etc/php5/mods-available/xdebug.ini
RUN echo "xdebug.remote_port=9001" >> /etc/php5/mods-available/xdebug.ini

# Give www-data write access to mounted volumes
RUN usermod -u 1000 www-data

# Enable apache modules
RUN a2enmod proxy_fcgi
RUN a2enmod rewrite
RUN a2enmod headers

EXPOSE 80

CMD ["/run.sh"]
