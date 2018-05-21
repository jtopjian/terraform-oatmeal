#!/bin/bash

_int=$(ip a | grep 172 | awk '{print $5}')
iptables -t nat -A POSTROUTING -s 172.24.4.0/24 -o $_int -j MASQUERADE
