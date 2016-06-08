FROM php:7-apache

MAINTAINER developers@synopsis.cz

RUN a2enmod rewrite 

# mbstring
RUN docker-php-ext-install -j$(nproc) mbstring

# json
RUN docker-php-ext-install -j$(nproc) json

# mcrypt
RUN apt-get update && apt-get install -y libmcrypt-dev && apt-get clean
RUN docker-php-ext-install -j$(nproc) mcrypt

# php.ini
COPY conf/php.ini /usr/local/etc/php/
