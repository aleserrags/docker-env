#!/usr/bin/env bash
set -euo pipefail

PHP_VERSIONS="8.2 8.3 8.5"

init_mysql() {
  mkdir -p /run/mysqld
  chown -R mysql:mysql /run/mysqld /var/lib/mysql

  if [ ! -d /var/lib/mysql/mysql ]; then
    mysqld --initialize-insecure --user=mysql --datadir=/var/lib/mysql
    mysqld --user=mysql --skip-networking --socket=/run/mysqld/mysqld.sock --pid-file=/run/mysqld/mysqld.pid &
    for i in $(seq 1 30); do
      [ -S /run/mysqld/mysqld.sock ] && break
      sleep 1
    done
    mysql --protocol=socket -uroot --socket=/run/mysqld/mysqld.sock -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}'; FLUSH PRIVILEGES;"
    mysqladmin --protocol=socket -uroot -p"${MYSQL_ROOT_PASSWORD}" --socket=/run/mysqld/mysqld.sock shutdown
  fi
}

init_mariadb() {
  mkdir -p /run/mariadb /var/lib/mariadb /var/log/mariadb
  chown -R mysql:mysql /run/mariadb /var/lib/mariadb /var/log/mariadb

  if [ ! -d /var/lib/mariadb/mysql ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mariadb --skip-test-db
    mariadbd --user=mysql --datadir=/var/lib/mariadb --port=3307 --socket=/run/mariadb/mysqld.sock --pid-file=/run/mariadb/mariadb.pid &
    for i in $(seq 1 30); do
      [ -S /run/mariadb/mysqld.sock ] && break
      sleep 1
    done
    mariadb --protocol=socket --socket=/run/mariadb/mysqld.sock -uroot -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}'; FLUSH PRIVILEGES;"
    mariadb-admin --protocol=socket --socket=/run/mariadb/mysqld.sock -uroot -p"${MARIADB_ROOT_PASSWORD}" shutdown
  fi
}

init_postgres() {
  if [ ! -d /var/lib/postgresql/18/main ]; then
    pg_createcluster 18 main --start
  fi

  if [ ! -f /var/lib/postgresql/.pg_initialized ]; then
    pg_ctlcluster 18 main start
    su - postgres -c "psql -c \"ALTER USER postgres WITH PASSWORD '${POSTGRES_PASSWORD}';\""
    pg_ctlcluster 18 main stop
    touch /var/lib/postgresql/.pg_initialized
  fi
}

# Make sure the devuser owns the workspace mount point if it exists
if [ -d /workspace ]; then
  chown -R ${USER_ID:-1000}:${GROUP_ID:-1000} /workspace || true
fi

init_mysql
init_mariadb
init_postgres

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/devstack.conf
