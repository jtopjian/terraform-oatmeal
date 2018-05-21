resource "random_id" "name" {
  prefix      = "oatmeal-"
  byte_length = 4
}

data "openstack_images_image_v2" "image" {
  name = "${var.image_name}"
}

resource "openstack_compute_instance_v2" "oatmeal" {
  name            = "${random_id.name.hex}"
  image_id        = "${data.openstack_images_image_v2.image.id}"
  flavor_name     = "${var.flavor_name}"
  key_pair        = "${var.key_name}"
  security_groups = "${var.security_groups}"

  block_device {
    uuid                  = "${data.openstack_images_image_v2.image.id}"
    source_type           = "image"
    destination_type      = "local"
    boot_index            = 0
    delete_on_termination = true
  }

  block_device {
    source_type           = "blank"
    destination_type      = "local"
    boot_index            = -1
    guest_format          = "swap"
    delete_on_termination = true
    volume_size           = 4096
  }

  block_device {
    source_type           = "blank"
    destination_type      = "volume"
    volume_size           = 100
    boot_index            = -1
    delete_on_termination = true
  }
}

resource "null_resource" "provision_lxd" {
  connection {
    host        = "${openstack_compute_instance_v2.oatmeal.access_ip_v6}"
    user        = "ubuntu"
    private_key = "${file(var.private_key)}"
  }

  provisioner "remote-exec" {
    scripts = [
      "files/lxd.sh",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "lxc config set core.trust_password \"${var.lxd_remote_password}\"",
    ]
  }

  provisioner "local-exec" {
    command = "rm ~/.config/lxc/servercerts/${random_id.name.hex}.crt || true"
    when    = "destroy"
  }
}
