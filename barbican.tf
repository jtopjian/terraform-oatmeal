resource "lxd_container" "barbican" {
  depends_on = ["lxd_container.keystone"]

  remote    = "${random_id.name.hex}"
  name      = "barbican"
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

  connection {
    host        = "${openstack_compute_instance_v2.oatmeal.access_ip_v6}"
    user        = "ubuntu"
    private_key = "${file(var.private_key)}"
  }

  provisioner "remote-exec" {
    inline = [
      "lxc exec infra -- mysql -e 'drop database barbican' || true",
      "lxc exec infra -- puppet agent -t || true",
      "lxc exec puppet -- puppet cert clean barbican.lxd || true",
      "lxc exec barbican -- bash /root/cloud-archive.sh",
      "lxc exec barbican -- bash /root/puppet-agent.sh",
    ]
  }
}
