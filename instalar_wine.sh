#!/bin/sh
# instalar_wine.sh
# Script para extrair e preparar o Wine a partir dos arquivos baixados.
# Não requer acesso a root.

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
  printf "Unsupported CPU architecture: ${ARCH}\n"
  exit 1
fi

# Se o arquivo de instalação não foi marcado, inicia o processo
if [ ! -e "$ROOTFS_DIR/.installed" ]; then
  echo "#######################################################################################"
  echo "#"
  echo "#                                      Wine INSTALLER"
  echo "#                           (Instalação sem acesso a root)"
  echo "#"
  echo "#######################################################################################"
  install_wine=YES
fi

case $install_wine in
  [yY][eE][sS]|[yY])
    # Se o arquivo completo não existir, une as partes
    if [ ! -f "$ROOTFS_DIR/wine-10.2-amd64.tar.xz" ]; then
      echo "Concatenando as partes do arquivo wine-10.2-amd64..."
      cat "$ROOTFS_DIR/wine-10.2-amd64-part-"* > "$ROOTFS_DIR/wine-10.2-amd64.tar.xz"
      if [ $? -ne 0 ]; then
         echo "Erro ao concatenar as partes do Wine."
         exit 1
      fi
    fi

    # Extrai o arquivo principal do Wine
    echo "Extraindo wine-10.2-amd64.tar.xz..."
    tar -xf "$ROOTFS_DIR/wine-10.2-amd64.tar.xz" -C "$ROOTFS_DIR"
    if [ $? -ne 0 ]; then
         echo "Falha ao extrair o arquivo wine-10.2-amd64.tar.xz."
         exit 1
    fi

    # Se existir, extrai também o arquivo de staging (WOW64)
    if [ -f "$ROOTFS_DIR/wine-10.2-staging-amd64-wow64.tar.xz" ]; then
      echo "Extraindo wine-10.2-staging-amd64-wow64.tar.xz..."
      tar -xf "$ROOTFS_DIR/wine-10.2-staging-amd64-wow64.tar.xz" -C "$ROOTFS_DIR"
      if [ $? -ne 0 ]; then
         echo "Falha ao extrair o arquivo wine-10.2-staging-amd64-wow64.tar.xz."
         exit 1
      fi
    fi

    # Marca a instalação como concluída
    touch "$ROOTFS_DIR/.installed"
    ;;
  *)
    echo "Instalação do Wine cancelada."
    exit 0
    ;;
esac

# Mensagem de conclusão com cores
CYAN='\e[0;36m'
WHITE='\e[0;37m'
RESET_COLOR='\e[0m'

echo -e "${WHITE}___________________________________________________${RESET_COLOR}"
echo -e ""
echo -e "           ${CYAN}-----> Extração do Wine concluída! <----${RESET_COLOR}"
echo -e ""
echo -e "${WHITE}___________________________________________________${RESET_COLOR}"

# Se desejar, teste a versão do Wine extraído (ajuste o caminho conforme a estrutura extraída)
if [ -x "$ROOTFS_DIR/wine/bin/wine64" ]; then
  "$ROOTFS_DIR/wine/bin/wine64" --version
else
  echo "Wine não encontrado no diretório esperado. Verifique se a extração ocorreu corretamente."
fi
