apt-get install -y git vim wget curl make

cd
git clone https://github.com/jtopjian/dotfiles .dotfiles
pushd .dotfiles
bash create.sh
popd

source ~/.bashrc
install_go
source ~/.bashrc

go get -u github.com/terraform-providers/terraform-provider-openstack
pushd go/src/github.com/terraform-providers/terraform-provider-openstack
git remote add jtopjian https://github.com/jtopjian/terraform-provider-openstack
git fetch jtopjian
popd

go get -u github.com/gophercloud/gophercloud
pushd go/src/github.com/gophercloud/gophercloud
go get -u ./...
git remote add jtopjian https://github.com/jtopjian/gophercloud
git fetch jtopjian
popd

go get -u github.com/gophercloud/utils
pushd go/src/github.com/gophercloud/utils
go get -u ./...
git remote add jtopjian https://github.com/jtopjian/gophercloud-utils
git fetch jtopjian
popd

go get -u github.com/kardianos/govendor

cat > /root/demorc <<EOF
export OS_PROJECT_NAME=demo
export OS_PROJECT_DOMAIN_ID=default
export OS_USERNAME=demo
export OS_USER_DOMAIN_NAME=Default
export OS_PASSWORD="password"
export OS_AUTH_URL="http://keystone:5000/v3/"
export OS_AUTH_STRATEGY=keystone
export OS_REGION_NAME=RegionOne
export OS_IDENTITY_API_VERSION=3
EOF

cat > /root/adminrc <<EOF
export OS_PROJECT_NAME=admin
export OS_PROJECT_DOMAIN_ID=default
export OS_USERNAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PASSWORD="password"
export OS_AUTH_URL="http://keystone:5000/v3/"
export OS_AUTH_STRATEGY=keystone
export OS_REGION_NAME=RegionOne
export OS_IDENTITY_API_VERSION=3
EOF

source /root/demorc
_IMAGE_ID=$(openstack image show cirros -c id -f value)
_NETWORK_ID=$(openstack network show private -c id -f value)
_EXTGW_ID=$(openstack network show public -c id -f value)
echo "export OS_IMAGE_NAME=cirros" >> /root/demorc
echo "export OS_IMAGE_NAME=cirros" >> /root/adminrc
echo "export OS_IMAGE_ID=$_IMAGE_ID" >> /root/demorc
echo "export OS_IMAGE_ID=$_IMAGE_ID" >> /root/adminrc
echo "export OS_NETWORK_NAME=private" >> /root/demorc
echo "export OS_NETWORK_NAME=private" >> /root/adminrc
echo "export OS_NETWORK_ID=$_NETWORK_ID" >> /root/demorc
echo "export OS_NETWORK_ID=$_NETWORK_ID" >> /root/adminrc
echo "export OS_EXTGW_ID=$_EXTGW_ID" >> /root/demorc
echo "export OS_EXTGW_ID=$_EXTGW_ID" >> /root/adminrc
echo "export OS_POOL_NAME=public" >> /root/demorc
echo "export OS_POOL_NAME=public" >> /root/adminrc
echo "export OS_FLAVOR_ID=99" >> /root/demorc
echo "export OS_FLAVOR_ID=99" >> /root/adminrc
echo "export OS_FLAVOR_ID_RESIZE=98" >> /root/demorc
echo "export OS_FLAVOR_ID_RESIZE=98" >> /root/adminrc
echo "export OS_FLAVOR_ID=99" >> /root/demorc
