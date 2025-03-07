#!/bin/bash

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
if [ ! -e "$ROOTFS_DIR/.installed" ]; then
  echo "#######################################################################################"
  echo "#"
  echo "#                                      Wine INSTALLER"
  echo "#"
  echo "#                           Copyright (C) 2024, Wine.sh"
  echo "#"
  echo "#"
  echo "#######################################################################################"

  # Pergunta ao usuário se deseja instalar o Wine
  read -p "Do you want to install Wine? (YES/no): " install_wine

  case $install_wine in
    [yY][eE][sS]|[yY])
      # Baixar o Wine a partir do repositório FreeWine
      echo "Downloading Wine..."
      if ! wget -q --show-progress -O wine.tar.xz "https://github.com/GabrielCriste/FreeWine/releases/download/latest/wine-${ARCH_ALT}.tar.xz"; then
        echo "Failed to download Wine. Please check your internet connection."
        exit 1
      fi

      # Extrair o Wine
      echo "Extracting Wine..."
      if ! tar -xf wine.tar.xz -C "$ROOTFS_DIR"; then
        echo "Failed to extract Wine."
        exit 1
      fi

      # Marcar como instalado
      touch "$ROOTFS_DIR/.installed"
      ;;
    *)
      echo "Skipping Wine installation."
      exit 0
      ;;
  esac
fi

# Verificar se o Wine foi extraído corretamente
if [ ! -e "$ROOTFS_DIR/.installed" ]; then
  echo "Wine installation failed. Please check the logs."
  exit 1
fi

# Exibir mensagem de conclusão
echo "___________________________________________________"
echo ""
echo "           -----> Wine Setup Completed! <----"
echo ""
echo "___________________________________________________"

# Verificar e executar o Wine
if [ -e "$ROOTFS_DIR/usr/local/bin/wine64" ]; then
  "$ROOTFS_DIR/usr/local/bin/wine64" --version
else
  echo "Wine not found in the expected directory."
  exit 1
fi

if [ -e "$ROOTFS_DIR/usr/local/bin/winecfg" ]; then
  "$ROOTFS_DIR/usr/local/bin/winecfg"
else
  echo "Winecfg not found in the expected directory."
  exit 1
fi
