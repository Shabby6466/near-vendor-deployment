#!/bin/bash
# ======================================================================================
#   This script generates a self-signed SSL certificate for the Nginx service.
# ======================================================================================
SSL_DIR="./nginx/ssl"
KEY_FILE="$SSL_DIR/selfsigned.key"
CERT_FILE="$SSL_DIR/selfsigned.crt"
DAYS_VALID=365

if [ -f "$CERT_FILE" ]; then
  echo "--> Self-signed certificate already exists. Skipping generation."
  exit 0
fi

echo "### Generating Self-Signed SSL Certificate for NearVendor ###"
mkdir -p $SSL_DIR
openssl req -x509 -nodes -newkey rsa:4096 -days $DAYS_VALID \
    -keyout "$KEY_FILE" \
    -out "$CERT_FILE" \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"
echo "### Self-signed SSL certificate has been successfully generated. ###"
