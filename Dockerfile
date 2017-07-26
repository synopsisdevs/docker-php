FROM ubuntu:12.04

MAINTAINER developers@synopsis.cz

ENV TZ Europe/Prague

ENV DEPENDENCY_PACKAGES="libapache2-mod-php5 php5-gd php5-mysql php5-curl php5-memcached php5-mcrypt libssh2-1-dev libssh2-php"
ENV BUILD_PACKAGES="apache2 php5 openjdk-7-jre cron supervisor ssl-cert"

RUN apt-get clean \
    && apt-get update \
    && apt-get install -y $DEPENDENCY_PACKAGES $BUILD_PACKAGES \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

RUN mkdir -p /var/run/apache2

RUN a2enmod rewrite
RUN a2enmod ssl

COPY conf/default /etc/apache2/sites-available/default
COPY conf/default-ssl /etc/apache2/sites-available/default-ssl
COPY conf/php.ini /etc/php5/apache2/php.ini

RUN a2ensite default
RUN a2ensite default-ssl

# cron
COPY cron /etc/pam.d/cron

# supervisor.conf
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/000-supervisord.conf

EXPOSE 80 443 9001

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
