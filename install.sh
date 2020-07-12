#!/usr/bin/env bash

###########################################
#            dotfile-installer            #
# by Kevin Kandlbinder <kevin@kevink.dev> #
#     https://github.com/Unkn0wnCat/      #
###########################################

# Define parameters.

INSTALL_DIR=$HOME/Projects/dotfiles/testhome

BACKUP_DIR_BASE=$INSTALL_DIR/dotfiles_backup

BACKUP_DIR=$BACKUP_DIR_BASE/$(date +"%Y-%m-%d_%H-%M-%S")

# Figure out OS and OS-Version.

if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    OS=$(lsb_release -si)
    VER=$(lsb_release -sr)
elif [ -f /etc/lsb-release ]; then
    # For some versions of Debian/Ubuntu without lsb_release command
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    OS=Debian
    VER=$(cat /etc/debian_version)
elif [ -f /etc/SuSe-release ]; then
    # Older SuSE/etc.
    ...
elif [ -f /etc/redhat-release ]; then
    # Older Red Hat, CentOS, etc.
    ...
else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    OS=$(uname -s)
    VER=$(uname -r)
fi

OS=${OS/\//_}
OS=${OS/ /_}

VER=${VER/\//_}
VER=${VER/ /_}

# Parse commandline-switches.

for i in "$@"
do
case $i in
    --symlink)
    SYMLINK=Yes
    ;;
    *)

    ;;
esac
done

# Define functions.

remove_dot_and_dotdot_dirs()
{
  sed \
    -e 's/^[.]\{1,2\}\x00//' \
    -e 's/\x00[.]\{1,2\}\x00/\x00/g'
}

remove_leading_dotslash() 
{
  sed \
    -e 's/^[.]\///' \
    -e 's/\x00[.]\//\x00/g'
}

install_dotfile () 
{
  local FILE=$1
  echo " Installing $FILE..."

  if [ -a "$INSTALL_DIR/$FILE" ]; then
    if [ -d "$INSTALL_DIR/$FILE" ]; then
      local DIR_BACKED_UP=Yes
    fi

    if [ -a "$BACKUP_DIR/$FILE" ]; then
      
      if [ -d "$INSTALL_DIR/$FILE" ]; then
        echo "  Overwrite-merging directory $file..."
      else
        echo "  Overwriting previously installed file $FILE..."
        rm -r $INSTALL_DIR/$FILE
      fi
    else
      echo "  $FILE exists, backing up..."
      mkdir -p $BACKUP_DIR
      mv $INSTALL_DIR/$FILE $BACKUP_DIR
    fi
  fi

  if [ "$SYMLINK" == Yes ]; then
    ln -s $(realpath $FILE) $INSTALL_DIR/$FILE
  else
    cp -f -r $FILE $INSTALL_DIR
  fi

  if [ "$DIR_BACKED_UP" == Yes ]; then
    echo "  Merging with old directory..."
    cp -n -r $BACKUP_DIR/$FILE $INSTALL_DIR
  fi
}

install_directory () 
{
  
  local DIRECTORY=$1
  
  pushd $DIRECTORY > /dev/null
 
  find . -maxdepth 1 -print0 |
    sort -z |
    remove_dot_and_dotdot_dirs |
    remove_leading_dotslash |
    while read -r -d "" filename
    do
      install_dotfile $filename
    done

  popd > /dev/null
}


# Execute pre-install-scripts.

for f in ./scripts/pre-install.d/*.sh; do
  bash "$f" -H 
done

# Install dotfiles.

## Install base-files.

echo "Installing base..."
install_directory ./base

## Install os-configs.

echo "Searching for OS-base-config at ./os/$OS-base"

if [ -d "./os/$OS-base" ]; then
  echo "Installing OS-base-config..."
  install_directory ./os/$OS-base
else 
  echo "No OS-base-config found. Skipping."
fi

echo "Searching for OS-version-config at ./os/$OS-$VER"

if [ -d "./os/$OS-$VER" ]; then
  echo "Installing OS-version-config..."
  install_directory ./os/$OS-$VER
else 
  echo "No OS-version-config found. Skipping."
fi

## Install host-config.

echo "Searching for host-config at ./host/$(hostname)"

if [ -d "./host/$(hostname)" ]; then
  echo "Installing host-config..."
  install_directory ./host/$(hostname)
else 
  echo "No host-config found. Skipping."
fi

# Execute post-install-scripts.

for f in ./scripts/post-install.d/*.sh; do
  bash "$f" -H 
done

# Done!

exit 0
