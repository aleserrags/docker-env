FROM php:8.2-cli

ENV NVM_DIR=/root/.nvm
ENV NODE_VERSION=24.12.0

# Dependências do sistema
 RUN apt-get update && apt-get install -y \
      git zip unzip curl wget nano vim \
      libicu-dev libxml2-dev libzip-dev \
      libonig-dev libpng-dev libjpeg-dev libfreetype6-dev \
      libcurl4-openssl-dev libpq-dev libsqlite3-dev \
      libssl-dev pkg-config \
      libmagickwand-dev --no-install-recommends \
 && rm -rf /var/lib/apt/lists/*

# Extensões PHP (curl é built-in desde PHP 8.0)
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install \
      intl \
      mbstring \
      zip \
      gd \
      pdo \
      pdo_mysql \
      pdo_pgsql \
      pdo_sqlite \
      bcmath \
      xml \
      opcache

# Imagick
RUN pecl install imagick && docker-php-ext-enable imagick

# Xdebug
RUN pecl install xdebug && docker-php-ext-enable xdebug

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Instalar NVM + Node
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash \
 && . $NVM_DIR/nvm.sh \
 && nvm install $NODE_VERSION \
 && nvm use $NODE_VERSION \
 && nvm alias default $NODE_VERSION

# Tornar Node/NPM acessível no PATH (fora do shell de login)
ENV PATH="$NVM_DIR/versions/node/v$NODE_VERSION/bin/:$PATH"

# Symfony CLI
RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | bash \
 && apt install -y symfony-cli

# Laravel Installer
RUN composer global require laravel/installer \
 && echo 'export PATH="$PATH:$HOME/.composer/vendor/bin"' >> /root/.bashrc

# Configurar bash colorido
RUN echo 'export PS1="\[\033[01;32m\]\u@php8.2\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\n$ "' >> /root/.bashrc \
 && echo 'alias ls="ls --color=auto"' >> /root/.bashrc \
 && echo 'alias grep="grep --color=auto"' >> /root/.bashrc \
 && echo 'alias ll="ls -lah --color=auto"' >> /root/.bashrc \
 && echo 'export TERM=xterm-256color' >> /root/.bashrc

# Copiar configurações customizadas do PHP
COPY custom.ini /usr/local/etc/php/conf.d/custom.ini

WORKDIR /workspace
