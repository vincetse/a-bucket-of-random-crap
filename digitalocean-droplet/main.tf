provider "digitalocean" {
}

locals {
  image  = "ubuntu-18-04-x64"
  region = "nyc1"
}

################################################################################
data "http" "myip" {
  url = "http://ifconfig.co"
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
  vars     = {
    ubuntu_codename = "bionic"
  }
}

################################################################################
# Firewall
locals {
  inbound_ports = [
    "22",
    "80",
    "443"
  ]
}

resource "digitalocean_firewall" "web" {
  name = "only-ssh-web"

  droplet_ids = [
    digitalocean_droplet.web.id,
  ]

  dynamic "inbound_rule" {
    for_each = local.inbound_ports
    content {
      protocol   = "tcp"
      port_range = inbound_rule.value
      source_addresses = [
        "${chomp(data.http.myip.body)}/32",
      ]
    }
  }

  outbound_rule {
    protocol   = "tcp"
    port_range = "1-65535"
    destination_addresses = [
      "0.0.0.0/0",
      "::/0",
    ]
  }

  outbound_rule {
    protocol   = "udp"
    port_range = "1-65535"
    destination_addresses = [
      "0.0.0.0/0",
      "::/0",
    ]
  }

  outbound_rule {
    protocol = "icmp"
    destination_addresses = [
      "0.0.0.0/0",
      "::/0",
    ]
  }
}
