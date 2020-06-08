#!/bin/bash
# https://dev.mysql.com/doc/refman/5.6/en/creating-ssl-files-using-openssl.html
# https://www.getpagespeed.com/server-setup/setup-mysql-ssl-connections
set -euxo pipefail
SSL_DOMAIN=${SSL_DOMAIN:=mysql.local}
SSL_DAYS=${SSL_DAYS:=3650}
RSA_BITS=2048

cd /var/lib/mysql

# Create CA certificate
openssl genrsa ${RSA_BITS} > ca-key.pem
openssl req -new -x509 -nodes -days ${SSL_DAYS} \
        -key ca-key.pem -out ca.pem \
        -subj "/CN=${SSL_DOMAIN}"

# Create server certificate, remove passphrase, and sign it
# server-cert.pem = public key, server-key.pem = private key
openssl req -newkey rsa:${RSA_BITS} -days ${SSL_DAYS} \
        -subj "/CN=server.${SSL_DOMAIN}" \
        -nodes -keyout server-key.pem -out server-req.pem
openssl rsa -in server-key.pem -out server-key.pem
openssl x509 -req -in server-req.pem -days ${SSL_DAYS} \
        -CA ca.pem -CAkey ca-key.pem -set_serial 01 -out server-cert.pem

## Create client certificate, remove passphrase, and sign it
## client-cert.pem = public key, client-key.pem = private key
#openssl req -newkey rsa:${RSA_BITS} -days ${SSL_DAYS} \
#        -subj "/CN=client.${SSL_DOMAIN}" \
#        -nodes -keyout client-key.pem -out client-req.pem
#openssl rsa -in client-key.pem -out client-key.pem
#openssl x509 -req -in client-req.pem -days ${SSL_DAYS} \
#        -CA ca.pem -CAkey ca-key.pem -set_serial 01 -out client-cert.pem

#openssl verify -CAfile ca.pem server-cert.pem client-cert.pem
openssl verify -CAfile ca.pem server-cert.pem
chmod 0600 *.pem
