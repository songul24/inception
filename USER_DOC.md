# User Documentation

This document explains how to use the Inception stack once it's running: what it provides, how
to start/stop it, how to access things, and how to check it's healthy.

## 1. What services does this stack provide?

| Service | What it does | How you access it |
|---|---|---|
| **WordPress + NGINX** | The website | `https://machaouk.42.fr` |
| **MariaDB** | Database (internal only, not exposed to the browser) | Used by WordPress/Adminer internally |
| **Adminer** *(bonus)* | Web UI to browse/edit the database | `https://machaouk.42.fr/adminer/` |
| **Portainer** *(bonus)* | Web UI to manage Docker containers | `https://machaouk.42.fr/portainer/` |
| **Static website** *(bonus)* | A simple extra site, independent of WordPress | `https://machaouk.42.fr/static/` |
| **Redis** *(bonus)* | Speeds up WordPress by caching database queries | Internal only, not accessed directly |
| **FTP** *(bonus)* | Upload/download WordPress files remotely | Any FTP client, port 21 |

> Ports above are examples — check `srcs/docker-compose.yml` for the exact ports mapped on your
> setup if any have been changed.

## 2. Starting and stopping the project

From the project root:

```bash
make          # build images (if needed) and start everything
make down     # stop and remove containers (keeps your data)
make re       # stop everything and start it again from scratch (rebuild)
```

Check everything is up:
```bash
docker compose -f srcs/docker-compose.yml ps
```
All services should show state `Up` (or `running`/`healthy`).

## 3. Accessing the website and admin panel

- **Website:** open `https://machaouk.42.fr` in a browser. The certificate is self-signed, so
  the browser will warn you the first time — accept/continue to proceed.
- **WordPress admin panel:** go to `https://machaouk.42.fr/wp-admin`.
  - Log in with the **administrator** account (username does **not** contain "admin", per
    project rules — check `srcs/.env` for the actual username).
  - A second, non-admin **author** account is also created for regular content editing.

## 4. Locating and managing credentials

All credentials (database, WordPress accounts, FTP) live in a single file: **`srcs/.env`**.
This file is not committed to the repository — keep it private and back it up separately.

- **Database:** `MYSQL_USER` / `MYSQL_PASSWORD`, and `MYSQL_ROOT_PASSWORD` for root access.
- **WordPress:** `WP_ADMIN_USER` / `WP_ADMIN_PASSWORD` (administrator), and
  `WP_USER` / `WP_PASSWORD` (author).
- **FTP:** `FTP_USER` / `FTP_PASSWORD`.


## 5. Checking that services are running correctly

```bash
# Are all containers up?
docker compose -f srcs/docker-compose.yml ps

# Watch logs for one service (e.g. wordpress)
docker compose -f srcs/docker-compose.yml logs -f wordpress

# Quick health checks
curl -Ik https://machaouk.42.fr                 # expect HTTP/2 200
docker exec mariadb mariadb -u root -p"$MYSQL_ROOT_PASSWORD" -e "SHOW DATABASES;"
```

If the website doesn't load:
1. Confirm `machaouk.42.fr` resolves (check `/etc/hosts` if testing locally).
2. Confirm the `nginx` container is `Up` and port 443 is published (`docker ps`).
3. Check `docker compose logs nginx` and `docker compose logs wordpress` for errors.

For deeper debugging and how the pieces fit together, see `DEV_DOC.md`.