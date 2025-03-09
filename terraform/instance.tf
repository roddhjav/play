# play - Apparmor play machine
# Copyright (C) 2025 Alexandre Pujol <alexandre@pujol.io>
# SPDX-License-Identifier: UNLICENSED

resource "hcloud_server" "play" {
  name        = "tf-preprod-play"
  image       = "ubuntu-24.04"
  datacenter  = local.datacenter
  server_type = "cx22"

  public_net {
    ipv4_enabled = true
    ipv4         = hcloud_primary_ip.play.id
    ipv6_enabled = false
  }

  ssh_keys = [hcloud_ssh_key.alex.id]
  user_data = templatefile("${path.cwd}/cloud-init.yml",
    {
      "username" = "play"
      "hostname" = hcloud_primary_ip.play.labels["domain"]
      "ssh_key"  = file("${var.ssh_publickey}")
      "passwd"   = random_password.play.bcrypt_hash
    }
  )

  firewall_ids = [hcloud_firewall.play.id]
}
