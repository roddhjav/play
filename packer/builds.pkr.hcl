# play - Apparmor play machine
# Copyright (C) 2025 Alexandre Pujol <alexandre@pujol.io>
# SPDX-License-Identifier: UNLICENSED

source "qemu" "default" {
  disk_image         = true
  iso_url            = var.DM[var.dist].img_url
  iso_checksum       = "file:${var.DM[var.dist].img_checksum}"
  iso_target_path    = pathexpand("${var.iso_dir}/${basename("${var.DM[var.dist].img_url}")}")
  cpu_model          = "host"
  cpus               = var.cpus
  memory             = var.ram
  disk_size          = var.disk_size
  accelerator        = "kvm"
  headless           = true
  ssh_username       = var.username
  ssh_password       = var.password
  ssh_port           = 22
  ssh_wait_timeout   = "1000s"
  disk_compression   = true
  disk_detect_zeroes = "unmap"
  disk_discard       = "unmap"
  output_directory   = pathexpand(var.output)
  vm_name            = "${var.hostname}.qcow2"
  boot_wait          = "10s"
  firmware           = pathexpand(var.firmware)
  shutdown_command   = "echo ${var.password} | sudo -S /sbin/shutdown -hP now"
  cd_label           = "cidata"
  cd_content = {
    "meta-data" = ""
    "user-data" = templatefile("${path.cwd}/packer/cloud-init.yml",
      {
        username = "${var.username}"
        password = "${var.password}"
        ssh_key  = file("${var.ssh_publickey}")
        hostname = "${var.hostname}"
      }
    )
  }
}

build {
  sources = [
    "source.qemu.default",
  ]

  # Upload system configuration
  provisioner "file" {
    destination = "/tmp/"
    sources     = ["${path.cwd}/packer/cleanup.sh"]
  }

  # Full system provisioning
  provisioner "shell" {
    execute_command = "echo '${var.password}' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      # Wait for cloud-init to finish
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for Cloud-Init...'; sleep 20; done",

      # Ensure cloud-init is successful
      "cloud-init status",

      # Remove logs and artifacts so cloud-init can re-run
      "cloud-init clean",

      # Minimize the image
      "bash /tmp/cleanup.sh",
    ]
  }

  post-processor "shell-local" {
    inline = [
      "mv ${var.output}/${var.hostname}.qcow2 ${var.base_dir}/${var.hostname}.qcow2",
    ]
  }
}
