provider "digitalocean" {
}

locals {
  image  = "ubuntu-18-04-x64"
  region = "nyc1"
}

################################################################################
resource "digitalocean_droplet" "web" {
  image     = local.image
  name      = "web-1"
  region    = local.region
  size      = "s-1vcpu-1gb"
  ipv6      = true
  user_data = data.template_file.user_data.rendered
}

data "template_file" "user_data" {
  template = file("${path.module}/user-data.tpl")
  vars     = {}
}
