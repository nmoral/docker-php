FROM php:8.1-fpm
WORKDIR "/application"
ARG xdebug=1


# Fix debconf warnings upon build
ARG DEBIAN_FRONTEND=noninteractive
RUN usermod -u 1000 www-data

# Install selected extensions and other stuff
RUN apt-get update \
    && apt-get -y --no-install-recommends install make \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Install git
RUN apt-get update \
    && apt-get -y install git wget libsodium-dev zip unzip libzip-dev \
    libpcre3-dev sqlite3 libsqlite3-dev \
     libjpeg-dev libpng-dev \
     libicu-dev npm \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

RUN docker-php-ext-configure intl

RUN docker-php-ext-install \
    sodium \
    pdo \
    pdo_mysql \
    pdo_sqlite \
    zip \
    opcache \
    intl \
    gd


RUN if [$xdebug = 1]; then pecl install xdebug && docker-php-ext-enable xdebug; fi

ENV         COMPOSER_HOME=/var/composer
COPY        ./composer-install /tmp/composer-install
RUN         chmod +x /tmp/composer-install
RUN         /tmp/composer-install
RUN         rm /tmp/composer-install
RUN         mkdir -p /var/composer && \
            chown -R www-data:www-data /var/composer
VOLUME      /var/composer
