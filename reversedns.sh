#!/bin/bash

prefix=$1
start=$2
end=$3

if [ -z "$prefix" ] || [ -z "$start" ] || [ -z "$end" ]; then
  echo "Uso: $0 <prefixo_ip> <inicio_range> <fim_range>"
  echo "Exemplo: $0 34.175.25 230 250"
  exit 1
fi

for ip in $(seq $start $end); do
  host -t ptr "${prefix}.${ip}"
done
