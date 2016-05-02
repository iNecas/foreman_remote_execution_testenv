#!/usr/bin/env bash

#./register-host.sh  2>&1 | tee -a /tmp/registeration_log
yum install -y puppet
echo $CAPSULE_HOSTLINE >> /etc/hosts
cat <<EOF > /etc/puppet/puppet.conf
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
certname        = $(hostname -f)
environment     = production
server          = $PUPPET_MASTER
EOF
puppet agent --test
/usr/sbin/sshd -D
