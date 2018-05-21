resource "lxd_container" "infra" {
  depends_on = ["lxd_container.puppet"]

  remote    = "${random_id.name.hex}"
  name      = "infra"
  image     = "ubuntu"
  ephemeral = false

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
      "lxc exec puppet -- puppet cert clean infra.lxd || true",
      "lxc exec infra -- bash /root/puppet-agent.sh",
    ]
  }
}
