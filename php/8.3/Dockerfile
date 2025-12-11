FROM php:8.3-cli

ARG USER_ID=1000
ARG GROUP_ID=1000
ARG NODE_VERSION=24.12.0

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

# Symfony CLI
RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | bash \
 && apt install -y symfony-cli

# Copiar configurações customizadas do PHP
COPY custom.ini /usr/local/etc/php/conf.d/custom.ini

# Criar usuário com mesmo UID/GID do host
RUN groupadd -g ${GROUP_ID} devuser && \
    useradd -u ${USER_ID} -g devuser -m -s /bin/bash devuser

# Trocar para devuser para instalar ferramentas de desenvolvimento
USER devuser

# Instalar NVM + Node como devuser
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash \
 && export NVM_DIR="$HOME/.nvm" \
 && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" \
 && nvm install $NODE_VERSION \
 && nvm use $NODE_VERSION \
 && nvm alias default $NODE_VERSION

# Laravel Installer para devuser
RUN composer global require laravel/installer

# Configurar bash colorido para devuser
RUN echo 'export PS1="\[\033[01;32m\]\u@php8.3\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\n$ "' >> ~/.bashrc \
 && echo 'alias ls="ls --color=auto"' >> ~/.bashrc \
 && echo 'alias grep="grep --color=auto"' >> ~/.bashrc \
 && echo 'alias ll="ls -lah --color=auto"' >> ~/.bashrc \
 && echo 'export TERM=xterm-256color' >> ~/.bashrc \
 && echo 'export PATH="$PATH:$HOME/.composer/vendor/bin"' >> ~/.bashrc

WORKDIR /workspace
