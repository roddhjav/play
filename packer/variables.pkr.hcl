# play - Apparmor play machine
# Copyright (C) 2025 Alexandre Pujol <alexandre@pujol.io>
# SPDX-License-Identifier: UNLICENSED

# Variables definitions

variable "username" {
  description = "Admin username"
  type        = string
  default     = "play"
}

variable "password" {
  description = "Default admin password (replaced by terraform)"
  type        = string
  default     = "play"
}

variable "ssh_publickey" {
  description = "Path to the ssh public key"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "ssh_privatekey" {
  description = "Path to the ssh private key"
  type        = string
  default     = "~/.ssh/id_ed25519"
}

variable "iso_dir" {
  description = "Original ISO file directory"
  type        = string
  default     = "/home/alex/.libvirt/iso"
}

variable "base_dir" {
  description = "Packer image output directory on terraform host"
  type        = string
  default     = "/home/alex/.libvirt/base"
}

variable "firmware" {
  description = "Path to the UEFI firmware"
  type        = string
  default     = "/usr/share/edk2/x64/OVMF.4m.fd"
}

variable "output" {
  description = "Output build directory"
  type        = string
  default     = "/tmp/packer"
}

variable "hostname" {
  description = "Server hostname"
  type        = string
  default     = "play.pujol.io"
}

variable "release" {
  description = "Distribution metadata to use"
  type = map(object({
    codename = string
    version  = string
  }))
  default = {
    "ubuntu" : {
      codename = "plucky",
      version  = "25.04",
    },
  }
}
