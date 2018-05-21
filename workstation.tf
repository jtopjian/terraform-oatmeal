resource "lxd_container" "workstation" {
  depends_on = ["lxd_container.puppet"]

  remote    = "${random_id.name.hex}"
  name      = "workstation"
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
    source      = "files/workstation.sh"
    target_file = "/root/workstation.sh"
  }

  connection {
    host        = "${openstack_compute_instance_v2.oatmeal.access_ip_v6}"
    user        = "ubuntu"
    private_key = "${file(var.private_key)}"
  }

  provisioner "remote-exec" {
    inline = [
      "lxc exec puppet -- puppet cert clean infra.lxd || true",
      "lxc exec workstation -- bash /root/cloud-archive.sh",
      "lxc exec workstation -- bash /root/puppet-agent.sh",
      "lxc exec workstation -- bash /root/workstation.sh",
    ]
  }
}
