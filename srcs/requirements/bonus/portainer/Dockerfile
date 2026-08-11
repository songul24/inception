FROM debian:bookworm


# Install curl and ca-certificates for downloading Portainer
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*


# Create directories for Portainer and its data
RUN mkdir -p /app /data

# Download portainer and extract it to /app
RUN curl -L https://github.com/portainer/portainer/releases/download/2.39.5/portainer-2.39.5-linux-amd64.tar.gz \
    -o /tmp/portainer.tar.gz \
    && tar -xzf /tmp/portainer.tar.gz -C /app --strip-components=1 \
    && rm /tmp/portainer.tar.gz

WORKDIR /app

#start portainer and store data in /data
CMD ["/app/portainer", "--data", "/data"]