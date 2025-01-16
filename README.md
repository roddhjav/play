[<img src="https://gitlab.com/uploads/-/system/project/avatar/65991964/logo.png" align="right" height="110"/>][project]

# play.pujol.io [![][build]][project]

**Apparmor play machine**

Free root access on an apparmor machine!

To access the Ubuntu based play machine ssh to `play.pujol.io` as root, the password is `apparmor`.

A Play Machine is what is called a system with root as the guest account with only Apparmor to restrict access.

The aim of this is to:
- Demonstrate that necessary security can be provided by Apparmor without any Unix permissions (however it is still recommended that you use Unix permissions as well for real servers).
- Show that root is not everything in modern security.
- Give a demo machine with [apparmor.d](https://github.com/roddhjav/apparmor.d) fully integrated.

[project]: https://gitlab.com/rdhjv/security/play
[build]: https://gitlab.com/rdhjv/security/play/main/pipeline.svg?style=flat-square
