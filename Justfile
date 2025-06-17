# play - Apparmor play machine
# Copyright (C) 2025 Alexandre Pujol <alexandre@pujol.io>
# SPDX-License-Identifier: GPL-2.0-only

build := ".build"

[doc('Show this help message')]
help:
	@just --list --unsorted
	@echo -e "\nSee https://apparmor.pujol.io/development/ for more information."

[group('build')]
[doc('Build the go programs')]
build:
	@go build -o {{build}}/ ./cmd/prebuild

[group('build')]
[doc('Prebuild the profiles in enforced mode')]
enforce: build
	@./{{build}}/prebuild

[group('build')]
[doc('Prebuild the profiles in complain mode')]
complain: build
	@./{{build}}/prebuild --complain

# First provision:
# just ansible staging play -t role::apparmor-profiles --extra-vars \"apparmor_profiles__local_build_cmd=\'just complain\'\"
# just ansible staging play
[group('provision')]
[doc('Provision the machine')]
ansible inventory="staging" playbook="play" *args="":
	ansible-playbook -i ansible/inventory/common -i ansible/inventory/{{inventory}} ansible/playbooks/{{playbook}}.yml {{args}}

[group('web')]
[doc('Build the static website')]
web-build:
	@cd site && hugo

[group('web')]
[doc('Serve the static website')]
web-serve:
	@cd site && hugo serve

[group('web')]
[doc('Deploy the static website to the play machine')]
deploy: web-build
	@rsync --recursive --links --verbose --compress --delete \
		site/public/ deploy@play.pujol.io:/var/www/public/

[group('linter')]
[doc('Run the linters')]
lint:
	@ansible-lint ansible/
	@golangci-lint run

[group('linter')]
[doc('Run style checks on the profiles')]
check:
	@bash ../apparmor.d/tests/check.sh

[group('tests')]
[doc('Run the integration tests on the machine')]
integration hostname="play.pujol.io":
	@ssh play@{{hostname}} \
		bats --recursive --pretty --timing --print-output-on-failure tests

[group('tests')]
[doc('Copy the tests & unshare the project from the VM')]
integration-init hostname="play.pujol.io":
	@rsync --recursive --links --verbose --compress --delete \
		tests/ play@{{hostname}}:~/

[doc('Clean the build directories')]
clean:
	rm -rf {{build}}/ site/public/ site/.hugo_build.lock .hugo_build.lock

