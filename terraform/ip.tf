# play - Apparmor play machine
# Copyright (C) 2025 Alexandre Pujol <alexandre@pujol.io>
# SPDX-License-Identifier: UNLICENSED

resource "hcloud_primary_ip" "play" {
  name          = "tf-primary-ip-play"
  type          = "ipv4"
  assignee_type = "server"
  datacenter    = local.datacenter
  auto_delete   = false

  labels = {
    "domain" : "play.pujol.io"
  }
}
