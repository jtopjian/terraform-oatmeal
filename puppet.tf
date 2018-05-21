resource "lxd_container" "puppet" {
  depends_on = ["null_resource.provision_lxd"]

  remote    = "${random_id.name.hex}"
  name      = "puppet"
  image     = "ubuntu"
  ephemeral = false

  file {
    source      = "files/puppetserver.sh"
    target_file = "/root/puppetserver.sh"
  }

  connection {
    host        = "${openstack_compute_instance_v2.oatmeal.access_ip_v6}"
    user        = "ubuntu"
    private_key = "${file(var.private_key)}"
  }

  provisioner "remote-exec" {
    inline = [
      "lxc exec puppet -- bash /root/puppetserver.sh",
    ]
  }
}
