FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    nginx \
    && rm -rf /var/lib/apt/lists/*

COPY tools/index.html /var/www/html/index.html

# -g "daemon off;" keeps nginx in the foreground -> PID 1
CMD ["nginx", "-g", "daemon off;"]