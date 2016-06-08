FROM ubuntu:12.04

# apache, php
RUN apt-get update && apt-get install -y apache2 php5 libapache2-mod-php5

# extensions
RUN apt-get update && apt-get install -y php5-gd php5-mysql php5-curl php5-memcached php5-mcrypt

RUN a2enmod rewrite

COPY conf/site-default /etc/apache2/sites-enabled/000-default
COPY conf/php.ini /etc/php5/apache2/php.ini

EXPOSE 80

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
