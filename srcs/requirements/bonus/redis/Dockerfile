FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    redis-server \
    && rm -rf /var/lib/apt/lists/*

COPY tools/setup.sh /setup.sh
RUN chmod +x /setup.sh


ENTRYPOINT ["/setup.sh"]