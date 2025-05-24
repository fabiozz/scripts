#!/bin/bash

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
echo "** Iniciando testes, aguarde..." 
for ip in {1..254}
do
    echo "** Testando IP $1.$ip"
    sudo nmap -Pn -sS $1.$ip -p13 --max-retries 0
    sudo nmap -Pn -sS $1.$ip -p37 --max-retries 0 
    sudo nmap -Pn -sS $1.$ip -p30000 --max-retries 0
    sudo nmap -Pn -sS $1.$ip -p3000 --max-retries 0   
    hping3 --syn -c 1 -p 7990 $1.$ip
    sudo hping3 --syn -c 1 -p 3443 $1.$ip
    wget $1.$ip:1337 -O - 2>/dev/null
done
