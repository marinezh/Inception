# Developer Documentation - Inception

## Overview

This document explains how to set up, develop, and manage the Inception project from a developer's perspective.

---

## Environment Setup from Scratch

### Prerequisites

**Required Software:**
- Docker Engine 20.10 or higher
- Docker Compose v2.0 or higher
- GNU Make
- Git
- Text editor (vim, nano, VSCode, etc.)

**System Requirements:**
- Linux or macOS (tested on Debian/Ubuntu and macOS)
- At least 2GB free disk space
- Minimum 4GB RAM
- Internet connection (for initial image pulls and WordPress download)

### Installing Docker

**On Ubuntu/Debian:**
```bash
# Install Docker
curl -fsSL https://get.docker.com | sh

# Add user to docker group
sudo usermod -aG docker $USER

# Log out and back in for group changes to take effect

# Verify installation
docker --version
docker compose version
```

**On macOS:**
```bash
# Install Docker Desktop
brew install --cask docker

# Start Docker Desktop application

# Verify installation
docker --version
docker compose version
```

### Cloning the Repository

```bash
# Clone repository
git clone <repository-url> Inception
cd Inception

# Check structure
ls -la
```

Expected structure:
```
Inception/
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/
└── srcs/
```

---

## Configuration Files

### 1. Environment File (.env)

**Location:** `srcs/.env`

**Create from template:**
```bash
cp srcs/.env.example srcs/.env
```

**Edit configuration:**
```bash
nano srcs/.env
```

**Required variables:**
```bash
# Database Configuration
MYSQL_DATABASE=wordpress          # Database name
MYSQL_USER=wp_user               # Database user (not root)
MYSQL_HOST=mariadb               # Service name from docker-compose.yml

# WordPress Configuration
WP_URL=https://mzhivoto.42.fr    # Full site URL with https://
WP_TITLE=Inception Blog          # Site title
WP_ADMIN_USER=admin              # Admin username
WP_ADMIN_EMAIL=admin@example.com # Admin email

# Data Paths (customize for your system)
WORDPRESS_DATA_PATH=/home/mzhivoto/data/wordpress
MARIADB_DATA_PATH=/home/mzhivoto/data/mariadb

# SSL Certificate
DOMAIN_NAME=mzhivoto.42.fr       # Must match WP_URL domain
```

**Important notes:**
- Never commit `.env` to Git (already in .gitignore)
- `MYSQL_HOST` must match MariaDB service name in docker-compose.yml
- `DOMAIN_NAME` must match the domain in `WP_URL`
- Paths must be absolute, not relative

### 2. Secrets Files

**Location:** `secrets/`

**Required files:**
```
secrets/
├── db_password.txt         # WordPress database user password
├── db_root_password.txt    # MariaDB root password
├── wp_admin_password.txt   # WordPress admin password
└── wp_user_password.txt    # Secondary WordPress user password
```

**Create secrets:**
```bash
# Create secrets directory
mkdir -p secrets

# Generate strong passwords
echo "$(openssl rand -base64 16)" > secrets/db_password.txt
echo "$(openssl rand -base64 16)" > secrets/db_root_password.txt
echo "$(openssl rand -base64 16)" > secrets/wp_admin_password.txt
echo "$(openssl rand -base64 16)" > secrets/wp_user_password.txt

# Restrict permissions
chmod 600 secrets/*.txt
chmod 700 secrets/
```

**Security requirements:**
- Each file must contain only the password (no newlines or extra spaces)
- Files must not be committed to Git (.gitignore configured)
- Use strong, unique passwords for each secret
- Minimum 12 characters recommended

### 3. Docker Compose File

**Location:** `srcs/docker-compose.yml`

**Key sections:**

```yaml
services:
  mariadb:      # Database service
  wordpress:    # WordPress + PHP-FPM
  nginx:        # Web server

volumes:
  mariadb_data: # Database storage
  wp_files:     # WordPress files

networks:
  inception:    # Internal network

secrets:        # Secure credentials
  db_password:
  db_root_password:
  wp_admin_password:
  wp_user_password:
```

**Modification guidelines:**
- Service names are used for DNS (e.g., `mariadb:3306`)
- Only modify if you understand Docker Compose
- Backup before making changes
- Test changes: `docker compose config` to validate syntax

### 4. Domain Configuration

**Add domain to /etc/hosts:**
```bash
sudo nano /etc/hosts
```

**Add line:**
```
127.0.0.1 mzhivoto.42.fr
```

Or use your login:
```
127.0.0.1 yourlogin.42.fr
```

**Verify:**
```bash
ping mzhivoto.42.fr
```

Should resolve to 127.0.0.1

---

## Building and Launching

### Using Makefile (Recommended)

The Makefile provides convenient commands for common tasks:

