#!/bin/bash

#serve para fazer transferência de zona e coletar informações armazenadas no nameserver.

dominio=$1

if [ -z "$dominio" ]; then
  echo "Uso: $0 <dominio>"
  exit 1
fi

for server in $(host -t ns $dominio | cut -d " " -f4); do
  echo "Tentando transferência de zona no servidor: $server"
  host -l -a $dominio $server
done
