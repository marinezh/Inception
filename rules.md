🔹 Case 1 — You changed WordPress admin / DB values

Examples:

WP_ADMIN_USER
WP_ADMIN_PASSWORD
WP_ADMIN_EMAIL
MYSQL_DATABASE
MYSQL_USER
MYSQL_PASSWORD

❌ docker compose build is NOT enough
❌ docker compose up -d is NOT enough

Because:

WordPress is installed only once
After first install, values are stored in:
wp-config.php
MariaDB tables

volumes

✅ You need fclean (full reset)
make fclean
make


This:

removes volumes

deletes DB + WordPress files

re-runs wp core install with new .env

➡️ Use this when changing admin password/user or DB creds

🔹 Case 2 — You changed only Nginx / DOMAIN_NAME

Examples:

DOMAIN_NAME

✅ No fclean needed

Just restart Nginx:

docker compose up -d --build nginx


(SSL cert regenerated automatically by your entrypoint if missing.)

🔹 Case 3 — You changed Dockerfile / scripts

Examples:

entrypoint.sh

wordpress.sh

nginx.conf

Dockerfile

✅ Rebuild is enough
docker compose build
docker compose up -d


No volume wipe required.

🔹 Decision table (save this)
What changed in .env	Action
WP admin user/password/email	make fclean && make
MariaDB credentials	make fclean && make
DOMAIN_NAME only	rebuild nginx
PHP / nginx config	rebuild
Nothing in volumes	no fclean
🧠 Pro tip (exam-safe workflow)

During setup:

make fclean
make


After that, don’t touch .env anymore unless you’re ready to wipe.

If you want, paste your final .env (with fake passwords) and I’ll confirm:
✅ “This one is evaluation-safe, don’t touch it anymore.”