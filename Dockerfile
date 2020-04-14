FROM php:7.3-fpm-alpine3.10

ARG OPENCENSUS_VERSION=0.5.2

WORKDIR /var/www

## GMP IMAGEMAGIC MYSQLI OPCACHE
RUN apk add --no-cache gmp gmp-dev imagemagick \
    && docker-php-ext-configure opcache --enable-opcache \
    && docker-php-ext-install gmp mysqli pdo_mysql opcache

## MONGO REDIS
RUN apk add --no-cache --virtual building-deps autoconf g++ make openssl-dev \
    && pecl install redis mongodb \
    && docker-php-ext-enable redis mongodb \
    && apk del building-deps

## OPENCENSUS
RUN apk add --no-cache --virtual building-deps autoconf g++ make openssl-dev tar gzip \
    && curl "https://codeload.github.com/census-instrumentation/opencensus-php/tar.gz/v${OPENCENSUS_VERSION}" -o opencensus.tar.gz \
    && tar -zxvf opencensus.tar.gz \
    && cd "opencensus-php-${OPENCENSUS_VERSION}/ext" \
    && find . -type f -exec sed -i s/ZVAL_DESTRUCTOR/zval_ptr_dtor/g {} + \
    && phpize \
    && ./configure --enable-opencensus \
    && make \
    && make test \
    && make install \
    && docker-php-ext-enable opencensus \
    && rm -rf "opencensus-php-${OPENCENSUS_VERSION}" opencensus.tar.gz \
    && apk del building-deps

## BLACKFIRE
RUN version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") \
    && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/alpine/amd64/$version \
    && mkdir -p /tmp/blackfire \
    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp/blackfire \
    && mv /tmp/blackfire/blackfire-*.so $(php -r "echo ini_get ('extension_dir');")/blackfire.so \
    && docker-php-ext-enable blackfire \
    && rm -rf /tmp/blackfire /tmp/blackfire-probe.tar.gz
