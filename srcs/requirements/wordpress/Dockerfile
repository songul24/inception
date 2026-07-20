FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php-fpm \
    php-mysqli \
    php-gd \
    php-curl \
    php-xml \
    php-mbstring \
    curl \
    default-mysql-client \
    && rm -rf /var/lib/apt/lists/*
# added default-mysql-client so we get "mysqladmin"

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp

COPY tools/wp-setup.sh /wp-setup.sh
RUN chmod +x /wp-setup.sh

EXPOSE 9000
ENTRYPOINT ["/wp-setup.sh"]