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
  default     = "~/.libvirt/iso"
}

variable "base_dir" {
  description = "Final packer image output directory"
  type        = string
  default     = "~/.libvirt/base"
}

variable "output" {
  description = "Output build directory"
  type        = string
  default     =  "~/.libvirt/base/packer"
}

variable "firmware" {
  description = "Path to the UEFI firmware"
  type        = string
  default     = "/usr/share/edk2/x64/OVMF.4m.fd"
}

variable "dist" {
  description = "Distribution to target"
  type        = string
  default     = "ubuntu24"
}

variable "DM" {
  description = "Distribution Metadata to use"
  type = map(object({
    img_url      = string
    img_checksum = string
  }))
  default = {
    "ubuntu24" : {
      img_url      = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
      img_checksum = "https://cloud-images.ubuntu.com/noble/current/SHA256SUMS"
    },
    "ubuntu25" : {
      img_url      = "https://cloud-images.ubuntu.com/plucky/current/plucky-server-cloudimg-amd64.img"
      img_checksum = "https://cloud-images.ubuntu.com/plucky/current/SHA256SUMS"
    },
  }
}
