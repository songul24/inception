# User Documentation

## Services

The project provides:

- **WordPress** — main website.
- **NGINX** — HTTPS access.
- **MariaDB** — database.
- **Redis** — WordPress cache.
- **FTP** — file transfer.
- **Portainer** — Docker management.
- **Adminer** — database management.
- **Static Website** — additional website.

## Start and Stop

Start:

```bash
make up
```

Stop:

```bash
make stop
```

Remove containers while keeping data:

```bash
make down
```

Full cleanup:

```bash
make fclean
```

Full rebuild:

```bash
make re
```

## Website

Add this to `/etc/hosts` for local testing:

```text
127.0.0.1 machaouk.42.fr
```

Website:

```text
https://machaouk.42.fr
```

The certificate is self-signed, so the browser will show a security warning.

## WordPress Administration

```text
https://machaouk.42.fr/wp-login.php
```

### Administrator

```text
Username: superadmin
Password: secrets/wp_admin_password.txt
```

### Normal User

```text
Username: johndoe
Role: Author
Password: secrets/wp_user_password.txt
```

## Credentials

Database and WordPress passwords are stored in:

```text
secrets/
├── db_password.txt
├── db_root_password.txt
├── wp_admin_password.txt
└── wp_user_password.txt
```

## Bonus Services

### Redis

Redis caches WordPress objects in memory. Its connection can be checked from the WordPress Redis Object Cache plugin.

### FTP

FTP allows files to be uploaded and downloaded.

```text
Port 21           → control
21100-21110       → passive data
```

### Portainer

Portainer provides a web interface for managing Docker containers, images, volumes and networks.

### Adminer

Adminer provides a web interface for connecting to and managing the MariaDB database.

### Static Website

The static website is an additional website separate from WordPress.

## Checking the Stack

```bash
docker compose -f srcs/docker-compose.yml ps
```

View logs:

```bash
docker compose -f srcs/docker-compose.yml logs -f
```

The containers should show a running/healthy state according to their configuration.