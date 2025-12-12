# PHP + DB devstack (8.2/8.3/8.5, MySQL 8.4, MariaDB 11.4, PostgreSQL 18)

## Build e subir

```bash
docker compose -f docker-compose.all-in-one.yml build
docker compose -f docker-compose.all-in-one.yml up -d
```

Mount padrão: `../projetos -> /workspace`. Ajuste no compose se precisar.

## Alternar PHP dentro do container

```bash
switch-php 8.2   # ou 8.3 / 8.5
php -v           # conferência
```
Aliases rápidos: `php82`, `php83`, `php85`.

## Configurações externas

- PHP INI: monte sua pasta em `/opt/devstack/config/php` (já mapeada no compose para `./all-in-one/config/php`).
- DB data: use volumes adicionais se quiser persistir `/var/lib/mysql`, `/var/lib/mariadb`, `/var/lib/postgresql/18/main`.
- Troque senhas via envs `MYSQL_ROOT_PASSWORD`, `MARIADB_ROOT_PASSWORD`, `POSTGRES_PASSWORD` no compose.

## Bancos de dados

- MySQL 8.4: porta 3306, usuário root, senha conforme env.
- MariaDB 11.4: porta 3307, usuário root, senha conforme env.
- PostgreSQL 18: porta 5432, usuário postgres, senha conforme env.

## Tooling incluído

- Composer, Laravel installer, Symfony CLI
- NVM + Node 24.12.0, npm, npx
- Xdebug e Imagick em todas as versões do PHP
- Utilitários de CLI (git, zip/unzip, curl/wget, imagemagick, poppler, tesseract, ocrmypdf)

## Shell

Prompt customizado: `usuario@devstack`. `nvm` e `~/.composer/vendor/bin` já no PATH para o usuário `devuser`.
