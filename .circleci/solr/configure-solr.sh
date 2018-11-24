#!/usr/bin/env bash
set -ex

apt-get update -qq && apt-get install -y --no-install-recommends \
  openjdk-7-jre-headless \
  daemon

mkdir -p /var/log/solr /opt/solr-cores
cd /opt && wget https://archive.apache.org/dist/lucene/solr/4.10.4/solr-4.10.4.tgz
tar -xzvf solr-4.10.4.tgz
ln -s /opt/solr-4.10.4 /usr/local/solr

cp /var/circleci/solr/solr.sysv /etc/init.d/solr
chmod 755 /etc/init.d/solr
cp /var/circleci/solr/solr.logrotate /etc/logrotate.d/solr
cp /var/circleci/solr/solr.xml.j2 /opt/solr-cores/solr.xml

for d in collection1 audio opinion recap person; do
  mkdir -p /opt/solr-cores/$d/data
  cp -R /usr/local/solr/example/solr/collection1/conf /opt/solr-cores/$d/
  cp /var/circleci/solr/elevate.xml /opt/solr-cores/$d/conf/
  cp "/var/circleci/solr/${d}_schema.xml" /opt/solr-cores/$d/conf/schema.xml
  cp /var/circleci/solr/solrconfig.xml.j2 /opt/solr-cores/$d/conf/solrconfig.xml
  sed -i 's%<dataDir>/opt/solr-cores/{{ item }}/data/</dataDir>%<dataDir>/opt/solr-cores/collection1/data/</dataDir>%' /opt/solr-cores/$d/conf/solrconfig.xml
  rm -fr /opt/solr-cores/$d/conf/lang
  cp -R /var/circleci/solr/lang /opt/solr-cores/$d/conf/
done

rm -fr ls /usr/local/solr/example/solr/collection1
ln -s /opt/solr-cores/collection1 /usr/local/solr/example/solr/collection1
