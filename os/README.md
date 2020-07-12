# OS-Specific Dotfiles

You can define OS-specific dotfiles in this directory by creating a directory named `[OS-Name]-base` or `[OS-Name]-[OS Version]` if you want to specify the version. In the OS-Name `/` and ` ` get replaced with `_`. If you are not sure which name the install script will use run it on the target machine and look for the line saying `Searching for OS-base-config at ./os/[OS-Name]-base` or the one saying `Searching for OS-version-config at ./os/[OS-Name]-[OS Version]`.

## Examples

`./Debian_GNU_Linux-10` for Debian 10.

`./Debian_GNU_Linux-base` for every Debian.
