#!/bin/sh
#获取docker容器启动传入的环境变量，后面的值是默认值
IP=${PUPPET_SERVER_IP:-xx.xx.xx.xx}
HOSTNAME=${PUPPET_SERVER_HOSTNAME:-puppet}
CERTNAME=${PUPPET_CERTNAME:-unknow}

#puppetserver
echo "$IP  $HOSTNAME" > /etc/hosts

# Puppet config
cat << EOF > $PUPPET_CONFIG
[main]
certname = $CERTNAME.dns.xx.com
environment = production
runinterval = 300
EOF

rm -f /var/run/puppetlabs/agent.pid

supervisord -c $SUPERVISORCONF
#exec "$@"
