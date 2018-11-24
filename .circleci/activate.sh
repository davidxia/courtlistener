#!/usr/bin/env bash

service postgresql start
service redis-server start
service solr start
source ~/virtualenvs/courtlistener/bin/activate
exec "$@"