**Build images:**
```bash
make build
```

**Start services:**
```bash
make up
# or simply
make
```

**Stop services:**
```bash
make down
```

**Clean containers:**
```bash
make clean
```

**Full cleanup (including volumes/data):**
```bash
make fclean
```

**Rebuild from scratch:**
```bash
make re
```

**View logs:**
```bash
make logs
```

### Using Docker Compose Directly

**Build images:**
```bash
cd srcs
docker compose build
```

**Start services (with build):**
```bash
docker compose up -d --build
```

**Stop services:**
```bash
docker compose down
```

**View logs:**
```bash
docker compose logs -f
```

**Rebuild specific service:**
```bash
docker compose build nginx
docker compose up -d nginx
```

### Build Process Explained

**What happens during `make up`:**

1. **Prepare data directories** (`prepare-dirs` target)
   - Creates `/home/mzhivoto/data/mariadb`
   - Creates `/home/mzhivoto/data/wordpress`
   - Sets correct permissions

2. **Build Docker images** (if not cached)
   - Builds `mariadb:42` from `requirements/mariadb/Dockerfile`
   - Builds `wordpress:42` from `requirements/wordpress/Dockerfile`
   - Builds `nginx:42` from `requirements/nginx/Dockerfile`

3. **Create Docker network**
   - Creates `srcs_inception` bridge network

4. **Create Docker volumes**
   - Creates `srcs_mariadb_data` (bind to host path)
   - Creates `srcs_wp_files` (bind to host path)

5. **Start containers in order**
   - MariaDB starts first
   - WordPress waits for MariaDB health check
   - NGINX waits for WordPress health check

6. **Service initialization** (first run only)
   - MariaDB: Initialize database, create users
   - WordPress: Download WordPress, install, create users
   - NGINX: Generate SSL certificate

### Build Optimization

**Use build cache:**
```bash
docker compose build
```

**Force rebuild (no cache):**
```bash
docker compose build --no-cache
```

**Build specific service:**
```bash
docker compose build mariadb
```

**Parallel builds:**
```bash
docker compose build --parallel
```

---

## Container Management Commands

### Basic Container Operations

**List running containers:**
```bash
docker ps
```

**List all containers (including stopped):**
```bash
docker ps -a
```

**Start a stopped container:**
```bash
docker start nginx
```

**Stop a container:**
```bash
docker stop nginx
```

**Restart a container:**
```bash
docker restart nginx
```

**Remove a container:**
```bash
docker rm nginx
```

**Remove all stopped containers:**
```bash
docker container prune
```

### Inspecting Containers

**View container details:**
```bash
docker inspect nginx
```

**View container logs:**
```bash
docker logs nginx
docker logs -f nginx          # Follow logs
docker logs --tail=50 nginx   # Last 50 lines
docker logs --since=1h nginx  # Last hour
```

**View container processes:**
```bash
docker top nginx
```

**View container resource usage:**
```bash
docker stats
docker stats nginx  # Specific container
```

**Execute commands in container:**
```bash
docker exec nginx ls -la /etc/nginx
docker exec -it nginx /bin/sh     # Interactive shell
docker exec nginx nginx -t         # Test nginx config
```

### Container Health and Status

**Check health status:**
```bash
docker inspect --format='{{.State.Health.Status}}' mariadb
```

**View health check logs:**
```bash
docker inspect --format='{{range .State.Health.Log}}{{.Output}}{{end}}' mariadb
```

**Wait for container to be healthy:**
```bash
docker compose up -d mariadb
docker compose ps mariadb | grep "healthy"
```

---

## Volume Management

### Understanding Project Volumes

**Two volumes are used:**

1. **mariadb_data** - Database files
   - Container path: `/var/lib/mysql`
   - Host path: `/home/mzhivoto/data/mariadb`
   - Contains: MySQL database files

2. **wp_files** - WordPress files
   - Container path: `/var/www/html`
   - Host path: `/home/mzhivoto/data/wordpress`
   - Contains: WordPress core, themes, plugins, uploads

### Volume Commands

**List volumes:**
```bash
docker volume ls
```

**Inspect volume:**
```bash
docker volume inspect srcs_mariadb_data
docker volume inspect srcs_wp_files
```

**View volume contents:**
```bash
# Via host filesystem (since we use bind mounts)
ls -la /home/mzhivoto/data/mariadb
ls -la /home/mzhivoto/data/wordpress

# Or via container
docker exec mariadb ls -la /var/lib/mysql
docker exec wordpress ls -la /var/www/html
```

**Check volume size:**
```bash
du -sh /home/mzhivoto/data/mariadb
du -sh /home/mzhivoto/data/wordpress
```

