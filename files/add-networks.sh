source /root/openrc
neutron net-create --shared --provider:physical_network provider --provider:network_type flat public
neutron net-update public --router:external
neutron subnet-create --name public --gateway 172.24.4.1 --dns-nameserver 8.8.4.4 public 172.24.4.0/24

openstack network create --share private
openstack subnet create --network private --subnet-range 10.0.0.0/24 --dns-nameserver 192.168.244.1 private

openstack router create main
openstack router set --external-gateway public main
openstack router add subnet main private
