FROM php:7-apache

MAINTAINER developers@synopsis.cz

RUN a2enmod rewrite 
RUN a2enmod ssl
RUN a2ensite 000-default
RUN a2ensite default-ssl

ENV TZ Europe/Prague

ENV REDIS_VERSION 3.0

ENV DEPENDENCY_PACKAGES="libpq-dev libcurl4-openssl-dev libpng12-dev libjpeg-dev libfreetype6-dev libpng-dev libmcrypt-dev libxml2-dev libmagickwand-6.q16-dev"
ENV BUILD_PACKAGES="sudo cron wkhtmltopdf supervisor rsyslog ssl-cert"

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

# redis
RUN pecl install -o -f redis-$REDIS_VERSION \
    && docker-php-ext-enable redis \
    && rm -rf /tmp/pear

RUN docker-php-ext-configure pgsql -with-pgsql=/usr/include/postgresql \
    && docker-php-ext-configure gd --enable-gd-native-ttf --with-png-dir=/usr/include --with-jpeg-dir=/usr/include --with-freetype-dir=/usr/include/freetype2 \
    && docker-php-ext-configure bcmath \
    && docker-php-ext-install -j$(nproc) pdo pdo_pgsql pgsql pdo_mysql mysqli curl gd mbstring json bcmath mcrypt zip fileinfo soap calendar

# wkhtmltopdf
COPY bin/wkhtmltopdf /usr/bin/wkhtmltopdf
COPY bin/wkhtmltoimage /usr/bin/wkhtmltoimage

# php.ini
COPY conf/php.ini /usr/local/etc/php/

# cron
COPY cron /etc/pam.d/cron

# supervisor.conf
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/000-supervisord.conf

EXPOSE 80 443 9001

CMD ["/usr/bin/supervisord"]