**Backup volume:**
```bash
# Backup database
docker exec mariadb mariadb-dump -u root -p"$(cat secrets/db_root_password.txt)" wordpress > backup.sql

# Backup WordPress files
tar -czf wordpress_backup.tar.gz /home/mzhivoto/data/wordpress
```

**Restore volume:**
```bash
# Restore database
cat backup.sql | docker exec -i mariadb mariadb -u root -p"$(cat secrets/db_root_password.txt)" wordpress

# Restore WordPress files
tar -xzf wordpress_backup.tar.gz -C /
```

**Clean volumes:**
```bash
# WARNING: This deletes all data!
make fclean

# Or manually
docker compose down -v
sudo rm -rf /home/mzhivoto/data/mariadb/*
sudo rm -rf /home/mzhivoto/data/wordpress/*
```

### Data Persistence

**How data persists:**

1. **Container deleted** → Data remains in volumes
2. **`docker compose down`** → Data remains
3. **`docker compose down -v`** → Volumes deleted, data lost
4. **`make fclean`** → Everything deleted including data

**Data locations:**
```
Host filesystem:
/home/mzhivoto/data/
├── mariadb/           # Database files
│   ├── mysql/
│   ├── wordpress/     # Your WordPress database
│   └── ...
└── wordpress/         # WordPress files
    ├── wp-content/    # Themes, plugins, uploads
    ├── wp-config.php  # WordPress configuration
    └── ...
```

---

## Network Management

### Understanding Project Network

**Network name:** `srcs_inception`  
**Type:** Bridge network  
**Purpose:** Connect containers for internal communication

**Network topology:**
```
Host (port 443)
    ↓
NGINX:443 (external)
    ↓
WordPress:9000 (internal)
    ↓
MariaDB:3306 (internal)
```

### Network Commands

**List networks:**
```bash
docker network ls
```

**Inspect network:**
```bash
docker network inspect srcs_inception
```

**View connected containers:**
```bash
docker network inspect srcs_inception --format='{{range .Containers}}{{.Name}} {{end}}'
```

**Test connectivity between containers:**
```bash
# From WordPress to MariaDB
docker exec wordpress ping -c 3 mariadb

# From NGINX to WordPress
docker exec nginx nc -zv wordpress 9000
```

**View container network settings:**
```bash
docker inspect nginx --format='{{.NetworkSettings.Networks}}'
```

---

## Development Workflow

### Making Changes

**Modify Dockerfile:**
```bash
# Edit file
nano srcs/requirements/nginx/Dockerfile

# Rebuild specific service
docker compose build nginx

# Restart service
docker compose up -d nginx
```

**Modify configuration files:**
```bash
# Edit nginx.conf
nano srcs/requirements/nginx/conf/nginx.conf

# Restart to apply changes
docker restart nginx
```

**Modify entrypoint scripts:**
```bash
# Edit script
nano srcs/requirements/wordpress/tools/wordpress.sh

# Rebuild and restart
docker compose build wordpress
docker compose up -d wordpress
```

### Debugging

**Check container logs:**
```bash
docker logs -f wordpress
```

**Access container shell:**
```bash
docker exec -it wordpress /bin/sh
```

**Test configurations:**
```bash
# Test nginx config
docker exec nginx nginx -t

# Test PHP-FPM
docker exec wordpress php-fpm8.2 -t

# Test database connection
docker exec wordpress wp db check --allow-root
```

**View environment variables:**
```bash
docker exec wordpress env
```

**Check file permissions:**
```bash
docker exec wordpress ls -la /var/www/html
docker exec mariadb ls -la /var/lib/mysql
```

### Testing Changes

**Test SSL/TLS:**
```bash
openssl s_client -connect mzhivoto.42.fr:443 -tls1_3
```

**Test HTTP connection:**
```bash
curl -Ik https://mzhivoto.42.fr
```

**Test PHP-FPM:**
```bash
docker exec wordpress ps aux | grep php-fpm
```

**Test database:**
```bash
docker exec mariadb mariadb-admin ping
```

---

## Image Management

### Working with Images

**List images:**
```bash
docker images
```

**Remove image:**
```bash
docker rmi nginx:42
```

**Remove all project images:**
```bash
docker rmi mariadb:42 wordpress:42 nginx:42
```

**Remove dangling images:**
```bash
docker image prune
```

**Remove all unused images:**
```bash
docker image prune -a
```

**Check image size:**
```bash
docker images | grep ":42"
```

**View image layers:**
```bash
docker history nginx:42
```

---

## Advanced Topics

### Custom Build Arguments

**Pass build arguments:**
```yaml
# In docker-compose.yml
services:
  nginx:
    build:
      context: ./requirements/nginx
      args:
        NGINX_VERSION: 1.24
```

### Multi-Stage Builds (if needed)

