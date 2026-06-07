FROM debian:bookworm
# Start from Debian bookworm as our base OS

RUN apt-get update && apt-get install -y mariadb-server && rm -rf /var/lib/apt/lists/*
# Install MariaDB, then clean up package cache to keep image small

COPY conf/my.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
# Copy our custom config into the container

COPY tools/init.sh /init.sh
# Copy our startup script into the container

RUN chmod +x /init.sh
# Make the script executable

EXPOSE 3306
# MariaDB listens on port 3306

ENTRYPOINT ["/init.sh"]
# When container starts, run our script
