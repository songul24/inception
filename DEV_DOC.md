# Developer Documentation

## Project Structure

```text
inception/
├── Makefile
├── secrets/
├── srcs/
│   ├── .env
│   ├── docker-compose.yml
│   └── requirements/
│       ├── mariadb/
│       ├── nginx/
│       └── wordpress/
```

The bonus services have their own requirement directories.

## Setup

Requirements:

- Docker
- Docker Compose
- Make

Configuration is stored in:

```text
srcs/.env
```

Passwords are stored in:

```text
secrets/
```

## Build and Launch

```bash
make up
```

Or:

```bash
docker compose -f srcs/docker-compose.yml build
docker compose -f srcs/docker-compose.yml up -d
```

Full rebuild:

```bash
make fclean
docker compose -f srcs/docker-compose.yml build --no-cache
make up
```

## Useful Commands

```bash
docker compose -f srcs/docker-compose.yml ps
docker compose -f srcs/docker-compose.yml logs -f
docker logs <container>
docker exec -it <container> bash
```

## Data Persistence

```text
db_data
└── MariaDB data

wp_data
└── WordPress files
```

`wp_data` is shared by WordPress and NGINX.

## Networking

All services use the `inception` Docker bridge network.

Services can communicate using Docker DNS:

```text
wordpress
mariadb
redis
```

PHP-FPM listens on `0.0.0.0:9000` because NGINX runs in a separate container and communicates with it over the Docker network.

## Bonus Services

### Redis

Redis runs on port `6379` and provides WordPress object caching.

The Redis Object Cache plugin connects WordPress to:

```text
redis:6379
```

### FTP

FTP provides access to the WordPress files.

```text
21              → control connection
21100-21110     → passive data connections
```

The FTP service shares the WordPress volume.

### Portainer

Portainer provides Docker management through a web interface.

It communicates with Docker through:

```text
/var/run/docker.sock
```

and stores its own data in a persistent volume.

### Adminer

Adminer provides a web interface for managing MariaDB. It connects to MariaDB through the Docker network.

### Static Website

The static website is an independent service serving static HTML/CSS/JavaScript files.

## Troubleshooting

Check all services:

```bash
docker compose -f srcs/docker-compose.yml ps
```

View logs:

```bash
docker compose -f srcs/docker-compose.yml logs -f
```

If WordPress cannot connect to MariaDB, check that both services are running and are on the same Docker network.

If Redis is unavailable, check that the Redis container is running and that WordPress is configured with `redis` as its Redis host.