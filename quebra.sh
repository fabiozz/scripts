#!/bin/bash

wordlist="/usr/share/wordlists/rockyou.txt"
hash='$6$czohNE6k$2YhrLYvK5BnavWLsPDVSlttNyXVxHedBoStgLWdcBJAQB8hs8TdJBE33BYuP9Q6U.ZKfNPcgpr3j5FYoach.O0'

# extrai o salt do hash
salt=$(echo "$hash" | cut -d'$' -f3)

while read senha; do
    echo "Testando senha ===> $senha"
    gerado=$(mkpasswd -m sha-512 -S "$salt" "$senha")
    echo "hash gerado   ===> $gerado"

    if [ "$hash" = "$gerado" ]; then
        echo "*******************************"
        echo "[+] SENHA ENCONTRADA => $senha"
        echo "*******************************"
        exit 0
    fi
done < "$wordlist"

echo "[-] Nenhuma senha corresponde ao hash."
exit 1
