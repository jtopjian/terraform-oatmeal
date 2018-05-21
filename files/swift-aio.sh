#!/bin/bash
set -e

LIBERASURECODE_RELEASE="1.4.0"
LIBERASURECODE_DIR="/opt/liberasurecode"
SWIFT_USER="swift"
SWIFTCLIENT_RELEASE="stable/queens"
SWIFT_RELEASE="stable/queens"

apt-get update -qq

apt-get install -y build-essential autoconf automake libtool curl gcc memcached rsync sqlite3 xfsprogs git-core libffi-dev python-setuptools libssl-dev python-dev python-pip

pushd /opt
git clone https://github.com/openstack/liberasurecode.git
pushd $LIBERASURECODE_DIR
git checkout ${LIBERASURECODE_RELEASE}
./autogen.sh
./configure
make
make install
ldconfig
popd
popd

#pip install pip setuptools ndg-httpsclient --upgrade

useradd -m -d /var/lib/swift -s /bin/bash ${SWIFT_USER}
adduser ${SWIFT_USER} sudo
adduser ${SWIFT_USER} adm
echo "${SWIFT_USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/swift

cat > /etc/rc.local <<EOF
#!/bin/bash
mkdir -p /var/cache/swift /var/cache/swift2 /var/cache/swift3 /var/cache/swift4
chown root:root /var/cache/swift*
mkdir -p /var/run/swift
chown root:root /var/run/swift

startmain

exit 0
EOF

chmod +x /etc/rc.local

git clone https://github.com/openstack/python-swiftclient.git
pushd python-swiftclient
git checkout ${SWIFTCLIENT_RELEASE}
pip install -r requirements.txt
python setup.py develop
popd

git clone https://github.com/openstack/swift.git
pushd swift
git checkout ${SWIFT_RELEASE}
pip install -r requirements.txt
python setup.py develop
popd

pip install keystonemiddleware

cp /root/swift/doc/saio/rsyncd.conf /etc/
sed -i -e "s/<your-user-name>/${SWIFT_USER}/" /etc/rsyncd.conf
sed -i -e "/^RSYNC_ENABLE.*/ s/^/#/" /etc/default/rsync
sed -i -e "/^#RSYNC_ENABLE.*/a RSYNC_ENABLE=true" /etc/default/rsync

mkdir -p /etc/rsyslog.d
cp /root/swift/doc/saio/rsyslog.d/10-swift.conf /etc/rsyslog.d/
sed -i -e "s/\$PrivDropToGroup.*/\$PrivDropToGroup adm/" /etc/rsyslog.conf
mkdir -p /var/log/swift
chown -R syslog.adm /var/log/swift
chmod -R g+w /var/log/swift

rm -rf /etc/swift
pushd /root/swift/doc
cp -r saio/swift /etc/swift
popd
chown -R ${SWIFT_USER}:${SWIFT_USER} /etc/swift
find /etc/swift/ -name \*.conf | xargs sudo sed -i "s/<your-user-name>/${SWIFT_USER}/"
grep changeme /etc/swift/*.conf | cut -d ':' -f1 | uniq | xargs sudo sed -i "s/changeme/$(openssl rand -hex 16)/"
sed -i -e 's/^bind_ip =.*$/bind_ip = 0.0.0.0/' /etc/swift/proxy-server.conf

pushd /root/swift/doc
cp saio/bin/* /usr/local/bin
popd

sed -i -e '/^find \/var\/cache\/swift/,$d' /usr/local/bin/resetswift
echo 'if [ $(sudo find /var/cache -type d -name "swift*" 2>/dev/null | wc -l ) != "0" ] ; then' >> /usr/local/bin/resetswift
echo '    sudo find /var/cache/swift* -type f -name *.recon -exec rm -f {} \;' >> /usr/local/bin/resetswift
echo 'fi' >> /usr/local/bin/resetswift
echo 'sudo /etc/init.d/rsyslog restart' >> /usr/local/bin/resetswift
echo 'sudo /etc/init.d/memcached restart' >> /usr/local/bin/resetswift

chown ${SWIFT_USER}.${SWIFT_USER} /etc/swift/proxy-server.conf

mkdir -p /var/cache/swift
chown ${SWIFT_USER}.${SWIFT_USER} /var/cache/swift
mkdir -p /var/cache/swift2
chown ${SWIFT_USER}.${SWIFT_USER} /var/cache/swift2
mkdir -p /var/cache/swift3
chown ${SWIFT_USER}.${SWIFT_USER} /var/cache/swift3
mkdir -p /var/cache/swift4
chown ${SWIFT_USER}.${SWIFT_USER} /var/cache/swift4

SAIO_BLOCK_DEVICE="/srv/swift-disk"

# Defines the file system type for the SAIO volume
FS_TYPE=${FS_TYPE:-"xfs"}

# Initialize SAIO
echo ""
echo "==================================================="
echo "Initializing Swift All-In-One"
echo "==================================================="
echo ""

# Using a loopback device for storage
echo "Creating loopback device of 1GB"
truncate -s 1GB ${SAIO_BLOCK_DEVICE}
mkfs.${FS_TYPE} -f ${SAIO_BLOCK_DEVICE}
echo ""

# Edit /etc/fstab and add:
echo "Updating /etc/fstab"
echo "${SAIO_BLOCK_DEVICE} /mnt/sdb1 ${FS_TYPE} loop,noatime,nodiratime,nobarrier,logbufs=8 0 0"  | tee --append /etc/fstab
echo ""

# Create the mount point and the individualized links:
echo "Create the mount point and the individualized links"
mkdir -p /mnt/sdb1
mount /mnt/sdb1
mkdir -p /mnt/sdb1/1 /mnt/sdb1/2 /mnt/sdb1/3 /mnt/sdb1/4
chown ${SWIFT_USER}:${SWIFT_USER} /mnt/sdb1/*
for x in {1..4}; do
    ln -s /mnt/sdb1/$x /srv/$x
done
mkdir -p /srv/1/node/sdb1 /srv/1/node/sdb5 \
         /srv/2/node/sdb2 /srv/2/node/sdb6 \
         /srv/3/node/sdb3 /srv/3/node/sdb7 \
         /srv/4/node/sdb4 /srv/4/node/sdb8 \
         /var/run/swift
chown -R ${SWIFT_USER}:${SWIFT_USER} /var/run/swift
for x in {1..4}; do
    chown -R ${SWIFT_USER}:${SWIFT_USER} /srv/$x/
done
echo ""

echo "Starting rsync, memcached, and rsyslog services"
## Start rsync
/etc/init.d/rsync start

## Start memcached
/etc/init.d/memcached start

## Restart rsyslog
/etc/init.d/rsyslog restart
echo ""

## Construct the initial rings using the provided script ##
echo "---------------------------------------------------"
echo "Constructing rings..."
echo "---------------------------------------------------"
remakerings
echo "done"
echo ""

chown ${SWIFT_USER}.${SWIFT_USER} /etc/swift
