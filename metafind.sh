#!/bin/bash

if [ $# -ne 2 ]; then
  echo "Uso: $0 <url> <tipo_de_arquivo>"
  echo "Exemplo: $0 example.com pdf"
  exit 1
fi

url="$1"
filetype="$2"
temp_dir=$(mktemp -d)
user_agent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.96 Safari/537.36"

echo "[*] Buscando arquivos .$filetype em $url usando Google Dork..."

# Monta a query do Google Dork
query="site:$url filetype:$filetype"

# Faz a busca no Google e pega o HTML da página de resultados
search_url="https://www.google.com/search?q=$(echo $query | sed 's/ /+/g')"

# Baixa a página de resultados com curl e user-agent para evitar bloqueios
html=$(curl -s -A "$user_agent" "$search_url")

# Usa lynx para extrair os links da página de resultados
links=$(echo "$html" | lynx -dump -listonly -stdin | grep "\.$filetype$" | awk '{print $2}' | sort -u)

if [ -z "$links" ]; then
  echo "[-] Nenhum arquivo .$filetype encontrado para $url"
  rm -rf "$temp_dir"
  exit 0
fi

echo "[*] Encontrados $(echo "$links" | wc -l) arquivos. Baixando e analisando metadados..."

for link in $links; do
  echo "==> Analisando: $link"
  filename="$temp_dir/$(basename "$link")"
  # Baixa o arquivo
  curl -s -A "$user_agent" -L "$link" -o "$filename"
  if [ ! -s "$filename" ]; then
    echo "  [!] Falha ao baixar ou arquivo vazio."
    continue
  fi
  # Analisa metadados com exiftool
  exiftool "$filename"
  echo "----------------------------------------"
done

# Limpa arquivos temporários
rm -rf "$temp_dir"
