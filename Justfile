# play - Apparmor play machine
# Copyright (C) 2025 Alexandre Pujol <alexandre@pujol.io>
# SPDX-License-Identifier: UNLICENSED

DESTDIR := env_var_or_default("DESTDIR", "")
build := ".build"
pkgdest := `pwd` / ".pkg"
apparmord_dir := "../apparmor.d"
src := `pwd` 

# Show the help message
default:
	@just --list


# Build the play image
play: dpkg-build-play dpkg-build-apparmord
	packer build -force -only=qemu.ubuntu -var hostname=play.pujol.io packer/
	mv /tmp/packer/play.pujol.io.qcow2 ~/.vm/play-ubuntu.qcow2

# Build the wazuh image
wazuh: dpkg-build-wazuh dpkg-build-apparmord
	packer build -force -only=qemu.ubuntu -var hostname=w.pujol.xyz -var disk_size=20G packer/
	mv /tmp/packer/w.pujol.xyz.qcow2 ~/.vm/w.pujol.xyz.qcow2

# Build the play distribution package
build:
	@go build -o {{build}}/ ./cmd/prebuild
	@./{{build}}/prebuild --complain

# Install the play package
install:
	#!/usr/bin/env bash
	set -euo pipefail
	user=play

	install -dm0750 "{{DESTDIR}}/root/.config/" "{{DESTDIR}}/root/.config/htop"
	install -dm0750 -o 1000 -g 1000 "{{DESTDIR}}/home/$user/Projects/" "{{DESTDIR}}/home/$user/.config/"

	# Install all files
	mapfile -t root < <(find play -type f -printf "%P\n")
	for file in "${root[@]}"; do
		install -Dm0644 "play/$file" "{{DESTDIR}}/$file"
	done
	mapfile -t profiles < <(find "{{build}}/apparmor.d" -type f -printf "%P\n")
	for file in "${profiles[@]}"; do
		install -Dm0644 "{{build}}/apparmor.d/$file" "{{DESTDIR}}/etc/apparmor.d/$file"
	done

	chown 1000:1000 "{{DESTDIR}}/home/$user/.bash_aliases"
	chown -R 1000:1000 "{{DESTDIR}}/home/$user/.config/"
	chmod 0600 "{{DESTDIR}}/root/thanks-append-only.txt"

# Build the play package in an Ubuntu container
dpkg-build-play: (_docker-dpkg-setup "play") (docker-dpkg-build "play")

# Build the w package in an Ubuntu container
dpkg-build-w: (_docker-dpkg-setup "w") (docker-dpkg-build "w")

# Build and integrate apparmor.d package in an Ubuntu container
dpkg-build-apparmord: (_docker-dpkg-setup "apparmor.d")
	#!/usr/bin/env bash
	set -euo pipefail
	source {{apparmord_dir}}/dists/docker.sh

	# Enable Full System Policy
	# TODO: also set enforce mode (not during dev) -> make full-enforce
	echo -e "\noverride_dh_auto_build:\n\tmake full" >> "$VOLUME/$PKGNAME/debian/rules"
	sed -i '/hotfix/d' "$VOLUME/$PKGNAME/cmd/prebuild/main.go"

	# Only install profile required on servers
	cp {{src}}/fsp.ignore "$VOLUME/$PKGNAME/dists/ignore/main.ignore"

	just docker-dpkg-build $PKGNAME

_docker-dpkg-setup $PKGNAME="":
	#!/usr/bin/env bash
	set -euo pipefail
	[[ "$PKGNAME" == "apparmor.d" ]] && cd {{apparmord_dir}}
	source {{apparmord_dir}}/dists/docker.sh
	dist="ubuntu"
	img="$PREFIX$dist-$PKGNAME"

	sync
	if _exist "$img"; then
		if ! _is_running "$img"; then
			_start "$img"
		fi
	else
		docker pull "$BASEIMAGE/$dist"
		docker run -tid --name "$img" --volume "$VOLUME:$BUILDIR" \
			--env DISTRIBUTION="$dist" "$BASEIMAGE/$dist"
		docker exec "$img" sudo apt-get update -q
		docker exec "$img" sudo apt-get install -y config-package-dev rsync golang-go just
	fi

docker-dpkg-build $PKGNAME="":
	#!/usr/bin/env bash
	set -euo pipefail
	[[ "$PKGNAME" == "apparmor.d" ]] && cd {{apparmord_dir}} 
	source {{apparmord_dir}}/dists/docker.sh
	dist="ubuntu"
	img="$PREFIX$dist-$PKGNAME"

	docker exec --workdir="$BUILDIR/$PKGNAME" "$img" dch --newversion="$VERSION" --urgency=medium --distribution=stable --controlmaint "Release $VERSION"
	docker exec --workdir="$BUILDIR/$PKGNAME" "$img" dpkg-buildpackage -b -d --no-sign
	docker exec --workdir="$BUILDIR/$PKGNAME" "$img" mv ../${PKGNAME}_${VERSION}_amd64.deb .pkg/
	mv "$VOLUME/$PKGNAME/.pkg/${PKGNAME}_${VERSION}_amd64.deb" "{{pkgdest}}"

# Build the static website
web-buid:
	@cd site && hugo

# Serve the static website
web-serve:
	@cd site && hugo serve

# Run the integration tests
tests:
	@bats --timing --print-output-on-failure tests/

# Run the linters
lint:
	@golangci-lint run
	@packer fmt packer/
	@packer validate --syntax-only packer/

# Clean the build directory
clean:
	rm -rf {{build}}/ {{pkgdest}}/
