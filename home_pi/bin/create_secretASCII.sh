#!/bin/bash

## Erzeugt 32 zufällige Bytes, kodiert als Base64 in einer Zeile
# openssl rand -base64 32 | tr -d '\n' 

## Liest aus der Zufallsquelle, filtert nur Alphanumerik, nimmt 1024 Zeichen
head /dev/urandom | tr -dc 'A-Za-z0-9' | head -c 1024
