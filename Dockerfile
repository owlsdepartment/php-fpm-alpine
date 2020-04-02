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
    pecl install opencensus-alpha redis && \
    pecl clear-cache && \
    docker-php-ext-enable mongodb && \
    docker-php-ext-enable opencensus && \
    docker-php-ext-enable redis && \
    docker-php-source delete

# install imagemagick
RUN apk add --no-cache imagemagick

# install blackfire
RUN version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") \
    && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/alpine/amd64/$version \
    && mkdir -p /tmp/blackfire \
    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp/blackfire \
    && mv /tmp/blackfire/blackfire-*.so $(php -r "echo ini_get ('extension_dir');")/blackfire.so \
    && printf "extension=blackfire.so\nblackfire.agent_socket=tcp://blackfire:8707\n" > $PHP_INI_DIR/conf.d/blackfire.ini \
    && rm -rf /tmp/blackfire /tmp/blackfire-probe.tar.gz

WORKDIR /var/www
