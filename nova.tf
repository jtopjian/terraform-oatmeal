resource "lxd_container" "nova" {
  depends_on = ["lxd_container.neutron"]

  remote    = "${random_id.name.hex}"
  name      = "nova"
  image     = "ubuntu"
  ephemeral = false

  config {
    "security.privileged" = "true"
  }

  file {
    source      = "files/cloud-archive.sh"
    target_file = "/root/cloud-archive.sh"
  }

  file {
    source      = "files/puppet-agent.sh"
    target_file = "/root/puppet-agent.sh"
  }

  file {
    source      = "files/add-flavors.sh"
    target_file = "/root/add-flavors.sh"
  }

  connection {
    host        = "${openstack_compute_instance_v2.oatmeal.access_ip_v6}"
    user        = "ubuntu"
    private_key = "${file(var.private_key)}"
  }

  provisioner "remote-exec" {
    inline = [
      "lxc exec infra -- mysql -e 'drop database nova' || true",
      "lxc exec infra -- mysql -e 'drop database nova_api' || true",
      "lxc exec infra -- mysql -e 'drop database nova_cell0' || true",
      "lxc exec infra -- puppet agent -t || true",
      "lxc exec puppet -- puppet cert clean nova.lxd || true",
      "lxc exec nova -- bash /root/cloud-archive.sh",
      "lxc exec nova -- apt-get install -y nova-api nova-scheduler nova-conductor",
      "lxc exec nova -- service stop nova-api",
      "lxc exec nova -- service stop nova-conductor",
      "lxc exec nova -- service stop nova-scheduler",
      "lxc exec nova -- bash /root/puppet-agent.sh",
      "lxc exec nova -- bash /root/add-flavors.sh",
    ]
  }
}

resource "lxd_container" "c01" {
  depends_on = ["lxd_container.nova"]

  remote    = "${random_id.name.hex}"
  name      = "c01"
  image     = "ubuntu"
  ephemeral = false

  config {
    "security.privileged" = "true"
    "raw.lxc"             = "lxc.apparmor.profile=unconfined"

    #"linux.kernel_modules" = "multipath,dm_multipath"
  }

  device {
    name = "kvm"
    type = "unix-char"

    properties {
      path = "/dev/kvm"
    }
  }

  device {
    name = "control"
    type = "unix-char"

    properties {
      path = "/dev/mapper/control"
    }
  }

  device {
    name = "modules"
    type = "disk"

    properties {
      source = "/lib/modules"
      path   = "/lib/modules"
    }
  }

  file {
    source      = "files/cloud-archive.sh"
    target_file = "/root/cloud-archive.sh"
  }

  file {
    source      = "files/puppet-agent.sh"
    target_file = "/root/puppet-agent.sh"
  }

  connection {
    host        = "${openstack_compute_instance_v2.oatmeal.access_ip_v6}"
    user        = "ubuntu"
    private_key = "${file(var.private_key)}"
  }

  provisioner "remote-exec" {
    inline = [
      "lxc exec puppet -- puppet cert clean c01.lxd || true",
      "lxc exec c01 -- bash /root/cloud-archive.sh",
      "lxc exec c01 -- bash /root/puppet-agent.sh",
      "lxc exec nova -- nova-manage cell_v2 discover_hosts",
    ]
  }
}
