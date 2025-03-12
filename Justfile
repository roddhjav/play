# play - Apparmor play machine
# Copyright (C) 2025 Alexandre Pujol <alexandre@pujol.io>
# SPDX-License-Identifier: UNLICENSED

# Integration environment for play
#
# Usage:
#   just
#   just img play.pujol.io 10G
#   just vm play.pujol.io
#   just up play.pujol.io
#   just ssh play.pujol.io
#   just halt play.pujol.io
#   just destroy play.pujol.io
#   just ansible staging play
#   just integration play.pujol.io
#   just web-build
#   just web-serve
#   just lint
#   just clean

build := ".build"
base_dir := home_dir() / ".libvirt/base"
vm := home_dir() / ".vm"
output := base_dir / "packer"
dist := "ubuntu24"
disk_size := "10G"
c := "--connect=qemu:///system"
sshopt := "-i ~/.ssh/id_ed25519.pub -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

[doc('Show this help message')]
default:
	@echo -e "Integration environment helper for play\n"
	@just --list --unsorted
	@echo -e "\nSee https://apparmor.pujol.io/development/vm/ for more information."

[doc('Build the apparmor profiles')]
build:
	@go build -o {{build}}/ ./cmd/prebuild
	@./{{build}}/prebuild

[doc('Build the image')]
img hostname="play.pujol.io" disk_size="10G":
	@mkdir -p {{base_dir}}
	packer build -force \
		-var dist={{dist}} \
		-var hostname={{hostname}} \
		-var disk_size={{disk_size}} \
		-var base_dir={{base_dir}} \
		-var output={{output}} \
		packer/

[doc('Create the machine')]
vm hostname="play.pujol.io":
	@cp -f {{base_dir}}/{{hostname}}.qcow2 {{vm}}/{{hostname}}.qcow2
	@virt-install {{c}} \
		--import \
		--name {{hostname}} \
		--vcpus 6 \
		--ram 3072 \
		--machine q35 \
		--boot uefi \
		--memorybacking source.type=memfd,access.mode=shared \
		--disk path={{vm}}/{{hostname}}.qcow2,format=qcow2,bus=virtio \
		--os-variant "`just get_osinfo {{dist}}`" \
		--graphics spice \
		--audio id=1,type=spice \
		--sound model=ich9 \
		--noautoconsole

[doc('Start a machine')]
up hostname="play.pujol.io":
	@virsh {{c}} start {{hostname}}

[doc('Stops the machine')]
halt hostname="play.pujol.io":
	@virsh {{c}} shutdown {{hostname}}

[doc('Destroy the machine')]
destroy hostname="play.pujol.io":
	@virsh {{c}} destroy {{hostname}} || true
	@virsh {{c}} undefine {{hostname}} --nvram
	@rm -fv {{vm}}/{{hostname}}.qcow2

[doc('Connect to the machine')]
ssh hostname="play.pujol.io":
	@ssh {{sshopt}} play@`just get_ip {{hostname}}`

# just ansible staging play -t role::core
[doc('Provision the machine')]
ansible inventory="staging" playbook="play" *args="":
	ansible-playbook -i ansible/inventory/{{inventory}} ansible/playbooks/{{playbook}}.yml {{args}}

[doc('Run the integration tests on the machine')]
integration hostname="play.pujol.io":
	@ssh {{sshopt}} user@`just get_ip {{hostname}}` \
		bats --recursive --pretty --timing --print-output-on-failure Projects/integration/

[doc('Build the static website')]
web-build:
	@cd site && hugo

[doc('Serve the static website')]
web-serve:
	@cd site && hugo serve

[doc('Deploy the static website to the play machine')]
deploy: web-build
	@rsync --recursive --links --verbose --compress --delete \
		site/public/ deploy@play.pujol.io:/var/www/public/

[doc('Run the linters')]
lint:
	@ansible-lint ansible/
	@golangci-lint run
	@packer fmt packer/
	@packer validate --syntax-only packer/

check:
	@bash ../apparmor.d/tests/check.sh

[doc('Clean the build directories')]
clean:
	rm -rf {{build}}/ site/public/ site/.hugo_build.lock

get_ip hostname:
	@virsh --quiet --readonly {{c}} domifaddr {{hostname}} | \
		head -1 | \
		grep -E -o '([[:digit:]]{1,3}\.){3}[[:digit:]]{1,3}'

get_osinfo dist:
    #!/usr/bin/env python3
    osinfo = {
        "archlinux": "archlinux",
        "debian12": "debian12",
        "debian13": "debian13",
        "ubuntu22": "ubuntu22.04",
        "ubuntu24": "ubuntu24.04",
        "ubuntu25": "ubuntu25.04", 
        "opensuse": "opensusetumbleweed",
    }
    print(osinfo.get("{{dist}}", "{{dist}}"))
