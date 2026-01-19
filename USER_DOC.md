# User Documentation - Inception

## Overview

This document explains how to use the Inception web infrastructure as an end user or system administrator.

---

## Services Provided

The Inception stack provides a complete WordPress website with the following services:

### 1. **WordPress Website**
- **Purpose:** Content management system for creating and managing website content
- **Access:** https://mzhivoto.42.fr
- **Features:**
  - Blog posts and pages
  - Media library
  - User management
  - Theme customization
  - Plugin support

### 2. **WordPress Admin Panel**
- **Purpose:** Administrative interface for managing the website
- **Access:** https://mzhivoto.42.fr/wp-admin
- **Features:**
  - Create/edit posts and pages
  - Manage users and permissions
  - Install themes and plugins
  - Configure site settings
  - View site statistics

### 3. **NGINX Web Server**
- **Purpose:** Secure HTTPS web server
- **Features:**
  - TLS 1.2/1.3 encryption
  - Static file serving
  - Reverse proxy to WordPress
  - SSL certificate management

### 4. **MariaDB Database**
- **Purpose:** Data storage for WordPress
- **Stores:**
  - Posts and pages content
  - User accounts and permissions
  - Site settings and options
  - Comments and metadata

### 5. **PHP-FPM**
- **Purpose:** PHP processor for WordPress
- **Features:**
  - Executes WordPress PHP code
  - Handles dynamic content generation
  - Manages PHP sessions

---

## Starting and Stopping the Project

### Starting the Services

**Method 1: Using Make (Recommended)**
```bash
cd /path/to/Inception
make
```

This command will:
1. Create necessary data directories
2. Build Docker images if needed
3. Start all services in the background
4. Wait for services to be healthy

**Method 2: Manual Docker Compose**
```bash
cd /path/to/Inception/srcs
docker compose up -d
```

**What happens during startup:**
1. MariaDB starts and initializes database (first time only)
2. WordPress downloads and configures (first time only)
3. NGINX generates SSL certificate (first time only)
4. All services become available

**Startup time:** 
- First run: 2-3 minutes (downloads WordPress, initializes DB)
- Subsequent runs: 10-30 seconds

### Stopping the Services

**Stop all services:**
```bash
make down
```

Or:
```bash
cd srcs
docker compose down
```

**What this does:**
- Stops all running containers
- Removes containers
- Preserves data volumes (your content is safe)

**Stop and remove everything (including data):**
```bash
make fclean
```

⚠️ **Warning:** This deletes all data including posts, users, and database!

### Restarting Services

**Restart all services:**
```bash
make down
make up
```

**Restart a single service:**
```bash
docker restart nginx
docker restart wordpress
docker restart mariadb
```

### Checking Status

**See which services are running:**
```bash
docker ps
```

Expected output:
```
CONTAINER ID   IMAGE            STATUS         PORTS
abc123...      nginx:42         Up 5 minutes   0.0.0.0:443->443/tcp
def456...      wordpress:42     Up 5 minutes   9000/tcp
ghi789...      mariadb:42       Up 5 minutes   3306/tcp
```

---

## Accessing the Website

### Website Access

**URL:** https://mzhivoto.42.fr

**First Visit:**
Your browser will show a security warning because the SSL certificate is self-signed.

**To proceed:**
- **Chrome/Edge:** Click "Advanced" → "Proceed to mzhivoto.42.fr (unsafe)"
- **Firefox:** Click "Advanced" → "Accept the Risk and Continue"
- **Safari:** Click "Show Details" → "visit this website"

This is normal for local development with self-signed certificates.

### Administration Panel Access

**URL:** https://mzhivoto.42.fr/wp-admin

**Default Credentials:**
- **Username:** Check your `.env` file for `WP_ADMIN_USER`
- **Password:** Located in `secrets/wp_admin_password.txt`

**To log in:**
1. Navigate to https://mzhivoto.42.fr/wp-admin
2. Enter your admin username
3. Enter your admin password
4. Click "Log In"

### Additional WordPress User

A secondary user account is also available:
- **Username:** editor
- **Role:** Editor (can create/edit posts but not change settings)
- **Password:** Located in `secrets/wp_user_password.txt`

---

## Managing Credentials

### Credential Storage

All passwords are stored securely in the `secrets/` directory:

