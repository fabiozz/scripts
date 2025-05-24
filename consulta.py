#!/usr/share/python
import socket
s = socket.socket(socket.AF_INET6, socket.SOCK_STREAM)
s.connect(("2001:12ff:0:2::3",43))
s.send("businesscorp.com.br"+"\r\n")
resposta = s.recv(1024)
print resposta

