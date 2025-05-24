#!/bin/bash

# verifica todos os subdominios hospedados usando "alias" baseado na name list.
# ./subtakeover.sh dominio.com


for palavra in $(cat lista.txt);do
host -t cname  $palavra.$1| grep "alias for"
done
