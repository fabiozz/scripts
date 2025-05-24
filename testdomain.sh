#!/bin/bash

# testa todos os tipos de registros do host

target=$1

if [ -z "$target" ]; then
  echo "Uso: $0 <dominio_ou_ip>"
  exit 1
fi

types=("SOA" "A" "AAAA" "NS" "CNAME" "MX" "PTR" "HINFO" "TXT")

for type in "${types[@]}"; do
  echo "$type:"
  host -t $type $target
  echo ""
done
