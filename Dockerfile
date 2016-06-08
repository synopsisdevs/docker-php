FROM php:7-apache

MAINTAINER developers@synopsis.cz

RUN apt-get update && \
    apt-get install libldap2-dev -y && \
    rm -rf /var/lib/apt/lists/* && \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu && \
    docker-php-ext-configure bcmath && \
    docker-php-ext-install ldap bcmath

RUN a2enmod rewrite ldap authnz_ldap

ADD conf/000-default.conf /etc/apache2/sites-enabled/000-default.conf
