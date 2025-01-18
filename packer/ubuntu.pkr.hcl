# play - Apparmor play machine
# Copyright (C) 2025 Alexandre Pujol <alexandre@pujol.io>
# SPDX-License-Identifier: UNLICENSED

source "qemu" "ubuntu" {
  disk_image         = true
  iso_url            = "https://cloud-images.ubuntu.com/${var.release.ubuntu.codename}/current/${var.release.ubuntu.codename}-server-cloudimg-amd64.img"
  iso_checksum       = "file:https://cloud-images.ubuntu.com/${var.release.ubuntu.codename}/current/SHA256SUMS"
  iso_target_path    = "${var.iso_dir}/ubuntu-${var.release.ubuntu.codename}-cloudimg-amd64.img"
  cpus               = 6
  memory             = 2048
  disk_size          = "10G"
  accelerator        = "kvm"
  headless           = true
  ssh_username       = var.username
  ssh_password       = var.password
  ssh_port           = 22
  ssh_wait_timeout   = "1000s"
  disk_compression   = true
  disk_detect_zeroes = "unmap"
  disk_discard       = "unmap"
  output_directory   = "${var.output}/"
  vm_name            = "${var.hostname}.qcow2"
  boot_wait          = "10s"
  firmware           = var.firmware
  shutdown_command   = "echo ${var.password} | sudo -S /sbin/shutdown -hP now"
  cd_label           = "cidata"
  cd_content = {
    "meta-data" = ""
    "user-data" = templatefile("${path.cwd}/packer/${split(".", var.hostname)[0]}-${source.name}.yml",
      {
        username = "${var.username}"
        password = "${var.password}"
        ssh_key  = file("${var.ssh_publickey}")
        hostname = "${var.hostname}"
      }
    )
  }
}
