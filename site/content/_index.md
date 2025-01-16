
## Free root access on an Apparmor machine!

A Play Machine is what is called a system with root as the guest account with only Apparmor to restrict access.

To access my Ubuntu 24.04 play machine ssh to `play.pujol.io` as root, the password is `apparmor`. To not give me your [own public SSH keys], connect without public keys: `ssh -o PubkeyAuthentication=no root@play.pujol.io`

The aim of this is to:
- Demonstrate that necessary security can be provided by Apparmor without any Unix permissions (however it is still recommended that you use Unix permissions as well for real servers).
- Show that root is not everything in modern security.
- Give a demo machine with [apparmor.d](https://github.com/roddhjav/apparmor.d) fully integrated.

This server is running the [apparmor.d](https://github.com/roddhjav/apparmor.d) project with the [Full System Policies (FSP)](https://apparmor.pujol.io/full-system-policy/) mode enabled and [enforced](https://apparmor.pujol.io/enforce/). Some profiles that only make sense in such a system have been made on purpose.

## Discuss

- Matrix channel available on https://matrix.to/#/#apparmor.d:matrix.org
- Github discussion on: https://github.com/roddhjav/apparmor.d/discussions/619
- If you find a security issue, please report it privately at security@pujol.io

## Rules

Although you get root access to this machine, in most jurisdictions it would be considered a crime to not comply with the present rules:

- Any kind of DOS is out of scope

## FAQ

#### Is it a completely useless and stripped down machine?

No. This is not a fake machine, root is not a fake account, it is serving this very own page using Caddy, that also handles automatic SSL certificate with Let's encrypt...

#### Do you have anything else than Apparmor to secure this machine?

No.

#### Are you stupid or do you really know what you are doing?

Yes. It should be secure. If it is not, it is a nice way to learn how to improve it.

#### What can I do

There is no harm in letting you see dmesg/journalctl as well as the apparmor profiles in use. Security by obscurity isn’t much good anyway. For a serious server you would probably deny dmesg access, but this is a play machine. One of the purposes of the machine is to teach people about Apparmor, and you can learn a lot from the dmesg output.

This machine is intentionally more permissive than some other play machines. I let you see the policy files, so you can learn how to configure a machine in this way. You can use Pyhton and GCC.

#### Can I overwrite the MAC policies?

To administer Apparmor policies, you need the `mac_admin` capability as well as write access to a few files **or** executable access to a program that has the capability.

#### How can I see Apparmor's confinement?

Run any of the following to see the profiles in use:
- `p` (alias for `ps auxZ`)
- `htop`
- `aa-status`

The profiles are all available in `/etc/apparmor.d`

#### Is it a honeypot?

No.


{{< alert "circle-info" >}}
**ACK** It is a 2025 and Apparmor version of [Russell Coker's SELinux play machine](https://doc.coker.com.au/computers/se-linux-play-machine/).
{{< /alert >}}
