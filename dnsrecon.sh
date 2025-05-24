#!/bin/bash

# realiza reconhecimento do DNS baseado em name list.

for palavra in $(cat lista.txt);do
host $palavra.$1| grep -v "NXDOMAIN"
done
