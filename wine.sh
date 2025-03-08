#!/bin/bash

set -e  # Encerra o script imediatamente em caso de erro

ROOTFS_DIR=$(pwd)
export PATH=$PATH:~/.local/usr/bin
max_retries=50
timeout=1
ARCH=$(uname -m)

# Verificar dependências
if ! command -v wget &> /dev/null || ! command -v tar &> /dev/null; then
  echo "Please install 'wget' and 'tar' to continue."
  exit 1
fi

# Verificar permissões
if [ ! -w "$ROOTFS_DIR" ]; then
  echo "You do not have write permissions for $ROOTFS_DIR."
  exit 1
fi

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
  echo "#                                      FreeWine INSTALLER"
  echo "#"
  echo "#                           Copyright (C) 2024, GabrielCriste/FreeWine"
  echo "#"
  echo "#"
  echo "#######################################################################################"

  read -p "Do you want to install Wine? (YES/no): " install_wine
fi

case $install_wine in
  [yY][eE][sS]|[yY])
    # Baixar o Wine a partir do repositório FreeWine
    echo "Downloading Wine..."
    if ! wget --tries=$max_retries --timeout=$timeout --no-hsts -O /tmp/wine.tar.xz \
      "https://github.com/GabrielCriste/FreeWine/releases/download/latest/wine-${ARCH_ALT}.tar.xz"; then
      echo "Failed to download Wine. Please check your internet connection."
      exit 1
    fi

    # Extrair o Wine
    echo "Extracting Wine..."
    if ! tar -xf /tmp/wine.tar.xz -C "$ROOTFS_DIR"; then
      echo "Failed to extract Wine."
      exit 1
    fi

    # Marcar como instalado
    touch "$ROOTFS_DIR/.installed"

    # Limpar arquivo temporário
    rm -f /tmp/wine.tar.xz
    ;;
  *)
    echo "Skipping Wine installation."
    ;;
esac

# Configurar o Wine
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
