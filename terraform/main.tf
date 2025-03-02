# play - Apparmor play machine
# Copyright (C) 2025 Alexandre Pujol <alexandre@pujol.io>
# SPDX-License-Identifier: UNLICENSED

# Providers documentation:
#
# Hetzner:
# - https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs
#

terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.50.0"
    }
  }
}

locals {
  pass       = yamldecode(file("../secrets.yml"))
  datacenter = "nbg1-dc3" # Nuremberg 1 DC3
}

provider "hcloud" {
  token = local.pass.hcloud.token
}
