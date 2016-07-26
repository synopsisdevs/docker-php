FROM ubuntu:12.04

MAINTAINER developers@synopsis.cz

ENV TZ Europe/Prague

ENV DEPENDENCY_PACKAGES="libapache2-mod-php5 php5-gd php5-mysql php5-curl php5-memcached php5-mcrypt"
ENV BUILD_PACKAGES="apache2 php5 openjdk-7-jre"

RUN apt-get clean \
    && apt-get update \
    && apt-get install -y $DEPENDENCY_PACKAGES $BUILD_PACKAGES \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

RUN a2enmod rewrite

COPY conf/site-default /etc/apache2/sites-enabled/000-default
COPY conf/php.ini /etc/php5/apache2/php.ini

EXPOSE 80

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
