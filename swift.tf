resource "lxd_container" "swift" {
  depends_on = ["lxd_container.keystone"]

  remote    = "${random_id.name.hex}"
  name      = "swift"
  image     = "ubuntu"
  ephemeral = false

  config = {
    "security.privileged" = "true"
    "raw.lxc"             = "lxc.apparmor.profile=unconfined"
  }

  device {
    name = "loop2"
    type = "unix-block"

    properties = {
      path = "/dev/loop2"
    }
  }

  device {
    name = "loop3"
    type = "unix-block"

    properties = {
      path = "/dev/loop3"
    }
  }

  device {
    name = "loop4"
    type = "unix-block"

    properties = {
      path = "/dev/loop4"
    }
  }

  device {
    name = "loop5"
    type = "unix-block"

    properties = {
      path = "/dev/loop5"
    }
  }

  device {
    name = "loop6"
    type = "unix-block"

    properties = {
      path = "/dev/loop6"
    }
  }

  device {
    name = "loop7"
    type = "unix-block"

    properties = {
      path = "/dev/loop7"
    }
  }

  device {
    name = "loop-control"
    type = "unix-char"

    properties = {
      path = "/dev/loop-control"
    }
  }

  file {
    source      = "files/puppet-agent.sh"
    target_file = "/root/puppet-agent.sh"
    mode        = "0750"
  }

  file {
    source      = "files/swift-aio.sh"
    target_file = "/root/swift-aio.sh"
    mode        = "0750"
  }

  connection {
    host        = "${openstack_compute_instance_v2.oatmeal.access_ip_v6}"
    user        = "ubuntu"
    private_key = "${file(var.private_key)}"
  }

  provisioner "remote-exec" {
    inline = [
      "lxc exec puppet -- puppet cert clean swift.lxd || true",
      "lxc exec swift -- bash /root/swift-aio.sh",
      "lxc exec swift -- bash /root/puppet-agent.sh",
    ]
  }
}
