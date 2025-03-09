# play - Apparmor play machine
# Copyright (C) 2025 Alexandre Pujol <alexandre@pujol.io>
# SPDX-License-Identifier: UNLICENSED

output "password_play" {
  description = "Password of the play instance"
  sensitive   = true
  value = random_password.play.result
}

output "password_donn" {
  description = "Password of the donn instance"
  sensitive   = true
  value = random_password.donn.result
}

output "ip_play" {
  description = "Address IP of the play instance"
  sensitive   = false
  value = hcloud_primary_ip.play.ip_address
}

