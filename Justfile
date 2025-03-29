# play - Apparmor play machine
# Copyright (C) 2025 Alexandre Pujol <alexandre@pujol.io>
# SPDX-License-Identifier: UNLICENSED

build := ".build"

[doc('Show this help message')]
default:
	@echo -e "Integration environment helper for play\n"
	@just --list --unsorted
	@echo -e "\nSee https://apparmor.pujol.io/development/vm/ for more information."

[doc('Build the apparmor profiles')]
build:
	@go build -o {{build}}/ ./cmd/prebuild
	@./{{build}}/prebuild

# just ansible staging play -t role::core
[doc('Provision the machine')]
ansible inventory="staging" playbook="play" *args="":
	ansible-playbook -i ansible/inventory/{{inventory}} ansible/playbooks/{{playbook}}.yml {{args}}

# [doc('Run the integration tests on the machine')]
# integration hostname="play.pujol.io":
# 	@ssh {{sshopt}} user@`just get_ip {{hostname}}` \
# 		bats --recursive --pretty --timing --print-output-on-failure Projects/integration/

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

check:
	@bash ../apparmor.d/tests/check.sh

[doc('Clean the build directories')]
clean:
	rm -rf {{build}}/ site/public/ site/.hugo_build.lock

