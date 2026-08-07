FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php \
    php-mysqli \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html

# Download Adminer, pinned version, renamed to index.php so PHP's
# built-in server serves it at "/" automatically
RUN curl -L https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php \
    -o /var/www/html/index.php

EXPOSE 8080

# PHP's built-in dev server, in the foreground -> becomes PID 1
CMD [ "php", "-S", "0.0.0.0:8080", "-t", "/var/www/html" ]