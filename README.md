# Inception

*This project has been created as part of the 42 curriculum by mzhivoto.*

---

## 📖 Documentation

This project includes comprehensive documentation for different audiences:

- **[USER_DOC.md](USER_DOC.md)** - For end users and administrators
  - Understanding services
  - Starting/stopping the project
  - Accessing website and admin panel
  - Managing credentials
  - Checking service status

- **[DEV_DOC.md](DEV_DOC.md)** - For developers
  - Environment setup from scratch
  - Building and launching with Makefile/Docker Compose
  - Container and volume management commands
  - Data persistence and storage locations
  - Development workflow and debugging

---

## Description

Inception is a system administration and DevOps project that focuses on Docker containerization and orchestration. The goal is to set up a complete web infrastructure using Docker Compose, consisting of multiple services running in separate containers:

- **NGINX** - Web server with TLSv1.2/TLSv1.3 encryption
- **WordPress** - Content management system with PHP-FPM
- **MariaDB** - Relational database management system

Each service runs in its own dedicated container built from custom Dockerfiles (using penultimate stable Debian version). The infrastructure uses Docker networks for inter-container communication, Docker volumes for data persistence, and Docker secrets for secure credential management.

This project demonstrates understanding of:
- Docker containerization and image building
- Service orchestration with Docker Compose
- Network configuration and container communication
- Data persistence and volume management
- Security best practices (TLS, secrets, principle of least privilege)
- System administration fundamentals

---

## Quick Start

### Prerequisites

- Docker Engine (20.10+)
- Docker Compose (v2.0+)
- GNU Make

### Basic Setup

1. **Clone and configure:**
   ```bash
   git clone <repository-url> && cd Inception
   sudo sh -c 'echo "127.0.0.1 mzhivoto.42.fr" >> /etc/hosts'
   cp srcs/.env.example srcs/.env
   # Edit srcs/.env if needed
   ```

2. **Start the project:**
   ```bash
   make
   ```

3. **Access:**
   - Website: https://mzhivoto.42.fr
   - Admin: https://mzhivoto.42.fr/wp-admin

**Note:** Browser will show security warning (expected for self-signed certificate).

For detailed instructions, see [USER_DOC.md](USER_DOC.md) or [DEV_DOC.md](DEV_DOC.md).

---

## Project Structure

```
Inception/
├── Makefile                    # Build automation
├── README.md                   # This file (project overview)
├── USER_DOC.md                # User/administrator documentation
├── DEV_DOC.md                 # Developer documentation
├── secrets/                    # Sensitive credentials (gitignored)
│   ├── db_password.txt
│   ├── db_root_password.txt
│   ├── wp_admin_password.txt
│   └── wp_user_password.txt
└── srcs/
    ├── .env                    # Environment configuration (gitignored)
    ├── .env.example            # Environment template
    ├── docker-compose.yml      # Service orchestration
    └── requirements/
        ├── mariadb/           # Database container
        ├── nginx/             # Web server container
        └── wordpress/         # WordPress + PHP-FPM container
```

---

## Common Commands

```bash
make          # Start all services
make down     # Stop all services
make fclean   # Full cleanup (including data)
make re       # Rebuild from scratch
make logs     # View logs
docker ps     # Check container status
```

For more commands, see [DEV_DOC.md](DEV_DOC.md).

---

## Resources

### Documentation & References

