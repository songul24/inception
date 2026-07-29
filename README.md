# Inception

A multi-container Docker infrastructure hosting a WordPress site, built entirely from Debian Bookworm base images.

## Architecture
Browser → NGINX (443, TLS) → WordPress (PHP-FPM, port 9000) → MariaDB (3306)
Three containers, each built from `debian:bookworm`, no pre-built service images:

- **MariaDB** — stores all WordPress data (posts, users, settings) in the `wordpress` database
- **WordPress** — PHP-FPM 8.2 running the WordPress 7.0.2 core, managed via `wp-cli`
- **NGINX** — the only entry point, terminates TLS (1.2/1.3 only) on port 443, proxies PHP requests to WordPress via FastCGI

All three run on a dedicated Docker bridge network (`inception`) and share a named volume (`wp_data`) mounted at `/var/www/wordpress` for WordPress's files and static assets.

## Quick Start

```bash
make up      # build and start all containers
make down    # stop containers (keep data)
make stop    # stop without removing containers
make start   # start stopped containers
make clean   # down + prune dangling Docker resources
make fclean  # clean + wipe all volumes/data
make re      # fclean + up (full rebuild from scratch)
```

Then visit `https://machaouk.42.fr` (add `127.0.0.1 machaouk.42.fr` to `/etc/hosts` for local testing).

## Key design decisions

### VM vs Docker
A full virtual machine emulates hardware and runs its own kernel, which is heavier and slower to start. Docker containers share the host's kernel and only isolate the process/filesystem layer, making them lighter weight and faster to spin up — better suited for running multiple coordinated services like this project's three containers.

### Secrets vs Env Vars
Plain environment variables (`ENV` in a Dockerfile, or values in `.env`) are visible in `docker inspect`, image history, and process listings — a real leak risk for passwords. This project instead stores each password in its own file under `secrets/`, and passes only the *path* to that file via `_FILE`-suffixed environment variables (e.g. `MYSQL_PASSWORD_FILE`). Each setup script reads the actual password from disk at runtime (`cat "$MYSQL_PASSWORD_FILE"`), so the password itself never appears in an inspectable env var.

### Docker Network vs Host
`network: host` or `--link` would either flatten all containers onto the host's network stack (breaking isolation) or create fragile, deprecated container-to-container links. This project uses a named Docker bridge network (`inception`), which gives each container an isolated network namespace with automatic DNS resolution by service name (e.g. `wordpress` resolves to the WordPress container's IP from within NGINX or MariaDB).

### Volumes vs Bind Mounts
A bind mount ties a container's data directly to a specific host filesystem path, which can behave inconsistently across OSes and expose more of the host than needed. A Docker named volume is managed entirely by Docker's own storage driver — portable, and the only thing containers see is the mount point they're given. This project uses named volumes (`db_data`, `wp_data`) for both MariaDB's data and WordPress's files.