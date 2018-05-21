echo " ===> Installing Puppet dependencies"
pushd /root
apt-get update -qq
apt-get install -y wget git
wget https://apt.puppetlabs.com/puppet5-release-xenial.deb
dpkg -i puppet5-release-xenial.deb
rm puppet5-release-xenial.deb
apt-get update -qq

echo " ===> Installing Puppet Server"
apt-get install -y puppetserver
echo "JAVA_ARGS=\"-Xms512m -Xmx512m\"" >> /etc/default/puppetserver
echo "*.lxd" >> /etc/puppetlabs/puppet/autosign.conf
service puppetserver restart

cat > /etc/puppetlabs/puppet/fileserver.conf <<EOF
[files]
  path /etc/puppetlabs/code/environments/production/files
  allow *
EOF

echo " ===> Installing Puppet Agent"
apt-get install -y puppet-agent
ln -s /opt/puppetlabs/bin/puppet /usr/bin
ln -s /opt/puppetlabs/bin/facter /usr/bin
service puppet start

echo " ===> Installing r10k"
/opt/puppetlabs/puppet/bin/gem install r10k
ln -s /opt/puppetlabs/puppet/bin/r10k /usr/bin

echo " ===> Installing modules"
pushd /etc/puppetlabs/code/environments
rm -rf production
git clone https://github.com/jtopjian/puppet-oatmeal production
pushd production
r10k puppetfile install
r10k puppetfile install
popd
popd

echo " ===> Bootstrapping Puppet Server"
puppet agent -t
puppet agent -t
