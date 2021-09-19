#!/bin/bash

set -eu

#
# Prepare the certificate authority (self-signed).
#
cd /rbmq/testca

# Create a self-signed certificate that will serve a certificate authority (CA).
# The private key is located under "private".
openssl req -x509 -config openssl.cnf -newkey rsa:2048 -days 365 -out cacert.pem -outform PEM -subj /CN=MyTestCA/ -nodes

# Encode our certificate with DER.
openssl x509 -in cacert.pem -out cacert.cer -outform DER



#
# Prepare the server's stuff.
#
cd /rbmq/server

# Generate a private RSA key.
openssl genrsa -out key.pem 2048

# Generate a certificate from our private key.
#openssl req -new -key key.pem -out req.pem -outform PEM -subj /CN=$(hostname)/O=server/ -nodes
openssl req -new -key key.pem -out req.pem -outform PEM -subj /CN=$DOMAIN/O=server/ -nodes

# Sign the certificate with our CA.
cd /rbmq/testca
openssl ca -config openssl.cnf -in /rbmq/server/req.pem -out /rbmq/server/cert.pem -notext -batch -extensions server_ca_extensions

# Create a key store that will contain our certificate.
cd /rbmq/server
openssl pkcs12 -export -out keycert.p12 -in cert.pem -inkey key.pem -passout pass:roboconf
