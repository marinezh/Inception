# WordPress Troubleshooting Guide (Alpine)

**Date:** January 19, 2026

## Quick Fixes Applied

### Fix 1: Added www-data User ✅
Alpine doesn't create `www-data` by default. Added to Dockerfile:
```dockerfile
RUN addgroup -g 82 -S www-data \
    && adduser -u 82 -D -S -G www-data www-data
```

### Fix 2: Added Missing PHP Extensions ✅
Added required WordPress extensions:
- `php82-ctype` (character type checking)
- `php82-fileinfo` (file type detection)
- `php82-iconv` (character encoding)
- `php82-simplexml` (XML parsing)
- `php82-xmlreader` (XML reading)

### Fix 3: PHP-FPM Flag ✅
Added `-R` flag to allow running as root (required in Docker):
```bash
exec php-fpm82 -F -R
```

---

## Testing Steps

On your **school machine VM**, run:

```bash
# 1. Clean everything
make fclean

# 2. Rebuild with fixes
make

# 3. Check container status
docker ps

# 4. Check WordPress logs
docker logs wordpress

# 5. Check NGINX logs
docker logs nginx

# 6. Check MariaDB logs
docker logs mariadb
```

---

## Common WordPress Errors & Solutions

### Error: "Error establishing a database connection"

**Cause:** WordPress can't connect to MariaDB

**Debug:**
```bash
# Check if MariaDB is running
docker exec mariadb mariadb-admin ping

# Check if database exists
docker exec mariadb mariadb -uroot -p$(cat secrets/db_root_password.txt) -e "SHOW DATABASES;"

# Test connection from WordPress container
docker exec wordpress nc -zv mariadb 3306
```

**Solution:** Wait for MariaDB to fully initialize (can take 30-60 seconds)

---

### Error: "502 Bad Gateway" or "PHP-FPM error"

**Cause:** PHP-FPM not starting or crashed

**Debug:**
```bash
# Check WordPress container logs
docker logs wordpress -f

# Check if PHP-FPM is running
docker exec wordpress ps aux | grep php-fpm

# Check PHP-FPM config
docker exec wordpress php-fpm82 -t
```

**Solution:** Look for specific error in logs (usually permission or config issue)

---

### Error: "White screen" or blank page

**Cause:** PHP fatal error

**Debug:**
```bash
# Check WordPress error log
docker exec wordpress cat /var/log/php82/www-error.log

# Check WordPress debug log
docker exec wordpress cat /var/www/html/wp-content/debug.log
```

**Solution:** Enable WordPress debug mode if needed

---

### Error: "Permission denied" errors

**Cause:** Wrong file ownership

**Debug:**
```bash
# Check file ownership
docker exec wordpress ls -la /var/www/html/

# Check www-data user exists
docker exec wordpress id www-data
```

**Solution:** Already fixed in entrypoint with `chown -R www-data:www-data`

---

### Error: "Unable to create directory"

**Cause:** Volume mount or permission issue

**Debug:**
```bash
# Check volume mount
docker exec wordpress df -h /var/www/html

# Check if directory is writable
docker exec wordpress touch /var/www/html/test.txt
```

**Solution:** Check volume permissions on host

---

## Get Detailed Logs

### All Container Logs
```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

### Follow Logs in Real-Time
```bash
docker logs -f wordpress
```

### Check Last 50 Lines
```bash
docker logs --tail 50 wordpress
```

### Execute Commands Inside Container
```bash
# Enter WordPress container
docker exec -it wordpress sh

# Inside container:
ps aux                          # Check running processes
ls -la /var/www/html           # Check WordPress files
cat /var/log/php82/www-error.log  # Check PHP errors
exit
```

---

## Alpine-Specific Issues

### Issue: `bash` not found
**Solution:** Alpine uses `sh`. Changed all `#!/bin/bash` to `#!/bin/sh` ✅

### Issue: Different package names
**Solution:** Already updated in Dockerfiles ✅

### Issue: Different paths
**Solution:** Updated all config paths ✅

---

## Quick Health Check

Run this complete diagnostic:

```bash
echo "=== Container Status ==="
docker ps -a

echo -e "\n=== Network ==="
docker network ls | grep inception

echo -e "\n=== Volumes ==="
docker volume ls | grep inception

echo -e "\n=== WordPress Logs (last 20 lines) ==="
docker logs --tail 20 wordpress

echo -e "\n=== NGINX Logs (last 20 lines) ==="
docker logs --tail 20 nginx

echo -e "\n=== MariaDB Logs (last 20 lines) ==="
docker logs --tail 20 mariadb

echo -e "\n=== Test Database Connection ==="
docker exec wordpress nc -zv mariadb 3306 && echo "✅ MariaDB reachable" || echo "❌ MariaDB unreachable"

echo -e "\n=== Test PHP-FPM ==="
docker exec wordpress ps aux | grep php-fpm && echo "✅ PHP-FPM running" || echo "❌ PHP-FPM not running"
```

Save this as `check.sh` and run: `bash check.sh`

---

## If Still Not Working

**Please provide:**

1. **Exact error message** from browser
2. **Output of:** `docker ps -a`
3. **Output of:** `docker logs wordpress`
4. **Output of:** `docker logs nginx`
5. **Which URL** you're trying to access

Then I can provide a more specific fix! 🔧
