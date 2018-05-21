#!/bin/bash

apt-get install -y ubuntu-cloud-keyring

cat > /etc/apt/sources.list.d/cloudarchive-queens.list <<EOF
deb http://ubuntu-cloud.archive.canonical.com/ubuntu xenial-updates/queens main
EOF

apt-get update -qq
