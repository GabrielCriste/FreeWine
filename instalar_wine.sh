#!/bin/bash

# Diretório atual
ROOTFS_DIR=$(pwd)

# Arquivo principal do Wine
WINE_ARCHIVE="$ROOTFS_DIR/wine-10.2-amd64.tar.xz"

# Função para verificar se o Wine já está instalado
function check_wine_installed {
  if command -v wine64 &> /dev/null; then
    echo "O Wine já está instalado."
    exit 0
  fi
}

# Função para extrair o arquivo tar.xz
function extract_wine {
  echo "Extraindo o Wine..."
  tar -xf "$WINE_ARCHIVE" -C "$ROOTFS_DIR"
  if [ $? -ne 0 ]; then
    echo "Falha ao extrair o Wine."
    exit 1
  fi
}

# Função para configurar o Wine
function configure_wine {
  echo "Configurando o Wine..."
  cd "$ROOTFS_DIR/wine-10.2-amd64" || exit 1
  ./configure --prefix=/usr/local
  if [ $? -ne 0 ]; then
    echo "Falha na configuração do Wine."
    exit 1
  fi
}

# Função para compilar e instalar o Wine
function build_and_install_wine {
  echo "Compilando e instalando o Wine..."
  make
  if [ $? -ne 0 ]; then
    echo "Falha na compilação do Wine."
    exit 1
  fi
  sudo make install
  if [ $? -ne 0 ]; then
    echo "Falha na instalação do Wine."
    exit 1
  fi
}

# Função principal
function main {
  check_wine_installed
  extract_wine
  configure_wine
  build_and_install_wine
  echo "Wine instalado com sucesso!"
  wine64 --version
}

# Executa a função principal
main