```
secrets/
├── db_password.txt         # WordPress database user password
├── db_root_password.txt    # MariaDB root password
├── wp_admin_password.txt   # WordPress admin panel password
└── wp_user_password.txt    # Secondary WordPress user password
```

### Viewing Credentials

**View admin password:**
```bash
cat secrets/wp_admin_password.txt
```

**View database root password:**
```bash
cat secrets/db_root_password.txt
```

### Changing Credentials

⚠️ **Important:** Changing passwords after initial setup requires multiple steps.

**To change WordPress admin password:**

1. **Method 1: Via WordPress Admin Panel (Easiest)**
   - Log in to wp-admin
   - Go to Users → Your Profile
   - Scroll to "New Password"
   - Generate and save new password
   - Update `secrets/wp_admin_password.txt` with new password

2. **Method 2: Via WP-CLI**
   ```bash
   # Update password
   docker exec wordpress wp user update admin --user_pass="newpassword" --allow-root
   
   # Update secret file
   echo "newpassword" > secrets/wp_admin_password.txt
   ```

**To change database passwords:**

⚠️ **Not recommended after initial setup** - requires:
1. Updating secret files
2. Recreating database
3. Reimporting data
4. Reconfiguring WordPress

If absolutely necessary:
```bash
make fclean  # Destroys all data!
# Update secrets/db_password.txt
make        # Recreate everything
```

### Security Best Practices

**DO:**
- ✅ Keep secrets/ directory permissions restricted: `chmod 700 secrets/`
- ✅ Never commit secrets to Git (.gitignore already configured)
- ✅ Use strong, unique passwords
- ✅ Change default passwords before deployment
- ✅ Backup secrets separately from data

**DON'T:**
- ❌ Share passwords via email or chat
- ❌ Use the same password for multiple services
- ❌ Store passwords in .env file (use secrets/ only)
- ❌ Commit secrets to version control

---

## Checking Service Status

### Quick Health Check

**Check all containers are running:**
```bash
docker ps
```

All three containers (nginx, wordpress, mariadb) should show "Up" status.

**Check logs for errors:**
```bash
make logs
```

