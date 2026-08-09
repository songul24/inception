FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /app /data

# Download the official Portainer CE binary release, pinned version
RUN curl -L https://github.com/portainer/portainer/releases/download/2.39.5/portainer-2.39.5-linux-amd64.tar.gz \
    -o /tmp/portainer.tar.gz \
    && tar -xzf /tmp/portainer.tar.gz -C /app --strip-components=1 \
    && rm /tmp/portainer.tar.gz

WORKDIR /app

EXPOSE 9443

CMD ["/app/portainer", "--data", "/data"]