FROM debian:bookworm

RUN apt-get update && apt-get install -y nginx openssl

COPY conf/nginx.conf /etc/nginx/nginx.conf

COPY tools/setup.sh /

RUN chmod +x /setup.sh

ENTRYPOINT ["/setup.sh"]


# FROM debian:bookworm
# # Same base as MariaDB and WordPress — Debian Bookworm, no pre-built images allowed

# RUN apt-get update && apt-get install -y nginx openssl && rm -rf /var/lib/apt/lists/*
# # Install nginx itself, plus openssl (needed to generate our self-signed TLS cert)
# # rm -rf cleans the package cache afterward to keep the image small

# RUN mkdir -p /etc/nginx/ssl
# # Directory where we'll put our TLS certificate and key

# RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
#     -keyout /etc/nginx/ssl/inception.key \
#     -out /etc/nginx/ssl/inception.crt \
#     -subj "/C=MA/ST=Marrakesh-Safi/L=BenGuerir/O=42/CN=machaouk.42.fr"
# # Generate a self-signed cert at BUILD time (fine for this project — no CA needed)
# # -x509: output a self-signed certificate instead of a CSR
# # -nodes: don't encrypt the private key (no passphrase prompt on nginx start)
# # -days 365: cert validity
# # -newkey rsa:2048: generate a new 2048-bit RSA key alongside it
# # CN should match your actual login — replace "malika" with your 42 login

# COPY conf/nginx.conf /etc/nginx/nginx.conf
# # We'll write this file in the next step

# EXPOSE 443
# # Only 443 — port 80 is explicitly excluded by the subject

# ENTRYPOINT ["nginx", "-g", "daemon off;"]
# # "daemon off" keeps nginx in the foreground so it becomes PID 1 correctly