FROM debian:12-slim

ARG USER_ID=1000
ARG GROUP_ID=1000
ARG NODE_VERSION=24.12.0
ARG TZ=America/Porto_Velho

ENV USER_ID=${USER_ID} \
     GROUP_ID=${GROUP_ID} \
     DEBIAN_FRONTEND=noninteractive \
     NVM_DIR=/usr/local/nvm \
     COMPOSER_ALLOW_SUPERUSER=1 \
     MYSQL_ROOT_PASSWORD=password \
     MARIADB_ROOT_PASSWORD=password \
     POSTGRES_PASSWORD=password \
     PATH="/usr/local/nvm/versions/node/v${NODE_VERSION}/bin:${PATH}"

# Base tooling and locales
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl wget gnupg2 lsb-release software-properties-common apt-transport-https \
      locales tzdata supervisor \
      git zip unzip nano vim \
      build-essential pkg-config \
      libicu-dev libxml2-dev libzip-dev libonig-dev \
      libpng-dev libjpeg-dev libfreetype6-dev \
      libcurl4-openssl-dev libpq-dev libsqlite3-dev \
      libssl-dev libmagickwand-dev imagemagick \
      poppler-utils tesseract-ocr tesseract-ocr-por ocrmypdf \
 && echo "${TZ}" > /etc/timezone \
 && ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime \
 && sed -i 's/# *en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen \
 && locale-gen \
 && rm -rf /var/lib/apt/lists/*

# PHP from Sury
RUN curl -fsSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/sury-php.gpg \
 && echo "deb https://packages.sury.org/php/ $(. /etc/os-release && echo ${VERSION_CODENAME}) main" > /etc/apt/sources.list.d/sury-php.list

# MySQL 8.4 repo
RUN curl -fsSL https://repo.mysql.com/RPM-GPG-KEY-mysql-2023 | gpg --dearmor -o /usr/share/keyrings/mysql.gpg \
 && echo "deb [signed-by=/usr/share/keyrings/mysql.gpg] http://repo.mysql.com/apt/debian/ $(lsb_release -sc) mysql-8.4" > /etc/apt/sources.list.d/mysql.list

# MariaDB 11.4 repo
RUN curl -fsSL https://mariadb.org/mariadb_release_signing_key.pgp | gpg --dearmor -o /usr/share/keyrings/mariadb.gpg \
 && echo "deb [signed-by=/usr/share/keyrings/mariadb.gpg] http://mirror.mariadb.org/repo/11.4/debian $(lsb_release -sc) main" > /etc/apt/sources.list.d/mariadb.list

# PostgreSQL 18 repo
RUN curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/postgres.gpg \
 && echo "deb [signed-by=/usr/share/keyrings/postgres.gpg] http://apt.postgresql.org/pub/repos/apt $(lsb_release -sc)-pgdg main" > /etc/apt/sources.list.d/postgres.list

ENV PHP_VERSIONS="8.2 8.3 8.5"

# Install PHP stacks + DB servers
RUN apt-get update \
 && for v in $PHP_VERSIONS; do \
      apt-get install -y --no-install-recommends \
        php${v} php${v}-cli php${v}-common php${v}-curl php${v}-zip \
        php${v}-gd php${v}-intl php${v}-mbstring php${v}-xml \
        php${v}-mysql php${v}-pgsql php${v}-sqlite3 php${v}-bcmath \
        php${v}-opcache php${v}-imagick php${v}-xdebug php${v}-dev; \
    done \
 && apt-get install -y --no-install-recommends \
      mysql-server=8.4.* \
      mariadb-server=1:11.4.* \
      postgresql-18 postgresql-client-18 \
 && rm -rf /var/lib/apt/lists/*

# Update alternatives for PHP toolchain
RUN for v in $PHP_VERSIONS; do \
      priority=$(echo ${v} | tr -d '.')0; \
      update-alternatives --install /usr/bin/php php /usr/bin/php${v} ${priority}; \
      update-alternatives --install /usr/bin/phpize phpize /usr/bin/phpize${v} ${priority}; \
      update-alternatives --install /usr/bin/php-config php-config /usr/bin/php-config${v} ${priority}; \
      ln -sf /usr/bin/php${v} /usr/local/bin/php${v/./}; \
    done \
 && update-alternatives --set php /usr/bin/php8.3

# Composer + Symfony CLI
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
 && curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | bash \
 && apt-get update && apt-get install -y --no-install-recommends symfony-cli \
 && rm -rf /var/lib/apt/lists/*

# NVM + Node
RUN mkdir -p ${NVM_DIR} \
 && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | NVM_DIR=${NVM_DIR} PROFILE=/etc/profile.d/nvm.sh bash \
 && . /etc/profile.d/nvm.sh \
 && nvm install ${NODE_VERSION} \
 && nvm alias default ${NODE_VERSION} \
 && nvm cache clear

# Dev user
RUN groupadd -g ${GROUP_ID} devuser \
 && useradd -u ${USER_ID} -g devuser -m -s /bin/bash devuser \
 && usermod -a -G www-data devuser

# Config mount points and defaults
RUN mkdir -p /opt/devstack/config/php \
 && mkdir -p /run/mysqld /run/mariadb /var/lib/mariadb /var/log/mariadb \
 && chown -R mysql:mysql /run/mysqld /run/mariadb /var/lib/mysql /var/log/mysql || true \
 && chown -R mysql:mysql /var/lib/mariadb /var/log/mariadb \
 && chown -R postgres:postgres /var/lib/postgresql

COPY config/php/zz-dev.ini /opt/devstack/config/php/zz-dev.ini
COPY supervisord.conf /etc/supervisor/conf.d/devstack.conf
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY switch-php /usr/local/bin/switch-php

# Attach PHP ini from host mount point (falls back to bundled)
RUN for v in $PHP_VERSIONS; do \
               ln -sf /opt/devstack/config/php/zz-dev.ini /etc/php/${v}/cli/conf.d/99-dev.ini; \
          done \
 && chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/switch-php

# Global shell helpers
RUN echo '. /etc/profile.d/nvm.sh' >> /etc/bash.bashrc \
 && echo 'alias php82="switch-php 8.2"' >> /etc/bash.bashrc \
 && echo 'alias php83="switch-php 8.3"' >> /etc/bash.bashrc \
 && echo 'alias php85="switch-php 8.5"' >> /etc/bash.bashrc

# Laravel installer (per-user)
USER devuser
RUN composer global require laravel/installer \
 && echo 'export PATH="$PATH:$HOME/.composer/vendor/bin"' >> ~/.bashrc \
 && echo 'export PS1="\\[\\033[01;32m\\]\u@devstack\\[\\033[00m\\]:\\[\\033[01;34m\\]\w\\[\\033[00m\\]\n$ "' >> ~/.bashrc

USER root
WORKDIR /workspace
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash"]
