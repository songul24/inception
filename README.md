*This project has been created as part of the 42 curriculum by machaouk.*

# Inception

## Description

Inception is a Docker infrastructure hosting a WordPress website. Each service runs in its own container and communicates through a dedicated Docker bridge network.

### Mandatory services

- **NGINX** — HTTPS entry point and FastCGI server.
- **WordPress** — PHP-FPM application.
- **MariaDB** — WordPress database.

### Bonus services

- **Redis** — WordPress object cache.
- **FTP** — file transfer service for WordPress files.
- **Portainer** — Docker management interface.
- **Adminer** — MariaDB management interface.
- **Static Website** — additional static website.

## Architecture

```text
Browser
   |
 HTTPS :443
   |
 NGINX
   |
 FastCGI :9000
   |
 WordPress
   |
   +------ MariaDB :3306
   |
   +------ Redis :6379

Bonus:
FTP | Portainer | Adminer | Static Website
```

All services use the `inception` Docker network.

The `wp_data` volume is shared between WordPress and NGINX. `db_data` stores MariaDB data.

## Instructions

### Requirements

- Docker
- Docker Compose
- Make

### Start

```bash
make up
```

For local testing, add:

```text
127.0.0.1 machaouk.42.fr
```

to `/etc/hosts`.

Then access:

```text
https://machaouk.42.fr
```

The certificate is self-signed, so the browser will show a security warning.

### Useful commands

```bash
make up
make stop
make start
make down
make clean
make fclean
make re
```

## Design Choices

### Virtual Machines vs Docker

VMs run a complete guest operating system and kernel. Docker containers share the host kernel, making them lighter and faster.

### Secrets vs Environment Variables

Passwords are stored in Docker secret files instead of directly in environment variables.

### Docker Network vs Host Network

A dedicated Docker bridge network keeps containers isolated while allowing them to communicate using service names.

### Docker Volumes vs Bind Mounts

Named volumes are managed by Docker and provide persistent storage without directly exposing a host directory.

## Resources

- Docker: https://docs.docker.com/
- Docker Compose: https://docs.docker.com/compose/
- WordPress: https://wordpress.org/documentation/
- WP-CLI: https://make.wordpress.org/cli/handbook/
- NGINX: https://nginx.org/en/docs/
- MariaDB: https://mariadb.com/docs/
- Redis: https://redis.io/docs/
- Portainer: https://docs.portainer.io/
- Adminer: https://www.adminer.org/

### AI Usage

AI was used as a learning and development assistant to understand Docker, networking, volumes, WordPress, PHP-FPM, MariaDB and the bonus services, and to help troubleshoot and document the project.