// play - Apparmor play machine
// Copyright (C) 2025 Alexandre Pujol <alexandre@pujol.io>
// SPDX-License-Identifier: GPL-2.0-only

package main

import (
	"github.com/roddhjav/apparmor.d/pkg/paths"
	"github.com/roddhjav/apparmor.d/pkg/prebuild"
	"github.com/roddhjav/apparmor.d/pkg/prebuild/builder"
	"github.com/roddhjav/apparmor.d/pkg/prebuild/cli"
	"github.com/roddhjav/apparmor.d/pkg/prebuild/prepare"
)

func init() {
	// Define the target ABI
	prebuild.ABI = 4

	// Define the tasks applied by default
	prepare.Register(
		"synchronise", // Initialize a new clean apparmor.d build directory
		"merge",       // Merge profiles (from group/, profiles-*-*/) to a unified apparmor.d directory
		"setflags",    // Set flags as definied in dist/flags
		"overwrite",   // Overwrite dummy upstream profiles
	)

	// Build tasks applied by default
	builder.Register(
		"userspace", // Resolve variable in profile attachments
	)

	// Define the dist directory, ie. the location of the overwrite file
	prebuild.DistDir = paths.New(".")

	// Define the flag directory
	prebuild.FlagDir = paths.New(".")

	// Define the apparmor.d paths to build
	sync, _ := prepare.Tasks["synchronise"].(*prepare.Synchronise)
	sync.Paths = []string{"apparmor.d"}
}

func main() {
	cli.Configure()
	cli.Prebuild()
}
