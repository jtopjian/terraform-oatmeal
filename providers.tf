provider "openstack" {}

provider "lxd" {
  generate_client_certificates = true
  accept_remote_certificate    = true

  lxd_remote {
    name     = "${random_id.name.hex}"
    scheme   = "https"
    address  = "${openstack_compute_instance_v2.oatmeal.access_ip_v6}"
    password = "${var.lxd_remote_password}"
    default  = true
  }
}
