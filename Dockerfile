FROM php:7.0-apache

MAINTAINER developers@synopsis.cz

RUN apt-get update && \
    apt-get install -y git-core && \
    rm -rf /var/lib/apt/lists/*

RUN a2enmod rewrite cgi alias

ADD conf/000-default.conf /etc/apache2/sites-enabled/000-default.conf

ADD conf/apache2.conf /etc/apache2/apache2.conf
