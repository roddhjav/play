# play - Apparmor play machine
# Copyright (C) 2025 Alexandre Pujol <alexandre@pujol.io>
# SPDX-License-Identifier: UNLICENSED

build := ".build"
vm := env('HOME') / ".vm"

# Show the help message
default:
	@just --list

# Example:
# just img play play.pujol.io 10G
# just img wazuh wazuh.pujol.xyz 20G
[doc('Build the base VM image')]
img name="play" hostname="play.pujol.io" disk_size="10G":
	packer build -force -only=qemu.ubuntu -var hostname={{hostname}} -var disk_size={{disk_size}} packer/
	mv /tmp/packer/{{hostname}}.qcow2 ~/.vm/{{name}}-ubuntu.qcow2

# Example:
# just vm play play.pujol.io
# just vm wazuh wazuh.pujol.xyz
[doc('Create a the test Play VM')]
vm name="play" hostname="play.pujol.io":
	virt-install \
		--connect qemu:///system \
		--import \
		--name {{hostname}} \
		--boot uefi \
		--ram 2048 \
		--vcpus 4 \
		--disk path={{vm}}/{{name}}-ubuntu.qcow2,format=qcow2,bus=virtio \
		--os-variant ubuntu24.04 \
		--vnc --noautoconsole

# Example:
# just ssh play.pujol.io
# just ssh wazuh.pujol.xyz
[doc('Connect to the test VM')]
ssh hostname="play.pujol.io" user="play":
    @ssh {{user}}@`virsh --quiet --readonly --connect=qemu:///system domifaddr "{{hostname}}" | grep -E -o '([[:digit:]]{1,3}\.){3}[[:digit:]]{1,3}'`

# Example:
# just ansible staging play -t role::core
[doc('Provision the VM image')]
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

# These tests are expected to be run on the test deployment machine
# ssh play-test sh -c 'Project/play && just tests'
[doc('Run the integration tests')]
tests:
	@bats --recursive --timing --print-output-on-failure tests/

[doc('Run the linters')]
lint:
	@ansible-lint ansible/
	@golangci-lint run
	@packer fmt packer/
	@packer validate --syntax-only packer/

[doc('Clean the build directory')]
clean:
	rm -rf {{build}}/
