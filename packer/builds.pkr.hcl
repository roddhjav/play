# play - Apparmor play machine
# Copyright (C) 2025 Alexandre Pujol <alexandre@pujol.io>
# SPDX-License-Identifier: UNLICENSED

build {
  sources = [
    "source.qemu.ubuntu",
  ]

  # Upload system configuration
  provisioner "file" {
    destination = "/tmp/"
    sources = [
      "${path.cwd}/packer/cleanup.sh",
      "${path.cwd}/.pkg/",
    ]
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

      # Install system packages & extensions
      "dpkg --force-confnew --install /tmp/*.deb",

      # Ensure the earlypolicy is recompiled
      "rm -rf /var/cache/apparmor/*",
      "rm -rf /etc/apparmor/earlypolicy/",
      "systemctl reload apparmor.service",

      # Minimize the image
      "bash /tmp/cleanup.sh",
    ]
  }
}
