FROM synopsis/php:ldap

MAINTAINER developers@synopsis.cz

RUN apt-get update && \
    apt-get install -y git-core && \
    rm -rf /var/lib/apt/lists/*

RUN a2enmod cgi 

ADD conf/apache2.conf /etc/apache2/apache2.conf
