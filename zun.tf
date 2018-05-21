resource "lxd_container" "zun" {
  depends_on = ["lxd_container.keystone"]

  remote    = "${random_id.name.hex}"
  name      = "zun"
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
      "lxc exec infra -- mysql -e 'drop database zun' || true",
      "lxc exec infra -- puppet agent -t || true",
      "lxc exec puppet -- puppet cert clean zun.lxd || true",
      "lxc exec zun -- bash /root/cloud-archive.sh",
      "lxc exec zun -- bash /root/puppet-agent.sh",
    ]
  }
}

resource "lxd_container" "z01" {
  depends_on = ["lxd_container.keystone"]

  remote    = "${random_id.name.hex}"
  name      = "z01"
  image     = "ubuntu"
  ephemeral = false

  config {
    "security.privileged" = "true"
    "raw.lxc"             = "lxc.apparmor.profile=unconfined"
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
      "lxc exec puppet -- puppet cert clean z01.lxd || true",
      "lxc exec z01 -- bash /root/cloud-archive.sh",
      "lxc exec z01 -- bash /root/puppet-agent.sh",
    ]
  }
}
