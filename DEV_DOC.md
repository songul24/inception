# Developer Documentation

This document explains how to set up, build, and manage the Inception infrastructure as a
developer.

## 1. Project layout

```
inception/
├── Makefile
└── srcs/
    ├── .env                         # all config, including passwords (not committed)
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        ├── nginx/
        ├── wordpress/
        └── bonus/
            ├── adminer/
            ├── ftp/
            ├── portainer/
            ├── redis/
            └── static_website/
```

## 2. Setting up the environment from scratch

### 2.1 Prerequisites
- Linux host (or VM) with Docker Engine + Docker Compose plugin installed.
- `machaouk.42.fr` resolving to `127.0.0.1` — add this to `/etc/hosts` on any machine you'll
  browse from:
  ```
  127.0.0.1 machaouk.42.fr
  ```

### 2.2 Configuration & credentials (`srcs/.env`)
All configuration, including passwords, lives in a single `srcs/.env` file. It is **not**
committed to the repository — create it locally before building:

```bash
DOMAIN_NAME=machaouk.42.fr

MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
MYSQL_PASSWORD=changeme
MYSQL_ROOT_PASSWORD=changeme

WP_ADMIN_USER=superuser        # must NOT contain "admin"
WP_ADMIN_PASSWORD=changeme
WP_USER=malika
WP_PASSWORD=changeme

FTP_USER=ftpuser
FTP_PASSWORD=changeme
```

Entrypoint scripts (`init.sh`, `wp-setup.sh`, etc.) read these directly as environment variables
via Docker Compose's `env_file: srcs/.env`.

## 3. Build and launch

Everything is driven by the Makefile, which wraps Docker Compose:

```bash
make            # build all images and start containers (detached)
make down       # stop and remove containers, keep volumes/data
make clean      # down + remove built images
make fclean     # clean + remove data under /home/machaouk/data/
make re         # fclean + make (full rebuild from a clean state)
```

Equivalent raw Compose commands, if needed directly:
```bash
docker compose -f srcs/docker-compose.yml up -d --build
docker compose -f srcs/docker-compose.yml down
docker compose -f srcs/docker-compose.yml down -v
```

> `docker compose down -v` removes named volumes but does **not** delete the underlying host
> directories they're backed by — clean those manually (`sudo rm -rf /home/machaouk/data/*`).

## 4. Managing containers and volumes

```bash
docker compose -f srcs/docker-compose.yml ps            # status of all services
docker compose -f srcs/docker-compose.yml logs -f nginx  # follow logs for one service
docker exec -it wordpress bash                            # shell into a running container
docker volume ls                                           # list volumes
```

Rebuilding a single service after editing its Dockerfile:
```bash
docker compose -f srcs/docker-compose.yml up -d --build wordpress
```

## 5. Where data is stored / how it persists

All persistent data lives on the host under `/home/machaouk/data/`. Each service has a named
volume (declared under the top-level `volumes:` key) whose `driver_opts` point the `local`
driver at a specific host path instead of Docker's default volume location:

```yaml
volumes:
  db_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/machaouk/data/mariadb
  wp_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/machaouk/data/wordpress
  # rd_data, por_data follow the same pattern
```

| Named volume | Host path | Mounted into | Contains |
|---|---|---|---|
| `db_data` | `/home/machaouk/data/mariadb/` | `mariadb:/var/lib/mysql` | Database files |
| `wp_data` | `/home/machaouk/data/wordpress/` | `wordpress:/var/www/html` | WordPress core, themes, plugins, uploads |
| `rd_data` | `/home/machaouk/data/redis/` | `redis:/data` | Redis persistence files |
| `por_data` | `/home/machaouk/data/portainer/` | `portainer:/data` | Portainer settings/state |

Because each volume is backed by a specific host path (rather than Docker's default
`/var/lib/docker/volumes/...` location), you can inspect this data directly from the host without
going through Docker — e.g. `ls /home/machaouk/data/wordpress/`. It's still a real Docker-managed
volume (visible in `docker volume ls`), it's just not stored where Docker would put it by
default. Data survives
`docker compose down` and container rebuilds; it is only lost if you manually delete the host
directory (as `make fclean` does on purpose).
