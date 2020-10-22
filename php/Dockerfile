FROM composer:latest as composer

FROM php:7.4.2-fpm

WORKDIR /app/api

RUN apt-get update && apt-get install -y openssl libfreetype6-dev libjpeg62-turbo-dev libmcrypt-dev libpng-dev libonig-dev libasound2 wget qpdf procps \
    autoconf automake bash make gcc g++ zip libzip-dev libxrender1 libfontconfig1 libxtst6 librabbitmq-dev \
    && pecl install apcu-5.1.17 \
    && pecl install xdebug-2.9.0 \
    && pecl install redis \
    && pecl install amqp \
    && docker-php-ext-install opcache pdo pdo_mysql zip bcmath sockets gd mbstring \
    && docker-php-ext-enable redis opcache apcu xdebug amqp

RUN cd /tmp
RUN wget http://launchpadlibrarian.net/340410966/libgcj17_6.4.0-8ubuntu1_amd64.deb \
    http://launchpadlibrarian.net/337429932/libgcj-common_6.4-3ubuntu1_all.deb \
    http://ftp.br.debian.org/debian/pool/main/g/gcc-6/gcc-6-base_6.3.0-18+deb9u1_amd64.deb

RUN apt-get install -y ./gcc-6-base_6.3.0-18+deb9u1_amd64.deb \
    ./libgcj17_6.4.0-8ubuntu1_amd64.deb \
    ./libgcj-common_6.4-3ubuntu1_all.deb

RUN wget http://ftp.us.debian.org/debian/pool/main/p/pdftk/pdftk_2.02-4+b2_amd64.deb
RUN dpkg -i pdftk_2.02-4+b2_amd64.deb

RUN apt-get install libmcrypt-dev libreadline-dev

COPY --from=composer /usr/bin/composer /usr/bin/composer
COPY config/ /usr/local/etc/php/conf.d/
RUN sed -i "1 i\zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN sed -i "1 i\zend_extension=$(find /usr/local/lib/php/extensions/ -name opcache.so)" /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini

RUN printf '[PHP]\ndate.timezone = "Europe/Madrid"\n' > /usr/local/etc/php/conf.d/tzone.ini
