cd /root
source /root/openrc
wget http://trunk.rdoproject.org/cirros-0.3.4-x86_64-disk.img
openstack image create --container-format bare --disk-format qcow2 --public cirros --property os_type=linux < cirros-0.3.4-x86_64-disk.img

wget https://download.fedoraproject.org/pub/alt/atomic/stable/Fedora-Atomic-27-20180212.2/CloudImages/x86_64/images/Fedora-Atomic-27-20180212.2.x86_64.qcow2
openstack image create --public --disk-format=qcow2 --container-format=bare --file=Fedora-Atomic-27-20180212.2.x86_64.qcow2 --property os_distro='fedora-atomic' fedora-atomic-latest
