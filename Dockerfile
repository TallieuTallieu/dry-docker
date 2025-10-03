FROM php:7.2.34-apache

# --- Fix Buster archive issue ---
RUN sed -i 's|deb.debian.org/debian|archive.debian.org/debian|g' /etc/apt/sources.list \
 && sed -i 's|security.debian.org|archive.debian.org|g' /etc/apt/sources.list \
 && echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until

WORKDIR /var/www/html

# change this value if you want to force a rebuild without cache
ARG CACHEBUST=4

ENV PATH=$PATH:/var/www/dry/src/bin

# Update
RUN apt update
RUN apt -y upgrade

# set timezone
RUN apt-get install -yq tzdata && \
    ln -fs /usr/share/zoneinfo/Europe/Brussels /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# install nodenv
RUN apt -y install curl dirmngr apt-transport-https lsb-release ca-certificates python git-core
RUN git clone https://github.com/nodenv/nodenv.git /root/.nodenv && \
    git clone https://github.com/nodenv/node-build.git /root/.nodenv/plugins/node-build && \
    git clone https://github.com/nodenv/nodenv-package-rehash.git /root/.nodenv/plugins/nodenv-package-rehash && \
    git clone https://github.com/nodenv/nodenv-update.git /root/.nodenv/plugins/nodenv-update

ENV PATH /root/.nodenv/shims:/root/.nodenv/bin:$PATH

RUN nodenv install 10.24.1
RUN nodenv install 12.22.12
RUN nodenv install 14.21.3
RUN nodenv install 16.20.1
RUN export NODENV_VERSION=16.20.1 && corepack enable
RUN nodenv install 18.16.1
RUN export NODENV_VERSION=18.16.1 && corepack enable
RUN nodenv install 20.11.1
RUN export NODENV_VERSION=20.11.1 && corepack enable
RUN nodenv install 22.14.0
RUN export NODENV_VERSION=22.14.0 && corepack enable

RUN apt -y install fswatch
RUN apt -y install rsync
RUN apt -y install git
RUN apt -y install openssh-client
RUN apt -y install zip unzip autoconf automake libtool nasm zlib1g-dev libzip-dev libpng-dev libimagequant-dev
RUN apt update
RUN apt -y install gcc g++ make
RUN #npm config set unsafe-perm true
RUN apt -y install nano

# Add WebP support d
RUN apt-get update && apt-get install -y libjpeg-dev libpng-dev libfreetype6-dev libwebp-dev && rm -rf /var/lib/apt/lists/*
RUN command docker-php-ext-configure gd --with-jpeg-dir=/usr/include/ --with-freetype-dir=/usr/include/ --with-webp-dir=/usr/include/

# install php extensions
RUN apt-get update --allow-releaseinfo-change \
 && apt-get install -y --no-install-recommends libmagickwand-dev \
 && rm -rf /var/lib/apt/lists/*
RUN pecl install imagick
RUN pecl install xdebug-3.1.5
RUN apt install -y libjpeg-dev libpng-dev libfreetype6-dev
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd
RUN docker-php-ext-install mysqli
RUN docker-php-ext-enable imagick
RUN docker-php-ext-install exif
RUN docker-php-ext-enable xdebug
RUN docker-php-ext-install soap

# Clean
RUN apt clean
RUN apt autoremove -y

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Enable apache modules
RUN a2enmod rewrite
RUN a2enmod expires

# Symbolic link php executable for dry
RUN ln -s /usr/local/bin/php /usr/bin/php

CMD ["/bin/bash"]
