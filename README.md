# Repositório Wine.sh

Este repositório contém arquivos relacionados ao Wine. Os arquivos estão organizados da seguinte forma:

## Arquivos:

- **wine-10.2-amd64.tar.xz**: Arquivo original do Wine.
- **wine-10.2-amd64-part-aa**, **wine-10.2-amd64-part-ab**, etc: Partes divididas do arquivo `wine-10.2-amd64.tar.xz`.
- **wine-10.2-staging-amd64-wow6**: Outro arquivo relacionado ao Wine.

## Como restaurar o arquivo original:

Se você precisar restaurar o arquivo original do Wine, basta usar o comando:

```bash
cat wine_files/wine-10.2-amd64-part-* > wine_files/wine-10.2-amd64.tar.xz

