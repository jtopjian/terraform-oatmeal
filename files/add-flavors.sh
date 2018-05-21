#!/bin/bash

cd /root
source openrc

nova flavor-create --ephemeral 0 --swap 0 m1.tiny 1 512 1 1
nova flavor-create --ephemeral 0 --swap 0 m1.small 2 2048 20 1
nova flavor-create --ephemeral 10 --swap 0 m1.acctest 99 512 5 1
nova flavor-create --ephemeral 10 --swap 0 m1.resize 98 512 6 1
