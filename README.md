# Kevin's Dotfiles-Repo Template

Welcome to my dotfiles-repo template. This template is made to get you up and running with your own dotfiles-repo in no time! Simply fork this directory to \[Your Username\]/dotfiles and you are ready to start customizing!




## Customizing your dotfiles

Adding your dotfiles is as simple as copying your own files to the right directories. You may also add directories to be copied to the home-directory.

### Base-Files

These files will be copied onto every machine you run `./install.sh` on, regardless of OS, version or hostname. Simply put your files into `./base/` and they will be copied into the home-directory of the machine the scipt is run on.

### OS-Files

These files will be copied second. They will override all base-files. For usage information see `./os/README.md`.

### Host-Files

These files will be copied last. They will override all base- and OS-files. For usage information see `./host/README.md`.

## Advanced configuration

If you need to perform advanced configuration such as changing files outside of the home-directory or manipulating files without overwriting them, you may want to add custom pre- or post-installation scripts in `./scripts`. For usage information see `./scripts/README.md`.




## Behaviour when encountering existing files and directories

If the script encounters an existing file it will move it to `$INSTALL_DIR/dotfiles_backup/[Current Datetime]/`, if the script encounters an existing directory it will move it to `$INSTALL_DIR/dotfiles_backup/[Current Datetime]/` and merge the files not overwritten back into the directory.

### Example

Lets assume you've got the following directory structures:

```
/home/user
          /.config
                  /somefile
                  /somefile2
          /.somefile3


dotfiles/base
             /.config
                     /somefile
                     /somefile3
             /.somefile3
```

Post-Install this would be:

```
/home/user
          /.config
                  /somefile  (from repo)
                  /somefile2 (original)
                  /somefile3 (from repo)
          /.somefile3        (from repo)
          /dotfiles_backup
                          /[DATE]
                                 /.config
                                         /somefile (original)
                                 /.somefile3       (original)
```




## Execution order

1. Run ./scripts/pre-install.d/*.sh
2. Install base-files
3. Install os-base-files
4. Install os-version-files
5. Install host-files
6. Run ./scripts/post-install.d/*.sh
