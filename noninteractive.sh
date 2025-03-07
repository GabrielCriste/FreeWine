#!/bin/sh

ROOTFS_DIR=$(pwd)
export PATH=$PATH:~/.local/usr/bin
max_retries=50
timeout=1
ARCH=$(uname -m)

if [ "$ARCH" = "x86_64" ]; then
  ARCH_ALT=amd64
elif [ "$ARCH" = "aarch64" ]; then
  ARCH_ALT=arm64
else
  printf "Unsupported CPU architecture: ${ARCH}"
  exit 1
fi

if [ ! -e $ROOTFS_DIR/.installed ]; then
  echo "#######################################################################################"
  echo "#"
  echo "#                                      FreeWine INSTALLER"
  echo "#"
  echo "#                           Copyright (C) 2024, GabrielCriste/FreeWine"
  echo "#"
  echo "#"
  echo "#######################################################################################"

  install_wine=YES
fi

case $install_wine in
  [yY][eE][sS])
    # Baixar o Wine a partir do repositório FreeWine
    echo "Downloading Wine..."
    wget --tries=$max_retries --timeout=$timeout --no-hsts -O /tmp/wine.tar.xz \
      "https://github.com/GabrielCriste/FreeWine/releases/download/latest/wine-${ARCH_ALT}.tar.xz"

    # Extrair o Wine
    echo "Extracting Wine..."
    tar -xf /tmp/wine.tar.xz -C $ROOTFS_DIR
    ;;
  *)
    echo "Skipping Wine installation."
    ;;
esac

if [ ! -e $ROOTFS_DIR/.installed ]; then
  mkdir $ROOTFS_DIR/usr/local/bin -p

  # Baixar o proot (opcional, se ainda quiser usar o proot)
  wget --tries=$max_retries --timeout=$timeout --no-hsts -O $ROOTFS_DIR/usr/local/bin/proot \
    "https://raw.githubusercontent.com/foxytouxxx/freeroot/main/proot-${ARCH}"

  while [ ! -s "$ROOTFS_DIR/usr/local/bin/proot" ]; do
    rm $ROOTFS_DIR/usr/local/bin/proot -rf
    wget --tries=$max_retries --timeout=$timeout --no-hsts -O $ROOTFS_DIR/usr/local/bin/proot \
      "https://raw.githubusercontent.com/foxytouxxx/freeroot/main/proot-${ARCH}"

    if [ -s "$ROOTFS_DIR/usr/local/bin/proot" ]; then
      chmod 755 $ROOTFS_DIR/usr/local/bin/proot
      break
    fi

    chmod 755 $ROOTFS_DIR/usr/local/bin/proot
    sleep 1
  done

  chmod 755 $ROOTFS_DIR/usr/local/bin/proot
fi

if [ ! -e $ROOTFS_DIR/.installed ]; then
  printf "nameserver 1.1.1.1\nnameserver 1.0.0.1" > ${ROOTFS_DIR}/etc/resolv.conf
  rm -rf /tmp/wine.tar.xz /tmp/sbin
  touch $ROOTFS_DIR/.installed
fi

CYAN='\e[0;36m'
WHITE='\e[0;37m'

RESET_COLOR='\e[0m'

display_gg() {
  echo -e "${WHITE}___________________________________________________${RESET_COLOR}"
  echo -e ""
  echo -e "           ${CYAN}-----> Mission Completed ! <----${RESET_COLOR}"
  echo -e ""
  echo -e "${WHITE}___________________________________________________${RESET_COLOR}"
}

clear
display_gg

# Mensagem final
echo "Wine installation completed!"
echo "You can now run Wine using the following command:"
echo "$ROOTFS_DIR/usr/local/bin/proot --rootfs=\"${ROOTFS_DIR}\" -0 -w \"/root\" -b /dev -b /sys -b /proc -b /etc/resolv.conf --kill-on-exit $ROOTFS_DIR/usr/local/bin/wine64 --version"
