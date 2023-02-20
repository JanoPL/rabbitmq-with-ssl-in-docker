#!/bin/bash

set -eu

#
# Prepare the client's stuff.
#
cd /tmp/client

# Generate a private RSA key.
openssl genrsa -out key.pem 4096

# Generate a certificate from our private key.
openssl req -new -key key.pem -out req.pem -outform PEM -subj /CN=$DOMAIN/O=client/ -nodes

# Sign the certificate with our CA.
cd /tmp/certs
openssl ca -config /tmp/openssl.cnf -in /tmp/client/req.pem -out /tmp/client/cert.pem -notext -batch -extensions client_ca_extensions

# Create a key store that will contain our certificate.
cd /tmp/client
openssl pkcs12 -export -out key-store.p12 -in cert.pem -inkey key.pem -passout pass:roboconf

# Create a trust store that will contain the certificate of our CA.
openssl pkcs12 -export -out trust-store.p12 -in /tmp/certs/cacert.pem -inkey /tmp/certs/private/cakey.pem -passout pass:roboconf
