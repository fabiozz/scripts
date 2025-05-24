#!/bin/bash

# basicamente tecnica de port knocking.

# Verifica se o argumento foi passado
if [ "$1" == "" ]
then
    # Se não passou argumento informa e sai do script
    echo "Informe a rede alvo, exemplo: 192.168.0"
    exit 1
fi

# Verifica se é root
if [ $UID -ne 0 ]
then
    # Se não for root informa e sai do script
    echo "Execute como root, exemplo: sudo ./script.sh 192.168.0"
    exit 1
fi

# Inicia o loop
echo "** iniciando testes, aguarde..." 
for ip in {1..254}
do
    echo "** Testando IP $1.$ip"
    hping3 $1.$ip -S -c 1 -p 13 &> /dev/null
    hping3 $1.$ip -S -c 1 -p 37 &> /dev/null
    hping3 $1.$ip -S -c 1 -p 30000 &> /dev/null
    hping3 $1.$ip -S -c 1 -p 3000 &> /dev/null
    curl "http://$1.$ip:1337/" -m .5 2>/dev/null
done
