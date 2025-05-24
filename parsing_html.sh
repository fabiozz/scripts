#!/usr/bin/env bash
################################################################################
# Titulo : Parsing_HTML_Bash
# Versao : 1.0
# Data   : 22.03.2023
# Homepage: https://www.desecsecurity.com
# Tested on: Linux

# Cores
RED='\033[31;1m'
GREEN='\033[32;1m'
BLUE='\033[34;1m'
YELLOW='\033[33;1m'
END='\033[m'

# Verificar dependências
[[ -e /usr/bin/wget ]] || printf "\nFaltando programa ${RED}wget${END} para funcionar.\n"
[[ -e /usr/bin/curl ]] || printf "\nFaltando programa ${RED}curl${END} para funcionar.\n"

# Verificando argumentos
if [[ "$1" == "" ]]; then
  echo -e "${YELLOW}################################################################################${END}"
  echo -e "${YELLOW}|-> PARSING HTML <-|${END}"
  echo -e "${YELLOW}|-> Desec Security - Ricardo Longatto <-|${END}"
  echo -e "${YELLOW}|-> Exemplo: $0 www.alvo.com.br <-|${END}"
  echo -e "${YELLOW}################################################################################${END}"
  exit 1
fi

# Sanitizar nome de arquivo
output=$(echo "$1" | sed 's|https\?://||; s|/|_|g')

# Download da página
wget "$1" -q -O "${output}.html"

# Filtrar links
grep "href" "${output}.html" | cut -d "/" -f 3 | grep "\." | cut -d '"' -f 1 | grep -v "<l" | grep -v "www." | sort -u > "${output}.hosts"

# Mostrar hosts encontrados
echo -e "${YELLOW}################################################################################${END}"
echo -e "${YELLOW}|-> Buscando Hosts... <-|${END}"
echo -e "${YELLOW}################################################################################${END}"
echo

for i in $(cat "${output}.hosts"); do
  status_code=$(curl -m 2 -o /dev/null -s -w "%{http_code}\n" "$i")
  echo -e "$i [CODE : ${status_code}]"
done

# Resolver IPs
echo -e "${YELLOW}################################################################################${END}"
echo -e "${YELLOW}|-> Resolvendo Hosts... <-|${END}"
echo -e "${YELLOW}################################################################################${END}"
for h in $(cat "${output}.hosts"); do host "$h"; done | grep "has address" > "${output}.ip"
cat "${output}.ip"

# Limpeza
rm "${output}.hosts" "${output}.ip"
exit 0
