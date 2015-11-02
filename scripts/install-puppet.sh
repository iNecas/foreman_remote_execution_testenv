#!/usr/bin/env bash

PUPPET_MASTER=$(echo $FOREMAN_URL | sed 's|^http.*//||' | sed 's/:.*$//')

rpm -Uvh http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y puppet
cat > /etc/puppet/puppet.conf << EOF

[main]
vardir = /var/lib/puppet
logdir = /var/log/puppet
rundir = /var/run/puppet
ssldir = \$vardir/ssl

[agent]
pluginsync      = true
report          = true
ignoreschedules = true
daemon          = false
ca_server       = $PUPPET_MASTER
certname        = $HOST_NAME
environment     = production
server          = $PUPPET_MASTER

EOF