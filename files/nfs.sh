apt-get install -y nfs-kernel-server

mkdir -p /srv/nfs
echo "/srv/nfs 192.168.244.0/24(rw,sync,no_root_squash,no_subtree_check)" >> /etc/exports
echo "/srv/nfs 127.0.0.0/8(rw,sync,no_root_squash,no_subtree_check)" >> /etc/exports
exportfs -a
