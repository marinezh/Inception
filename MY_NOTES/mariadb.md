1. Enter to the sql database as a root user
```bash
docker exec -it mariadb mariadb -u root -p
```
or
```bash
docker exec -it mariadb mariadb -u wp_user -p
docker exec -it wordpress mariadb -h mariadb -u wp_user -p wordpress

```

2. Choose wordpress db
```sql
SHOW DATABASES;
USE wordpress;
```

3. What’s inside the database (all tables)
```sql
SHOW TABLES;
```
4. For each table: see what “data fields” exist		
	Pick a table and run:

```sql
DESCRIBE wp_posts;
DESCRIBE wp_comments;
DESCRIBE wp_users;
DESCRIBE wp_options;
```

5. Posts + pages (titles, status)
```sql
SELECT ID, post_type, post_status, post_title, post_date
FROM wp_posts
ORDER BY ID DESC
LIMIT 15;
```
or comments
```sql
SELECT comment_ID, comment_post_ID, comment_author, comment_approved, comment_date
FROM wp_comments
ORDER BY comment_ID DESC
LIMIT 15;
```
or users
```sql
SELECT ID, user_login, user_email, user_registered
FROM wp_users
ORDER BY ID ASC;
```
6. Check users in wordpress db (only as a root)
```sql
SELECT User, Host FROM mysql.user;
```
shoud be:
root
wp_user