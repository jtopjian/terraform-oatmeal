variable "key_name" {
  default = "infra"
}

variable "private_key" {
  default = "~/infrastructure/keys/infra"
}

variable "image_name" {
  default = "Ubuntu 16.04"
}

variable "flavor_name" {
  default = "m1.16c16g"
}

variable "security_groups" {
  type    = "list"
  default = ["AllowAll"]
}

variable "volume_size" {
  default = 100
}

variable "lxd_remote_password" {
  default = "password"
}
