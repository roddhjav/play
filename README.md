[<img src="https://gitlab.com/uploads/-/system/project/avatar/65991964/logo.png" align="right" height="110"/>][project]

# play.pujol.io [![][build]][project] [![][matrix]][matrix-link] [![][play]][play-link]

**AppArmor play machine**

Free root access on an AppArmor machine!

A Play Machine is what is called a system with root as the guest account with only AppArmor to restrict access.

To access the Ubuntu based play machine ssh to `play.pujol.io` as root, the password is `apparmor`.

The aim of this is to:
- Demonstrate that necessary security can be provided by AppArmor without any Unix permissions (however it is still recommended that you use Unix permissions as well for real servers).
- Show that root is not everything in modern security.
- Give a demo machine with [apparmor.d](https://github.com/roddhjav/apparmor.d) fully integrated.

## Requirements

**System requirements**

* A fresh VM with Ubuntu 24.04

**Local dependencies**

* Just
* Ansible
* Go >= 1.23
* Docker (to build the `apparmor.d` package)
* The `apparmor.d` project must be available under the `../apparmor.d` path.
* Hugo (to build the website)

## Deploy

To build the profiles, and install the play machine, run the following command:
```sh
just ansible staging play
```

If you only want to provision the apparmor-profiles, you can run:
```sh
just ansible production play -t role::apparmor-profiles
```

> [!NOTE]  
> The first provision is a bit tricky: you may have to force rebooting the VM manually

Then, you can deploy the static website with:
```sh
just deploy
```

[project]: https://gitlab.com/roddhjav/play
[build]: https://gitlab.com/roddhjav/play/badges/main/pipeline.svg?style=flat-square
[matrix]: https://img.shields.io/badge/Matrix-%23apparmor.d-blue?style=flat-square&logo=matrix
[matrix-link]: https://matrix.to/#/#apparmor.d:matrix.org
[play]: https://img.shields.io/badge/Live_Demo-play.pujol.io-blue?style=flat-square
[play-link]: https://play.pujol.io
