echo " ===> Setting acng server"
cat >> /etc/apt/apt.conf.d/02proxy <<EOF
Acquire::http::Proxy "http://acng-yyc.cloud.cybera.ca:3142";
Acquire::https::Proxy "http://acng-yyc.cloud.cybera.ca:3142";
Acquire::http::Proxy { download.oracle.com DIRECT; };
Acquire::http::Proxy { apt.postgresql.org DIRECT; };
EOF

echo " ===> Installing Puppet dependencies"
pushd /root
apt-get update -qq
apt-get install -y wget git
wget https://apt.puppetlabs.com/puppet5-release-xenial.deb
dpkg -i puppet5-release-xenial.deb
rm puppet5-release-xenial.deb
apt-get update -qq

echo " ===> Installing Puppet Agent"
apt-get install -y puppet-agent
ln -s /opt/puppetlabs/bin/puppet /usr/bin
ln -s /opt/puppetlabs/bin/facter /usr/bin

service mcollective stop

puppet agent -t
puppet agent -t
puppet agent -t
