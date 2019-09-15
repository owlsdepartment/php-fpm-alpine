FROM php:7.3-fpm-alpine3.10

# Install gmp
RUN apk add --no-cache gmp gmp-dev

RUN docker-php-ext-install mysqli pdo_mysql gmp
RUN docker-php-ext-configure opcache --enable-opcache && \
    docker-php-ext-install opcache

# install mongodb
RUN apk add --no-cache autoconf g++ make openssl-dev && \
    apk add --no-cache --virtual .mongodb-ext-build-deps pcre-dev && \
    pecl install mongodb && \
    apk del .mongodb-ext-build-deps && \
    pecl install opencensus-alpha && \
    pecl clear-cache && \
    docker-php-ext-enable mongodb && \
    docker-php-ext-enable opencensus && \
    docker-php-source delete

# install imagemagick
RUN apk add --no-cache imagemagick

WORKDIR /var/www
