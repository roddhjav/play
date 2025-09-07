# play - Apparmor play machine
# Copyright (C) 2025 Alexandre Pujol <alexandre@pujol.io>
# SPDX-License-Identifier: GPL-2.0-only

# Build settings
build := ".build"

# Admin username
username := "play"

# Path to the ssh key
ssh_keyname := "id_ed25519"
ssh_privatekey := home_dir() / ".ssh/" + ssh_keyname
ssh_publickey := ssh_privatekey + ".pub" 

# SSH options
sshopt := "-i " + ssh_privatekey + " -o IdentitiesOnly=yes -o StrictHostKeyChecking=no"

# Show this help message
help:
	@just --list --unsorted
	@printf "\n%s\n" "See https://apparmor.pujol.io/development/ for more information."

# Build the go programs
[group('build')]
build:
	@go build -o {{build}}/ ./cmd/prebuild

# Prebuild the profiles in enforced mode
[group('build')]
enforce: build
	@./{{build}}/prebuild

# Prebuild the profiles in complain mode
[group('build')]
complain: build
	@./{{build}}/prebuild --complain

# Provision the machine
[group('provision')]
ansible inventory="staging" playbook="play" *args="":
	ansible-playbook -i ansible/inventory/common -i ansible/inventory/{{inventory}} ansible/playbooks/{{playbook}}.yml {{args}}

# Build the static website
[group('web')]
web-build:
	@cd site && hugo

# Serve the static website
[group('web')]
web-serve:
	@cd site && hugo serve

# Deploy the static website to the play machine
[group('web')]
deploy: web-build
	@rsync --recursive --links --verbose --compress --delete \
		site/public/ deploy@play.pujol.io:/var/www/public/

# Run the linters
[group('linter')]
lint:
	@ansible-lint ansible/
	@golangci-lint run

# Run style checks on the profiles
[group('linter')]
check:
    @mkdir -p tests
    @curl -sSL https://raw.githubusercontent.com/roddhjav/apparmor.d/refs/heads/main/tests/check.sh > tests/check.sh
    @curl -sSL https://raw.githubusercontent.com/roddhjav/apparmor.d/refs/heads/main/tests/sbin.list > tests/sbin.list
    @bash tests/check.sh

# Synchronize the integration tests on the play machine
[group('tests')]
tests-sync hostname="play.pujol.io":
	@rsync --recursive --links --verbose --compress --delete \
		tests/ {{username}}@{{hostname}}:~/

# Run the integration tests on the play machine
[group('tests')]
tests-run hostname="play.pujol.io" name="": (tests-sync hostname)
	ssh {{sshopt}} {{username}}@{{hostname}} \
		bats --recursive --pretty --timing --print-output-on-failure \
			/home/{{username}}/tests/{{name}}

# Remove all build artifacts
clean:
	rm -rf {{build}}/ site/public/ site/.hugo_build.lock .hugo_build.lock