**Docker Official Documentation:**
- [Docker Overview](https://docs.docker.com/get-started/overview/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Docker Networking](https://docs.docker.com/network/)
- [Docker Volumes](https://docs.docker.com/storage/volumes/)
- [Docker Secrets](https://docs.docker.com/engine/swarm/secrets/)

**Service-Specific Documentation:**
- [NGINX Configuration](https://nginx.org/en/docs/)
- [NGINX SSL Module](https://nginx.org/en/docs/http/ngx_http_ssl_module.html)
- [MariaDB Documentation](https://mariadb.com/kb/en/documentation/)
- [WordPress Codex](https://wordpress.org/support/)
- [WP-CLI Documentation](https://wp-cli.org/)
- [PHP-FPM Configuration](https://www.php.net/manual/en/install.fpm.php)

**Tutorials & Articles:**
- [Understanding Docker Networking](https://earthly.dev/blog/docker-networking/)
- [Docker Security Best Practices](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)
- [NGINX as Reverse Proxy](https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/)

### AI Usage

**AI tools were used for:**
- **Code review and debugging** - Identifying potential bugs, edge cases, and security issues
- **Best practices consultation** - Verifying Docker and system administration best practices
- **Documentation clarification** - Understanding complex Docker networking and volume concepts
- **Script optimization** - Improving entrypoint scripts for robustness and error handling
- **Documentation support** - Drafting and refining documentation files (README.md, USER_DOC.md, DEV_DOC.md)
- **Technical explanations** - Reviewing project structure against requirements (services, networking, secrets vs environment variables, storage choices)

**AI was NOT used for:**
- Writing the core Dockerfiles from scratch
- Initial service configuration files (nginx.conf, my.cnf, www.conf)
- Docker Compose structure and design decisions
- Makefile creation and build system design

All AI-generated recommendations were manually evaluated, tested, and adapted before implementation.

---

```
Inception/
├── Makefile                    # Build automation
├── README.md                   # This file
├── secrets/                    # Sensitive credentials (gitignored)
│   ├── db_password.txt
│   ├── db_root_password.txt
│   ├── wp_admin_password.txt
│   └── wp_user_password.txt
└── srcs/
    ├── .env                    # Environment configuration (gitignored)
    ├── .env.example            # Environment template
    ├── docker-compose.yml      # Service orchestration
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/
        │   │   └── my.cnf
        │   └── tools/
        │       └── entrypoint.sh
        ├── nginx/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/
        │   │   └── nginx.conf
        │   └── tools/
        │       └── entrypoint.sh
        └── wordpress/
            ├── Dockerfile
            ├── .dockerignore
            ├── conf/
            │   └── www.conf
            └── tools/
                └── wordpress.sh
```

---

## Technical Overview

### Docker Architecture

This project uses Docker to containerize three services, each in its own isolated environment:

**Service Containers:**
1. **NGINX** - Handles HTTPS requests, serves static files, proxies PHP requests
2. **WordPress + PHP-FPM** - Processes dynamic content, manages WordPress application
3. **MariaDB** - Stores WordPress data (posts, users, settings)

**Key Design Principles:**
- One service per container (separation of concerns)
- Custom Dockerfiles from Debian base (no pre-built images like alpine-nginx)
- Foreground process execution (no daemon mode hacks)
- Proper PID 1 handling with `exec` command
- Healthchecks for service orchestration
- Restart policies for fault tolerance

### Virtual Machines vs Docker

| Aspect | Virtual Machines | Docker Containers |
|--------|------------------|-------------------|
| **Architecture** | Full OS with kernel, drivers, system services | Shares host kernel, isolated user space |
| **Size** | GBs (entire OS) | MBs (app + dependencies) |
| **Startup Time** | Minutes | Seconds |
| **Resource Usage** | Heavy (reserved RAM/CPU) | Lightweight (shared resources) |
| **Isolation** | Complete (hardware-level) | Process-level (kernel namespaces) |
| **Portability** | Limited (hypervisor-dependent) | High (runs anywhere Docker runs) |
| **Use Case** | Multiple OS types, complete isolation | Microservices, rapid deployment |

**Why Docker for this project:**
- ✅ Faster deployment and iteration during development
- ✅ Consistent environment across different systems
- ✅ Lightweight resource consumption
- ✅ Easy scaling and orchestration
- ✅ Perfect for single-purpose services (nginx, database, app)

**When VMs are better:**
- Need different OS types (Linux + Windows)
- Require complete isolation (security-critical)
- Running untrusted code
- Legacy applications requiring specific kernel versions

### Secrets vs Environment Variables

| Feature | Docker Secrets | Environment Variables |
|---------|---------------|----------------------|
| **Storage** | Encrypted at rest, tmpfs in container | Plain text in container config |
| **Visibility** | Only visible to assigned services | Visible in `docker inspect`, logs, error messages |
| **Access** | Mounted as files in `/run/secrets/` | Available as shell variables |
| **Security** | High (encrypted, never in logs) | Low (can leak in logs, process lists) |
| **Best For** | Passwords, API keys, certificates | Non-sensitive config (URLs, feature flags) |

**Implementation in this project:**

**Secrets** (used for sensitive data):
```yaml
secrets:
  db_password:
    file: ../secrets/db_password.txt
```

Accessed in container:
```bash
MYSQL_PASSWORD="$(cat /run/secrets/db_password)"
```

**Environment Variables** (used for non-sensitive config):
```yaml
environment:
  MYSQL_HOST: mariadb
  WP_URL: ${WP_URL}
```

**Why this approach:**
- ✅ Passwords never appear in code or logs
- ✅ Can't accidentally leak secrets via `docker inspect`
- ✅ Secrets stored separately from code (gitignored)
- ✅ Non-sensitive config remains easy to override

### Docker Network vs Host Network

| Network Mode | Docker Network (Bridge) | Host Network |
|--------------|------------------------|--------------|
| **Isolation** | Containers have isolated network stack | Containers share host network stack |
| **Port Mapping** | Required (`-p 443:443`) | Not needed (direct host ports) |
| **DNS** | Built-in service discovery by name | Manual IP management |
| **Security** | Isolated, controlled exposure | Direct exposure to host network |
| **Performance** | Slight overhead (NAT) | No overhead |
| **Use Case** | Standard containerized apps | Network-intensive apps, monitoring |

**Implementation in this project:**

```yaml
networks:
  inception:
    driver: bridge
```

**Why bridge network:**
- ✅ **Service discovery:** WordPress connects to `mariadb:3306` (no IPs)
- ✅ **Security:** Only nginx port 443 exposed to host, other services internal
- ✅ **Isolation:** Services can't interfere with host network
- ✅ **Flexibility:** Can run multiple similar setups on same host

**Container communication:**
```
nginx:443 → wordpress:9000 → mariadb:3306
(external)    (internal)        (internal)
```

**When to use host network:**
- High-performance requirements
- Network monitoring tools
- Need to bind to host interfaces directly


## Key Features

### Security

- ✅ TLS 1.2/1.3 only (no weak SSL/TLS versions)
- ✅ Self-signed SSL certificate with proper CN
- ✅ Docker secrets for all passwords
- ✅ Non-root user execution (mysql, www-data)
- ✅ Read-only volume mounts where applicable
- ✅ No hardcoded credentials in code
- ✅ Principle of least privilege (expose only port 443)

### Reliability

- ✅ Healthchecks for all services
- ✅ Restart policies (`restart: always`)
- ✅ Bounded wait loops (no infinite waits)
- ✅ Initialization markers (prevent re-initialization)
- ✅ Graceful shutdown (proper PID 1 handling)
- ✅ Dependency ordering with health conditions

### Best Practices

- ✅ One service per container
- ✅ Foreground process execution
- ✅ `.dockerignore` files for build optimization
- ✅ Multi-stage builds not needed (simple base images)
- ✅ Minimal package installation (`--no-install-recommends`)
- ✅ Proper signal handling with `exec`
- ✅ Environment variable configuration
- ✅ Comprehensive error handling in scripts

---

## License

This project is part of the 42 School curriculum and follows 42's academic policies.

---

## Need More Information?

📖 **For Users/Administrators:**  
See [USER_DOC.md](USER_DOC.md) for detailed instructions on using the system, managing credentials, and troubleshooting.

🔧 **For Developers:**  
See [DEV_DOC.md](DEV_DOC.md) for environment setup, development workflow, container management, and advanced topics.

---

## Author

**mzhivoto** - 42 Student

For questions or suggestions, please refer to the 42 Inception subject documentation.
