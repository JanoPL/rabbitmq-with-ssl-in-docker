#!/bin/bash

set -eu

#
# Prepare the certificate authority (self-signed).
#
cd /tmp/certs

# Create a self-signed certificate that will serve a certificate authority (CA).
# The private key is located under "private".
openssl req -x509 -config /tmp/openssl.cnf -newkey rsa:4096 -days 365 -out cacert.pem -outform PEM -subj /CN=MyTestCA/ -nodes

# Encode our certificate with DER.
openssl x509 -in cacert.pem -out cacert.cer -outform DER

#
# Prepare the server's stuff.
#
cd /tmp/server

# Generate a private RSA key.
openssl genrsa -out key.pem 4096

# Generate a certificate from our private key.
openssl req -new -key key.pem -out req.pem -outform PEM -subj /CN=$DOMAIN/O=server/ -nodes

# Sign the certificate with our CA.
cd /tmp/certs
openssl ca -config /tmp/openssl.cnf -in /tmp/server/req.pem -out /tmp/server/cert.pem -notext -batch -extensions server_ca_extensions

# Create a key store that will contain our certificate.
cd /tmp/server
openssl pkcs12 -export -out keycert.p12 -in cert.pem -inkey key.pem -passout pass:roboconf
