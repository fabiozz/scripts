#!/bin/bash

# coleta de e-mails expostos em sites relacionados a um domínio principal
# sudo apt install cewl
# ./email_scraper.sh example.com

if [ -z "$1" ]; then
  echo "Uso: $0 dominio.com"
  exit 1
fi

main_domain="$1"
hosts_file="hosts.txt"
emails_file="emails_found.txt"

> "$hosts_file"
> "$emails_file"

echo "[*] Coletando hosts do domínio principal: $main_domain"

# pega o conteúdo da página principal
page_content=$(curl -s "http://www.$main_domain")

if [ -z "$page_content" ]; then
  echo "Erro: não foi possível obter conteúdo de http://www.$main_domain"
  exit 1
fi

# extrai hosts/domínios do conteúdo
echo "$page_content" | grep -Eo 'https?://[^/"]+' | sed -E 's#https?://##' | cut -d/ -f1 | sort -u > "$hosts_file"

# garante que o domínio principal está na lista
if ! grep -q "$main_domain" "$hosts_file"; then
  echo "$main_domain" >> "$hosts_file"
fi

while read -r host; do
  echo "[*] Coletando emails do host: $host"
  cewl -e "http://$host" 2>/dev/null | grep "@" >> "$emails_file"
done < "$hosts_file"

sort -u "$emails_file" -o "$emails_file"

echo "[*] Emails coletados:"
cat "$emails_file"

rm -f "$hosts_file" "$emails_file"