Or for specific service:
```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

### Detailed Service Checks

#### NGINX Status

**Check NGINX is responding:**
```bash
curl -Ik https://mzhivoto.42.fr
```

Expected: `HTTP/2 200` or `HTTP/2 301`

**Check SSL certificate:**
```bash
docker exec nginx openssl x509 -in /etc/nginx/ssl/server.crt -noout -subject
```

Expected: Subject with `CN=mzhivoto.42.fr`

**Check configuration:**
```bash
docker exec nginx nginx -t
```

Expected: `configuration file ... test is successful`

#### WordPress Status

**Check PHP-FPM is running:**
```bash
docker exec wordpress ps aux | grep php-fpm
```

Should show php-fpm processes.

**Check WordPress installation:**
```bash
docker exec wordpress ls -la /var/www/html/wp-config.php
```

Should show the file exists.

**Check database connectivity:**
```bash
docker exec wordpress wp db check --allow-root
```

Expected: `Success: Database connection is working`

#### MariaDB Status

**Check database is accepting connections:**
```bash
docker exec mariadb mariadb-admin ping -h localhost
```

Expected: `mysqld is alive`

**Check databases exist:**
```bash
docker exec mariadb mariadb -u root -p"$(cat secrets/db_root_password.txt)" -e "SHOW DATABASES;"
```

Should show `wordpress` database.

**Check WordPress tables:**
```bash
docker exec mariadb mariadb -u root -p"$(cat secrets/db_root_password.txt)" wordpress -e "SHOW TABLES;"
```

Should list WordPress tables (wp_posts, wp_users, etc.)

### Performance Monitoring

**Check resource usage:**
```bash
docker stats
```

Shows CPU, memory, network usage for all containers.

**Check disk usage:**
```bash
docker system df
```

Shows space used by images, containers, and volumes.

---

## Common Issues and Solutions

### Issue: Website not accessible

**Symptoms:** Browser shows "This site can't be reached"

**Solutions:**
1. Check containers are running: `docker ps`
2. Check domain in /etc/hosts: `grep mzhivoto.42.fr /etc/hosts`
3. Check port 443 is accessible: `sudo lsof -i :443`
4. Check firewall isn't blocking port 443

### Issue: Database connection error

**Symptoms:** WordPress shows "Error establishing database connection"

**Solutions:**
1. Check MariaDB is running: `docker ps | grep mariadb`
2. Wait 30 seconds for MariaDB to be ready
3. Check logs: `docker logs mariadb`
4. Verify credentials match:
   ```bash
   docker exec mariadb mariadb -u wp_user -p"$(cat secrets/db_password.txt)" wordpress
   ```

### Issue: SSL certificate errors

**Symptoms:** Browser shows "NET::ERR_CERT_AUTHORITY_INVALID"

**Solutions:**
- This is normal for self-signed certificates
- Click "Advanced" and proceed anyway (safe for local development)
- Or regenerate certificate:
  ```bash
  docker exec nginx rm -f /etc/nginx/ssl/server.*
  docker restart nginx
  ```

### Issue: Changes not appearing

**Symptoms:** Code/config changes don't take effect

**Solutions:**
1. Rebuild containers: `make re`
2. Clear browser cache (Ctrl+Shift+R / Cmd+Shift+R)
3. Check you're editing the right files (in bind-mounted volumes)

### Issue: Port 443 already in use

**Symptoms:** Error: "port is already allocated"

**Solutions:**
1. Find what's using port 443: `sudo lsof -i :443`
2. Stop conflicting service:
   ```bash
   sudo systemctl stop apache2  # If Apache is running
   sudo systemctl stop nginx    # If system nginx is running
   ```
3. Or change port in `docker-compose.yml`: `ports: - "8443:443"`

---

## Data Backup and Restore

### Backing Up Data

**Backup database:**
```bash
docker exec mariadb mariadb-dump -u root -p"$(cat secrets/db_root_password.txt)" wordpress > backup_db.sql
```

**Backup WordPress files:**
```bash
tar -czf backup_wp.tar.gz /home/mzhivoto/data/wordpress
```

**Backup secrets:**
```bash
tar -czf backup_secrets.tar.gz secrets/
```

### Restoring Data

**Restore database:**
```bash
cat backup_db.sql | docker exec -i mariadb mariadb -u root -p"$(cat secrets/db_root_password.txt)" wordpress
```

**Restore WordPress files:**
```bash
tar -xzf backup_wp.tar.gz -C /
```

---

## Maintenance Tasks

### Updating WordPress

WordPress can be updated through the admin panel or via WP-CLI:

```bash
docker exec wordpress wp core update --allow-root
docker exec wordpress wp plugin update --all --allow-root
docker exec wordpress wp theme update --all --allow-root
```

### Cleaning Up Old Data

**Remove stopped containers:**
```bash
docker container prune
```

**Remove unused images:**
```bash
docker image prune -a
```

**Remove unused volumes:**
```bash
docker volume prune
```

⚠️ **Warning:** Be careful with volume pruning - it can delete data!

### Viewing Logs

**Live logs (all services):**
```bash
make logs
```

**Logs from specific service:**
```bash
docker logs -f nginx
docker logs -f wordpress
docker logs -f mariadb
```

**Last 50 lines:**
```bash
docker logs --tail=50 wordpress
```

---

## Support and Further Help

### Getting Help

**Check logs for errors:**
```bash
make logs
```

**Check service health:**
```bash
docker ps
docker inspect mariadb | grep -A5 Health
```

**WordPress Debug Mode:**
Edit `/home/mzhivoto/data/wordpress/wp-config.php` and add:
```php
define('WP_DEBUG', true);
define('WP_DEBUG_LOG', true);
```

Then check: `/home/mzhivoto/data/wordpress/wp-content/debug.log`

### Additional Resources

- **WordPress Support:** https://wordpress.org/support/
- **Docker Documentation:** https://docs.docker.com/
- **NGINX Documentation:** https://nginx.org/en/docs/
- **MariaDB Knowledge Base:** https://mariadb.com/kb/

---

## Appendix: Service URLs and Ports

| Service | Internal Port | External Port | URL |
|---------|--------------|---------------|-----|
| NGINX | 443 | 443 | https://mzhivoto.42.fr |
| WordPress/PHP-FPM | 9000 | - | (internal only) |
| MariaDB | 3306 | - | (internal only) |

**Note:** Only NGINX port 443 is exposed to the host. WordPress and MariaDB are only accessible within the Docker network.
