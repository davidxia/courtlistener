#!/usr/bin/env bash
set -e

apt-get update -qq && apt-get install -y --no-install-recommends \
  postgresql-9.3 \
  python-psycopg2
/etc/init.d/postgresql start

# Do this first before we change pg_hba.conf so we can guarantee we have the right password.
su postgres -c "psql -U postgres -c \"ALTER USER postgres WITH ENCRYPTED PASSWORD 'password';\""
mv /var/circleci/pg_hba.conf /etc/postgresql/9.3/main/pg_hba.conf
chown postgres:postgres /etc/postgresql/9.3/main/pg_hba.conf
mv /var/circleci/pgpass ~/.pgpass
chmod 600 ~/.pgpass
/etc/init.d/postgresql restart

# Create django user and courtlistener database
psql -U postgres -c "CREATE USER django WITH PASSWORD 'your-password' CREATEDB NOSUPERUSER;"
psql -U postgres -c "CREATE DATABASE courtlistener WITH OWNER django TEMPLATE template0 ENCODING 'UTF-8';"
psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE courtlistener to django;"
