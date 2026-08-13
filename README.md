*This project has been created as part of the 42 curriculum by machaouk.*

# Inception

## Description

Inception is a system administration project that builds a small web infrastructure entirely
with Docker, from scratch — no pre-built Docker Hub service images allowed. Every service runs
in its own container, built from a `debian:bookworm` base image, and containers are orchestrated
together with Docker Compose.

The goal is to end up with a working, secure WordPress website served over HTTPS, backed by a
database, plus a set of bonus services that extend the infrastructure. Beyond making it work,
the project is about understanding *why* each piece is configured the way it is — networking,
process management, secrets, persistence — well enough to explain and defend it.

**Stack:**
- **MariaDB** — database, stores WordPress data
- **WordPress** (PHP-FPM + wp-cli) — the website itself
- **NGINX** — the only entry point, TLS-only on port 443
- **Bonus:** Redis (WordPress object cache), Adminer (DB admin UI), a static website, Portainer
  (Docker management UI), FTP server (vsftpd)

```
Browser ──HTTPS(443)──▶ NGINX ──FastCGI──▶ WordPress (PHP-FPM) ──▶ MariaDB
                                                  │
                                                  ▼
                                                Redis
```

All containers communicate over a single custom Docker bridge network (`inception`). Data that
must survive a container restart (database files, WordPress files) is stored on the host under
`/home/machaouk/data/` and mounted into containers as bind-mount volumes.

## Instructions

### Requirements
- Docker & Docker Compose installed
- `machaouk.42.fr` resolving to `127.0.0.1` (add it to `/etc/hosts` on the host you're browsing from)

### Setup
1. Fill in `srcs/.env` with your domain, database, and WordPress credentials (see `DEV_DOC.md`
   for the full list of variables).
2. From the project root:
   ```bash
   make
   ```
4. Visit `https://machaouk.42.fr` in a browser.

See `USER_DOC.md` for day-to-day usage and `DEV_DOC.md` for full setup/build/debugging details.

## Project Description: Docker & Design Choices

Every service is built from `debian:bookworm` — nothing is pulled as a ready-made service image.
Each Dockerfile installs only the packages that service needs, copies in its configuration and
an entrypoint script, and ends by `exec`-ing the main process so it runs as PID 1 (no supervisors,
no `sleep infinity`, no `tail -f` tricks). Containers are wired together with Docker Compose,
which builds each image, attaches every container to the same custom bridge network, injects
configuration from `.env`, and mounts the bind-mount volumes.

### Virtual Machines vs Docker
A VM virtualizes an entire computer, including its own kernel — it's heavy, slow to boot, and
fully isolated. A Docker container shares the host's kernel and only isolates the process itself
(via namespaces/cgroups), so it's lightweight and starts in seconds. Inception uses Docker
because the goal is to run several small, cleanly separated services fast, not to virtualize
full machines.

### Secrets vs Environment Variables
Environment variables set via `.env`/`environment:` end up visible in `docker inspect`, in the
container's process environment, and often in logs — anyone with access to the host or the
Compose file can read them. Docker **secrets**, by contrast, are mounted as read-only files
(typically under `/run/secrets/`) that only the container using them can access, and are never
shown by `docker inspect` or baked into image layers — that's the more secure approach for real
production credentials.

This project keeps all configuration, including passwords, in a single `srcs/.env` file (not
committed to the repository) rather than using Docker secrets. This was a deliberate trade-off
for simplicity: it's easier to manage one file, but it's weaker than the secrets approach since
those values are readable via `docker inspect` and sit in the container's environment.

### Docker Network vs Host Network
With `network: host`, a container shares the host's network stack directly — no isolation, and
ports collide with whatever else is running on the host. A custom Docker **bridge** network gives
containers their own private network with internal DNS: each container can reach another by its
service name (e.g. WordPress connects to `mariadb:3306`), while the host only exposes what's
explicitly published (here, only NGINX's port 443). This project uses a dedicated bridge network
(`inception`) for isolation and clean service discovery.

### Docker Volumes vs Bind Mounts
A **bind mount** maps a host path directly onto a container path inline on the service — Docker
doesn't manage or track it at all. A **named volume** is declared under the top-level `volumes:`
key and is a real object Docker manages.


## Resources

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose file reference](https://docs.docker.com/compose/compose-file/)
- [Docker secrets documentation](https://docs.docker.com/engine/swarm/secrets/)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)
- [WordPress wp-cli documentation](https://wp-cli.org/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [vsftpd documentation](https://security.appspot.com/vsftpd.html)
- [Redis documentation](https://redis.io/docs/)
- [Portainer documentation](https://docs.portainer.io/)

**AI usage:** was used as a learning and debugging aid throughout the project —
explaining, reviewing Dockerfiles and shell scripts for mistakes.
All configuration files and scripts were written, tested, and
understood by the author; AI was not used to generate the final infrastructure blindly.