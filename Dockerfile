FROM php:7.4.33-apache

WORKDIR /var/www/html

ENV PATH=$PATH:/var/www/dry/src/bin

# Update
RUN apt update
RUN apt -y upgrade

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
RUN nodenv install 20.5.0
RUN export NODENV_VERSION=20.5.0 && corepack enable

RUN apt -y install rsync
RUN apt -y install zip unzip zlib1g-dev libzip-dev
RUN apt -y install openssh-client
RUN apt -y install git
RUN apt update
RUN apt -y install gcc g++ make
RUN #npm config set unsafe-perm true
RUN apt-get install nano

# install php extensions
RUN apt -y install libmagickwand-dev --no-install-recommends
RUN pecl install imagick
RUN pecl install xdebug-3.1.5
RUN apt install -y libjpeg-dev libpng-dev libfreetype6-dev
RUN docker-php-ext-configure gd --with-jpeg && docker-php-ext-install gd
RUN docker-php-ext-install zip
RUN docker-php-ext-install mysqli
RUN docker-php-ext-enable imagick
RUN docker-php-ext-enable xdebug

# Clean
RUN apt clean
RUN apt autoremove

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Enable apache modules
RUN a2enmod rewrite
RUN a2enmod expires

# Symbolic link php executable for dry
RUN ln -s /usr/local/bin/php /usr/bin/php

CMD ["/bin/bash"]
