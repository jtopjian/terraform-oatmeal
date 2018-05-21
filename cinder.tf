resource "lxd_container" "cinder" {
  depends_on = ["lxd_container.keystone"]

  remote    = "${random_id.name.hex}"
  name      = "cinder"
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

  file {
    source      = "files/nfs.sh"
    target_file = "/root/nfs.sh"
  }

  connection {
    host        = "${openstack_compute_instance_v2.oatmeal.access_ip_v6}"
    user        = "ubuntu"
    private_key = "${file(var.private_key)}"
  }

  provisioner "remote-exec" {
    inline = [
      "lxc exec infra -- mysql -e 'drop database cinder' || true",
      "lxc exec infra -- puppet agent -t || true",
      "lxc exec puppet -- puppet cert clean cinder.lxd || true",
      "lxc exec cinder -- bash /root/cloud-archive.sh",
      "lxc exec cinder -- bash /root/puppet-agent.sh",
      "lxc exec cinder -- bash /root/nfs.sh",
    ]
  }
}
