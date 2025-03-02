# play - Apparmor play machine
# Copyright (C) 2025 Alexandre Pujol <alexandre@pujol.io>
# SPDX-License-Identifier: UNLICENSED

# Variables definitions

variable "ssh_publickey" {
  description = "Path to the ssh public key"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "base_dir" {
  description = "Packer image output directory on terraform host"
  type        = string
  default     = "~/.libvirt/base"
}

variable "pass" {
  description = "Dictionary of secrets"
  type        = map(any)
  sensitive   = true
  default     = {}
}

