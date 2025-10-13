FROM php:7.2.34-apache

# --- Fix Buster archive issue ---
RUN sed -i 's|deb.debian.org/debian|archive.debian.org/debian|g' /etc/apt/sources.list \
 && sed -i 's|security.debian.org|archive.debian.org|g' /etc/apt/sources.list \
 && echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until

WORKDIR /var/www/html

# change this value if you want to force a rebuild without cache
ARG CACHEBUST=4

ENV PATH=$PATH:/var/www/dry/src/bin

# Update and install all system packages in one go
RUN apt update --allow-releaseinfo-change && apt -y upgrade && \
    apt install -yq --no-install-recommends \
    tzdata \
    curl \
    dirmngr \
    apt-transport-https \
    lsb-release \
    ca-certificates \
    python \
    git-core \
    fswatch \
    rsync \
    git \
    openssh-client \
    zip \
    unzip \
    autoconf \
    automake \
    libtool \
    nasm \
    zlib1g-dev \
    libzip-dev \
    libpng-dev \
    libimagequant-dev \
    gcc \
    g++ \
    make \
    nano \
    libjpeg-dev \
    libfreetype6-dev \
    libwebp-dev \
    libmagickwand-dev \
    && rm -rf /var/lib/apt/lists/*

# set timezone
RUN ln -fs /usr/share/zoneinfo/Europe/Brussels /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# install nodenv (no apt install needed here anymore)
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

# Configure and install php extensions (all packages already installed above)
RUN command docker-php-ext-configure gd --with-jpeg-dir=/usr/include/ --with-freetype-dir=/usr/include/ --with-webp-dir=/usr/include/
RUN pecl install imagick
RUN pecl install xdebug-3.1.5
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd
RUN docker-php-ext-install mysqli
RUN docker-php-ext-enable imagick
RUN docker-php-ext-install exif
RUN docker-php-ext-enable xdebug
RUN docker-php-ext-install soap

# Conditionally install Puppeteer dependencies
ARG ENABLE_PUPPETEER=false
RUN if [ "$ENABLE_PUPPETEER" = "true" ]; then \
    apt update && apt install -y --no-install-recommends \
    libx11-xcb1 \
    libxcomposite1 \
    libasound2t64 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libexpat1 \
    libfontconfig1 \
    libgbm1 \
    libgcc1 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libstdc++6 \
    libx11-6 \
    libxcb1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    && rm -rf /var/lib/apt/lists/*; \
    fi

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

# Health check for Apache
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

CMD ["/bin/bash"]
