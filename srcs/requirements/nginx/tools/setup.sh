#!/bin/bash


until (echo > /dev/tcp/wordpress/9000) 2>/dev/null; do
    echo "Waiting for WordPress..."
    sleep 2
done
echo "WordPress is up!"

# Create SSL directory for saving the certificate and key
mkdir -p /etc/nginx/ssl

# Generate a self-signed SSL certificate and key for Nginx
openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=MA/ST=Marrakesh-Safi/L=BenGuerir/O=42/CN=$DOMAIN_NAME"


exec nginx -g "daemon off;"