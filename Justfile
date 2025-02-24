# play - Apparmor play machine
# Copyright (C) 2025 Alexandre Pujol <alexandre@pujol.io>
# SPDX-License-Identifier: UNLICENSED

build := ".build"

# Show the help message
default:
	@just --list

# Build the base VM image
img name="play" hostname="play.pujol.io" disk_size="10G":
	packer build -force -only=qemu.ubuntu -var hostname={{hostname}} -var disk_size={{disk_size}} packer/
	mv /tmp/packer/{{name}}.qcow2 ~/.vm/{{name}}-ubuntu.qcow2

# Provision the VM image
ansible inventory="staging" playbook="play" *args="":
	ansible-playbook -i ansible/inventory/{{inventory}} ansible/playbooks/{{playbook}}.yml {{args}}

# Build the apparmor profiles
build:
	@go build -o {{build}}/ ./cmd/prebuild
	@./{{build}}/prebuild

# Build the static website
web-buid:
	@cd site && hugo

# Serve the static website
web-serve:
	@cd site && hugo serve

# Run the integration tests
tests:
	@bats --recursive --timing --print-output-on-failure tests/

# Run the linters
lint:
	@golangci-lint run
	@packer fmt packer/
	@packer validate --syntax-only packer/

# Clean the build directory
clean:
	rm -rf {{build}}/
