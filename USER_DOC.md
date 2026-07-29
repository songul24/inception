# User Documentation

## Accessing the site

Once `make up` has finished and all three containers are running, visit: https://machaouk.42.fr

If testing locally (not on a machine with real DNS for this domain), add this line to `/etc/hosts` first: 127.0.0.1 machaouk.42.fr

The certificate is self-signed, so your browser will show a security warning on first visit — this is expected for a project environment with no real Certificate Authority. Accept the warning to proceed.

## Logging in

Go to `https://machaouk.42.fr/wp-login.php`.

**Administrator account**
- Username: `superadmin`
- Password: stored in `secrets/wp_admin_password.txt`

**Standard (non-admin) account**
- Username: `johndoe`
- Role: Author (can write/manage their own posts, no site administration access)
- Password: stored in `secrets/wp_user_password.txt`

## Common commands

| Command | What it does |
|---|---|
| `make up` | Build (if needed) and start all containers |
| `make down` | Stop and remove containers, keep data |
| `make stop` | Pause containers without removing them |
| `make start` | Resume previously stopped containers |
| `make clean` | Stop containers, prune unused Docker images/cache |
| `make fclean` | Full teardown: containers, images, and all volume data |
| `make re` | Full clean rebuild from nothing |

## Checking container status

```bash
docker compose -f srcs/docker-compose.yml ps
docker compose -f srcs/docker-compose.yml logs -f
```