#!/bin/bash

# This script automates the initial setup of Let's Encrypt SSL certificates.

# Load environment variables safely
set -a # automatically export all variables
source .env
set +a

if [ -z "$DOMAIN" ] || [ -z "$CERT_EMAIL" ]; then
  echo "Error: DOMAIN and CERT_EMAIL must be set in the .env file."
  exit 1
fi

echo "### Initializing SSL certificates for $DOMAIN ###"
# Get the first domain in the list to use as the directory name
PRIMARY_DOMAIN=$(echo $DOMAIN | awk '{print $1}')

echo "### Initializing SSL certificates for: $DOMAIN ###"
echo "### Primary directory name: $PRIMARY_DOMAIN ###"

# Create dummy certificate to start Nginx
echo "--> Creating dummy certificate..."
mkdir -p ./certbot_conf/live/$PRIMARY_DOMAIN
docker compose run --rm --entrypoint "\
  openssl req -x509 -nodes -newkey rsa:4096 -days 1\
    -keyout '/etc/letsencrypt/live/$PRIMARY_DOMAIN/privkey.pem' \
    -out '/etc/letsencrypt/live/$PRIMARY_DOMAIN/fullchain.pem' \
    -subj '/CN=localhost'" certbot

# Download recommended SSL parameters
echo "--> Downloading SSL parameters..."
mkdir -p ./certbot_conf
curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > "./certbot_conf/options-ssl-nginx.conf"
curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "./certbot_conf/ssl-dhparams.pem"

# Start Nginx
echo "--> Starting Nginx..."
docker compose up -d nginx

# Request real certificate
echo "--> Deleting dummy certificate and requesting real one..."
docker compose run --rm --entrypoint "\
  rm -Rf /etc/letsencrypt/live/$PRIMARY_DOMAIN && \
  rm -Rf /etc/letsencrypt/archive/$PRIMARY_DOMAIN && \
  rm -Rf /etc/letsencrypt/renewal/$PRIMARY_DOMAIN.conf" certbot

# Build the domain arguments dynamically (-d domain1.com -d www.domain1.com)
domain_args=""
for d in $DOMAIN; do
  domain_args="$domain_args -d $d"
done

cert_command="certbot certonly --webroot -w /var/www/certbot \
  --email $CERT_EMAIL \
  $domain_args \
  --rsa-key-size 4096 \
  --agree-tos \
  --force-renewal \
  --non-interactive"
docker compose run --rm --entrypoint "$cert_command" certbot

# Stop the temporary Nginx
echo "--> Shutting down temporary Nginx..."
docker compose stop nginx

echo "### SSL setup complete! You can now start the stack with 'sh deploy.sh start' ###"
