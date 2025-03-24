#!/bin/zsh

APP=$1

if ! command -v psql &>/dev/null; then
  doas pkg_add postgresql-server
  doas rcctl enable postgresql
fi

if ! doas -u _postgresql pg_ctl status -D /var/postgresql/data &>/dev/null; then
  doas rcctl stop postgresql || true
  doas rm -rf /var/postgresql/data
  doas mkdir /var/postgresql/data
  doas chown _postgresql:_postgresql /var/postgresql/data
  doas -u _postgresql initdb -D /var/postgresql/data -E UTF8
  doas rcctl start postgresql
  sleep 10

  if ! doas -u _postgresql pg_ctl status -D /var/postgresql/data; then
    echo "PostgreSQL failed to start. Exiting..."
    exit 1
  fi

  doas -u _postgresql psql -d postgres -c "CREATE ROLE dev WITH LOGIN SUPERUSER;"
  doas -u _postgresql psql -d postgres -c "CREATE DATABASE ${APP}_development OWNER dev;"
  doas -u _postgresql psql -d postgres -c "CREATE DATABASE ${APP}_test OWNER dev;"
  doas -u _postgresql psql -d postgres -c "CREATE DATABASE ${APP}_production OWNER dev;"

  DB_PASS=$(pwgen 16 1)
  doas -u _postgresql psql -d postgres -c "DROP USER IF EXISTS ${APP}_development;"
  doas -u _postgresql psql -d postgres -c "CREATE USER ${APP}_development WITH LOGIN PASSWORD '${DB_PASS}';"
  echo "local all ${APP}_development scram-sha-256" | doas tee -a /var/postgresql/data/pg_hba.conf
  doas rcctl reload postgresql

  if ! doas -u _postgresql pg_ctl status -D /var/postgresql/data; then
    echo "PostgreSQL failed to start after configuration changes. Exiting..."
    exit 1
  fi
fi

if ! grep -q "permit nopass :wheel as _postgresql" /etc/doas.conf; then
  echo "permit nopass :wheel as _postgresql" | doas tee -a /etc/doas.conf
  commit_to_git "Install and configure PostgreSQL"
else
  echo "Install and configure PostgreSQL"
fi
