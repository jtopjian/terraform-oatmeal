resource "lxd_container" "glance" {
  depends_on = ["lxd_container.keystone"]

  remote    = "${random_id.name.hex}"
  name      = "glance"
  image     = "ubuntu"
  ephemeral = false

  file {
    source      = "files/cloud-archive.sh"
    target_file = "/root/cloud-archive.sh"
  }

  file {
    source      = "files/puppet-agent.sh"
    target_file = "/root/puppet-agent.sh"
  }

  file {
    source      = "files/add-images.sh"
    target_file = "/root/add-images.sh"
  }

  connection {
    host        = "${openstack_compute_instance_v2.oatmeal.access_ip_v6}"
    user        = "ubuntu"
    private_key = "${file(var.private_key)}"
  }

  provisioner "remote-exec" {
    inline = [
      "lxc exec infra -- mysql -e 'drop database glance' || true",
      "lxc exec infra -- puppet agent -t || true",
      "lxc exec puppet -- puppet cert clean glance.lxd || true",
      "lxc exec glance -- bash /root/cloud-archive.sh",
      "lxc exec glance -- bash /root/puppet-agent.sh",
    ]
  }
}