Not currently used in this project, but can be added:

```dockerfile
# Builder stage
FROM debian:bookworm AS builder
RUN apt-get update && apt-get install -y build-essential
# ... build steps ...

# Final stage
FROM debian:bookworm
COPY --from=builder /app/binary /usr/local/bin/
```

### Docker Compose Profiles

Add profiles for different environments:

```yaml
services:
  debug-tool:
    image: nicolaka/netshoot
    profiles: ["debug"]
    networks:
      - inception
```

Run with: `docker compose --profile debug up`

### Healthcheck Customization

Modify healthchecks in docker-compose.yml:

```yaml
healthcheck:
  test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
  interval: 10s      # Check every 10 seconds
  timeout: 5s        # Timeout after 5 seconds
  retries: 3         # Retry 3 times
  start_period: 30s  # Wait 30s before first check
```

---

## Troubleshooting for Developers

### Build Failures

**Error: Cannot download packages**
```bash
# Check internet connection
ping 8.8.8.8

# Check DNS
docker run --rm busybox nslookup google.com

# Try with DNS server
docker build --network=host .
```

**Error: No space left on device**
```bash
# Clean up Docker
docker system prune -a --volumes

# Check disk space
df -h
```

**Error: Permission denied**
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Restart shell or log out/in
```

### Runtime Issues

**Container exits immediately:**
```bash
# Check logs
docker logs <container>

# Check exit code
docker inspect <container> --format='{{.State.ExitCode}}'
```

**Service not reachable:**
```bash
# Check if container is running
docker ps | grep nginx

# Check port mapping
docker port nginx

# Check network
docker network inspect srcs_inception
```

**Volume mount issues:**
```bash
# Check volume exists
docker volume ls | grep srcs

# Check permissions
ls -la /home/mzhivoto/data/

# Fix permissions
sudo chown -R $USER:$USER /home/mzhivoto/data/
```

### Performance Issues

**High CPU usage:**
```bash
# Check which container
docker stats

# Check processes
docker top <container>
```

**High memory usage:**
```bash
# Check memory
docker stats

# Set memory limits in docker-compose.yml
services:
  nginx:
    mem_limit: 512m
```

**Slow builds:**
```bash
# Use build cache
docker compose build

# Clean and rebuild
docker builder prune
docker compose build --no-cache
```

---

## Best Practices for Development

### Code Organization

- ✅ Keep Dockerfiles simple and readable
- ✅ Use `.dockerignore` to exclude unnecessary files
- ✅ One service per container
- ✅ Use multi-stage builds for complex builds
- ✅ Comment your code and configurations

### Configuration Management

- ✅ Use environment variables for configuration
- ✅ Use Docker secrets for sensitive data
- ✅ Keep `.env.example` updated
- ✅ Never commit secrets to Git
- ✅ Document all configuration options

### Testing

- ✅ Test builds locally before committing
- ✅ Test with clean volumes (`make fclean && make`)
- ✅ Verify healthchecks work
- ✅ Test error scenarios
- ✅ Check logs for warnings/errors

### Version Control

- ✅ Commit often with clear messages
- ✅ Use branches for new features
- ✅ Keep `.gitignore` updated
- ✅ Don't commit generated files
- ✅ Review changes before committing

---

## Useful Commands Reference

### Quick Command Cheatsheet

```bash
# Start everything
make

# Stop everything
make down

# Clean everything
make fclean

# View logs
make logs

# Rebuild
make re

# Access container shell
docker exec -it <container> /bin/sh

# View container logs
docker logs -f <container>

# Check status
docker ps

# Check resource usage
docker stats

# Backup database
docker exec mariadb mariadb-dump -u root -p"$(cat secrets/db_root_password.txt)" wordpress > backup.sql

# Access MySQL
docker exec -it mariadb mariadb -u root -p"$(cat secrets/db_root_password.txt)"

# WordPress CLI
docker exec wordpress wp --allow-root <command>
```

---

## Additional Resources for Developers

### Documentation

- **Docker Documentation:** https://docs.docker.com/
- **Docker Compose:** https://docs.docker.com/compose/
- **Dockerfile Reference:** https://docs.docker.com/engine/reference/builder/
- **NGINX Documentation:** https://nginx.org/en/docs/
- **PHP-FPM:** https://www.php.net/manual/en/install.fpm.php
- **MariaDB:** https://mariadb.com/kb/en/documentation/
- **WordPress Developer:** https://developer.wordpress.org/
- **WP-CLI:** https://wp-cli.org/

### Tools

- **Docker Desktop:** Visual interface for Docker
- **Portainer:** Web-based Docker management
- **Dive:** Tool to inspect Docker image layers
- **ctop:** Top-like interface for containers

---

*For user-facing documentation, see USER_DOC.md*
