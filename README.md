[<img src="https://gitlab.com/uploads/-/system/project/avatar/65991964/logo.png" align="right" height="110"/>][project]

# play.pujol.io [![][build]][project]

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

**Local dependency**

* Ansible
* Go >= 1.21
* Hugo
* Just
* The `apparmor.d` project must be available under the `../apparmor.d` path.

## Deploy

To build the profiles, and install the play machine, run the following command:
```sh
just ansible
```

Then, you can deploy the static website with:
```sh
just deploy
```


[project]: https://gitlab.com/rdhjv/security/play
[build]: https://gitlab.com/rdhjv/security/play/main/pipeline.svg?style=flat-square
