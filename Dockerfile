FROM php:7-cli

MAINTAINER developers@synopsis.cz

# instalace sudo
RUN apt-get update -qq && apt-get install sudo && apt-get clean

# pdo
RUN docker-php-ext-install -j$(nproc) pdo

# pgsql
RUN apt-get update -qq && apt-get install -y libpq-dev && apt-get clean
RUN docker-php-ext-configure pgsql -with-pgsql=/usr/include/postgresql && docker-php-ext-install -j$(nproc) pdo_pgsql pgsql

# mysql
RUN docker-php-ext-install -j$(nproc) pdo_mysql mysqli 

# curl
RUN apt-get update -qq && apt-get install -y libcurl4-openssl-dev php5-curl && apt-get clean
RUN docker-php-ext-install -j$(nproc) curl

# gd
RUN apt-get update -qq && apt-get install -y libpng12-dev libjpeg-dev && apt-get clean
RUN docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr && docker-php-ext-install -j$(nproc) gd

# mbstring
RUN docker-php-ext-install -j$(nproc) mbstring

# json
RUN docker-php-ext-install -j$(nproc) json

# bcmath
RUN docker-php-ext-configure bcmath
RUN docker-php-ext-install -j$(nproc) bcmath

# mcrypt
RUN apt-get update -qq && apt-get install -y libmcrypt-dev && apt-get clean
RUN docker-php-ext-install -j$(nproc) mcrypt

# zip
RUN docker-php-ext-install -j$(nproc) zip

# imagick
RUN apt-get update -qq && apt-get install -y libmagickwand-6.q16-dev && apt-get clean
RUN ln -s /usr/lib/x86_64-linux-gnu/ImageMagick-6.8.9/bin-Q16/MagickWand-config /usr/bin
RUN pecl install -o -f imagick-3.4 && docker-php-ext-enable imagick && rm -rf /tmp/pear

# phpredis
ENV PHPREDIS_VERSION php7
RUN curl -L -o /tmp/redis.tar.gz https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.tar.gz \
    && tar xfz /tmp/redis.tar.gz \
    && rm -r /tmp/redis.tar.gz \
    && mv phpredis-$PHPREDIS_VERSION /usr/src/php/ext/redis \
    && docker-php-ext-install -j$(nproc) redis

# fileinfo
RUN docker-php-ext-install -j$(nproc) fileinfo

# soap
RUN apt-get update -qq && apt-get install -y libxml2-dev && apt-get clean
RUN docker-php-ext-install -j$(nproc) soap

# cron
RUN apt-get update -qq && apt-get install -y cron && apt-get clean

# calendar
RUN docker-php-ext-install calendar

# wkhtmltopdf
RUN apt-get update -qq && apt-get install -y wkhtmltopdf && apt-get clean

# php.ini
COPY conf/php.ini /usr/local/etc/php/

ADD run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
