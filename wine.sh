#!/bin/sh

ROOTFS_DIR=$(pwd)
export PATH=$PATH:~/.local/usr/bin
max_retries=50
timeout=1
ARCH=$(uname -m)

# Definir a arquitetura baseada no sistema
if [ "$ARCH" = "x86_64" ]; then
  ARCH_ALT=amd64
elif [ "$ARCH" = "aarch64" ]; then
  ARCH_ALT=arm64
else
  printf "Unsupported CPU architecture: ${ARCH}"
  exit 1
fi

# Verificar se o Wine já foi instalado, caso contrário, instalar
if [ ! -e $ROOTFS_DIR/.installed ]; then
  echo "#######################################################################################"
  echo "#"
  echo "#                                      Wine INSTALLER"
  echo "#"
  echo "#                           Copyright (C) 2024, Wine.sh"
  echo "#"
  echo "#"
  echo "#######################################################################################"

  read -p "Do you want to install Wine? (YES/no): " install_wine
fi

case $install_wine in
  [yY][eE][sS])
    # Baixar e descompactar o Wine
    if [ -f "wine-10.2-amd64.tar.xz" ]; then
      tar -xf wine-10.2-amd64.tar.xz -C $ROOTFS_DIR
    elif [ -f "wine-10.2-staging-amd64-wow64.tar.xz" ]; then
      tar -xf wine-10.2-staging-amd64-wow64.tar.xz -C $ROOTFS_DIR
    else
      echo "Nenhum arquivo Wine encontrado para extração."
      exit 1
    fi
    ;;
  *)
    echo "Skipping Wine installation."
    ;;
esac

# Verificar se o Wine foi extraído corretamente
if [ ! -e $ROOTFS_DIR/.installed ]; then
  chmod -R 755 $ROOTFS_DIR
  touch $ROOTFS_DIR/.installed
fi

CYAN='\e[0;36m'
WHITE='\e[0;37m'

RESET_COLOR='\e[0m'

# Função para exibir a mensagem de conclusão
display_gg() {
  echo -e "${WHITE}___________________________________________________${RESET_COLOR}"
  echo -e ""
  echo -e "           ${CYAN}-----> Wine Setup Completed! <----${RESET_COLOR}"
  echo -e ""
  echo -e "${WHITE}___________________________________________________${RESET_COLOR}"
}

clear
display_gg

# Verificar e executar o Wine
$ROOTFS_DIR/usr/local/bin/wine64 --version
$ROOTFS_DIR/usr/local/bin/winecfg

# Manter o terminal aberto
read -p "Press Enter to exit..."
