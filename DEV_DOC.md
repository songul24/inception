# Developer Documentation

## Project structure

inception/
├── Makefile
├── secrets/
│ ├── db_password.txt
│ ├── db_root_password.txt
│ ├── wp_admin_password.txt
│ └── wp_user_password.txt
└── srcs/
├── .env
├── docker-compose.yml
└── requirements/
├── mariadb/
│ ├── Dockerfile
│ ├── conf/my.cnf
│ └── tools/init.sh
├── nginx/
│ ├── Dockerfile
│ └── conf/nginx.conf
└── wordpress/
├── Dockerfile
└── tools/wp-setup.sh

## Container responsibilities

**MariaDB** (`requirements/mariadb/`)
- Installs `mariadb-server` on `debian:bookworm`
- `conf/my.cnf` sets `bind-address = 0.0.0.0` so WordPress (a different container) can connect
- `tools/init.sh` initializes the data directory on first run only, creates the `wordpress` DB, `wpuser`, and root account, then execs `mysqld` as PID 1

**WordPress** (`requirements/wordpress/`)
- Installs PHP-FPM 8.2 + required extensions (mysqli, gd, curl, xml, mbstring), plus `wp-cli`
- Patches PHP-FPM's pool config from a Unix socket to TCP (`0.0.0.0:9000`) so NGINX, running in a separate container, can reach it over FastCGI
- `tools/wp-setup.sh` waits for MariaDB (`mysqladmin ping`), downloads WordPress via `wp-cli` only if `wp-config.php` doesn't already exist (idempotent across restarts), creates the admin (`superadmin`) and a second non-admin user (`johndoe`, role `author`), then execs `php-fpm8.2` in the foreground as PID 1

**NGINX** (`requirements/nginx/`)
- Installs `nginx` + `openssl`
- Generates a self-signed TLS certificate at build time
- `conf/nginx.conf` listens only on 443 (TLSv1.2/1.3), proxies `.php` requests to `wordpress:9000` via FastCGI, serves static files directly from the shared `wp_data` volume

## Networking & volumes

- All three services sit on one Docker bridge network (`inception`), giving them DNS resolution by service name
- `wp_data` is mounted at `/var/www/wordpress` in **both** the WordPress and NGINX containers — this is what lets NGINX serve WordPress's actual theme/plugin/upload files (CSS, JS, images) directly, instead of 404s or stale content
- `db_data` persists MariaDB's data directory across container restarts

## Troubleshooting notes (real issues hit during development)

- **PHP-FPM socket vs TCP**: Debian's default PHP-FPM pool config listens on a Unix socket, which only works for processes on the same filesystem. Since NGINX and WordPress are separate containers, the pool config needed patching via `sed` to listen on `0.0.0.0:9000` (TCP) instead.
- **Docker Compose DNS**: hostnames like `wordpress` only resolve inside the `docker-compose.yml`-defined network. Testing a container standalone (`docker run` without compose) will correctly fail with "host not found" — that's expected, not a bug, if the upstream service name is referenced.
- **Idempotent setup**: `wp-setup.sh` checks for `wp-config.php` before running installation steps, so restarting the WordPress container doesn't wipe or reinitialize an existing site.
- **Version pinning**: Debian Bookworm ships PHP 8.2 by default (not 7.4) — always confirm actual installed binaries with `ls /usr/sbin/ | grep php-fpm` rather than assuming a version.

## Rebuilding from scratch

```bash
make fclean
docker compose -f srcs/docker-compose.yml build --no-cache
make up
```