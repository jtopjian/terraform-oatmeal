# Oatmeal

OpenStack Acceptance Testing meal-something something

This repository contains Terraform configurations to do the following:

1. Create an OpenStack instance
2. Install LXD on it
3. Create an LXD container which runs Puppet Server
4. Create an LXD container to host MySQL, RabbitMQ, memcached, etc
5. Create an LXD container to act as a workstation
6. Create LXD containers for the following OpenStack Services:
   - Barbican
   - Cinder
   - Glance
   - Heat
   - Keystone
   - Magnum
   - Neutron
   - Nova
   - Senlin
   - Swift
   - Zaqar
   - Zun

The Puppet repository which provisions all of the above can be found
[here](https://github.com/jtopjian/puppet-oatmeal).

This repository is mainly for personal purposes, but it's always possible
others will find it useful.

# Requirements

Terraform is required. All Terraform plugins will be downloaded when you
run `terraform init` _except_ for the LXD provider. You need to download
that from [here](https://github.com/sl1pm4t/terraform-provider-lxd).
