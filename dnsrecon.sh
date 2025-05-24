#!/bin/bash

# realiza reconhecimento do DNS baseado em name list.
# ./dnsrecon.sh example.com

for palavra in $(cat lista.txt);do
host $palavra.$1| grep -v "NXDOMAIN"
done
