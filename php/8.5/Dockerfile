FROM php:8.5-cli

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

# Extensões PHP (curl e opcache são built-in desde PHP 8.0)
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
      xml

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

# Configurar Git safe.directory (executado automaticamente ao entrar no container)
RUN echo 'git config --global --add safe.directory "*" 2>/dev/null || true' >> /root/.bashrc

WORKDIR /workspace
