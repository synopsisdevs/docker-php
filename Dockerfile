FROM php:7.0-apache

MAINTAINER developers@synopsis.cz

RUN a2enmod rewrite

ENV TZ Europe/Prague

ENV XDEBUG_VERSION 2.4
ENV REDIS_VERSION 3.1.1
ENV OPENSSL_VERSION="OpenSSL_1_0_1-stable"

ENV DEPENDENCY_PACKAGES="libpq-dev libcurl4-openssl-dev libjpeg-dev libfreetype6-dev libpng-dev libmcrypt-dev libxml2-dev libmagickwand-6.q16-dev libc-client-dev libkrb5-dev libssh2-1-dev"
ENV BUILD_PACKAGES="sudo cron wkhtmltopdf supervisor ssl-cert locales git"

RUN sed -i  "s/http:\/\/httpredir\.debian\.org\/debian/ftp:\/\/ftp\.debian\.org\/debian/g" /etc/apt/sources.list

RUN apt-get clean \
    && apt-get update \
    && apt-get install -y $DEPENDENCY_PACKAGES $BUILD_PACKAGES \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

# imagick
RUN ln -s /usr/lib/x86_64-linux-gnu/ImageMagick-6.8.9/bin-Q16/MagickWand-config /usr/bin \
    && pecl install -o -f imagick-3.4 && docker-php-ext-enable imagick && rm -rf /tmp/pear

# xdebug & redis
RUN pecl install -o -f xdebug-$XDEBUG_VERSION redis-$REDIS_VERSION\
    && docker-php-ext-enable xdebug redis\
    && rm -rf /tmp/pear

# SSH2
# TODO PECL is buggy, we must compile it.
RUN git clone https://github.com/php/pecl-networking-ssh2.git /usr/src/php/ext/ssh2 \
	&& docker-php-ext-install ssh2

RUN docker-php-ext-configure pgsql -with-pgsql=/usr/include/postgresql \
    && docker-php-ext-configure gd --enable-gd-native-ttf --with-png-dir=/usr/include --with-jpeg-dir=/usr/include --with-freetype-dir=/usr/include/freetype2 \
    && docker-php-ext-configure bcmath \
    && docker-php-ext-configure imap --with-imap-ssl --with-kerberos \
    && docker-php-ext-install -j$(nproc) pdo pdo_pgsql pgsql pdo_mysql mysqli curl gd mbstring json bcmath mcrypt zip fileinfo soap calendar imap

# propper Install zip
RUN apt-get update && \
     apt-get install -y \
         zlib1g-dev \
         && docker-php-ext-install zip

# wkhtmltopdf
COPY bin/wkhtmltopdf /usr/bin/wkhtmltopdf
COPY bin/wkhtmltoimage /usr/bin/wkhtmltoimage

# php.ini
COPY conf/php.ini /usr/local/etc/php/

# xdebugu configuration
COPY conf/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

# cron
COPY cron /etc/pam.d/cron

# supervisor.conf
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/000-supervisord.conf

# locales
COPY conf/locales.sh /etc/locales.sh
RUN chmod +x /etc/locales.sh
RUN /etc/locales.sh

#wait for dependent containers
COPY bin/wait /wait
RUN chmod +x /wait
COPY run.sh /run.sh
RUN chmod +x /run.sh

#openssl
RUN apt-get remove -y openssl && \
    cd /usr/src && \
    git clone https://github.com/openssl/openssl.git && \
    cd openssl && git checkout $OPENSSL_VERSION && \
    ./config shared --prefix=/usr/local/openssl/ && \
    make && \
    make install && \
    ln -s /usr/local/openssl/bin/openssl /usr/bin/openssl

EXPOSE 80 9001

CMD /run.sh
