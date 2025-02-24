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

variable "hostname" {
  description = "Server hostname"
  type        = string
  default     = ""
}

variable "cpus" {
  description = "Default CPU of the VM"
  type        = string
  default     = "6"
}

variable "ram" {
  description = "Default RAM of the VM"
  type        = string
  default     = "2048"
}

variable "disk_size" {
  description = "Default image disk size"
  type        = string
  default     = "10G"
}

variable "ssh_publickey" {
  description = "Path to the ssh public key"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
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

variable "release" {
  description = "Distribution metadata to use"
  type = map(object({
    codename = string
    version  = string
  }))
  default = {
    "ubuntu" : {
      codename = "noble",
      version  = "24.04",
    },
  }
}
