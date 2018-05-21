resource "lxd_container" "neutron" {
  depends_on = ["lxd_container.keystone"]

  remote    = "${random_id.name.hex}"
  name      = "neutron"
  image     = "ubuntu"
  ephemeral = false

  config {
    "security.privileged" = "true"
    "raw.lxc"             = "lxc.apparmor.profile=unconfined"
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
    source      = "files/add-networks.sh"
    target_file = "/root/add-networks.sh"
  }

  file {
    source      = "files/neutron-nat.sh"
    target_file = "/root/neutron-nat.sh"
  }

  connection {
    host        = "${openstack_compute_instance_v2.oatmeal.access_ip_v6}"
    user        = "ubuntu"
    private_key = "${file(var.private_key)}"
  }

  provisioner "remote-exec" {
    inline = [
      "lxc exec infra -- mysql -e 'drop database neutron' || true",
      "lxc exec infra -- puppet agent -t || true",
      "lxc exec puppet -- puppet cert clean neutron.lxd || true",
      "lxc exec neutron -- bash /root/cloud-archive.sh",
      "lxc exec neutron -- bash /root/puppet-agent.sh",
      "lxc exec neutron -- bash /root/add-networks.sh",
    ]
  }
}
