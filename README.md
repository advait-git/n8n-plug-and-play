# n8n Docker Setup - Completely Local & Secure

This setup runs n8n, PostgreSQL, and pgAdmin entirely on your local machine. **No data leaves your computer.**



### Your Data is 100% Local:
- **PostgreSQL database**: Runs on your machine only
- **n8n workflows**: Stored locally in Docker volumes
- **No cloud connections**: Everything is self-hosted
- **Network isolation**: Services only communicate within your computer

### What `n8n-network` Actually Is:
- **Local Docker bridge network** (like a private LAN on your computer)
- **NOT connected to n8n's servers** on the internet
- Only these 3 containers can communicate: postgres ↔ pgadmin ↔ n8n
- **No external access** unless you explicitly configure it

```
┌─────────────────────────────────────┐
│          Your Computer              │
│  ┌─────────────────────────────────┐│
│  │      n8n-network (isolated)     ││
│  │                                 ││
│  │  [postgres] ↔ [pgadmin] ↔ [n8n] ││
│  │                                 ││
│  └─────────────────────────────────┘│
│                                     │
│  Only YOU can access via:           │
│  • localhost:5678 (n8n)             │
│  • localhost:8080 (pgAdmin)         │
└─────────────────────────────────────┘
```

## Folder Structure
```
n8n-docker/
├── docker-compose.yml
├── Dockerfile (optional)
├── .env
├── README.md
└── .gitignore (recommended)
```

## Quick Start

### 1. Create the folder and files
```bash
mkdir n8n-docker
cd n8n-docker
```

Copy the docker-compose.yml file into this folder.

### 2. Start all services
```bash
docker-compose up -d
```

### 3. Access the applications
- **n8n**: http://localhost:5678
- **pgAdmin**: http://localhost:8080
  - Email: `admin@gmail.com`
  - Password: `admin`

### 4. Connect pgAdmin to PostgreSQL
1. Open pgAdmin at http://localhost:8080
2. Login with your email and password
3. Right-click "Servers" → "Register" → "Server"
4. **General tab**: Name = `n8n-postgres`
5. **Connection tab**:
   - Host: `postgres`
   - Port: `5432`
   - Database: `n8ndb`
   - Username: `postgres`
   - Password: `root`

## Common Commands

### Start all services
```bash
docker-compose up -d
```

### Stop all services
```bash
docker-compose down
```

### View logs
```bash
# All services
docker-compose logs

# Specific service
docker-compose logs n8n
docker-compose logs postgres
docker-compose logs pgadmin
```

### Follow live logs
```bash
docker-compose logs -f n8n
```

### Restart a specific service
```bash
docker-compose restart n8n
```

### Update n8n to latest version
```bash
docker-compose pull n8n
docker-compose up -d n8n
```

### Check service status
```bash
docker-compose ps
```

## Data Management

### Backup your data
```bash
# Backup n8n data
docker run --rm -v n8n-docker_n8n_data:/data -v $(pwd):/backup alpine tar czf /backup/n8n-backup.tar.gz -C /data .

# Backup PostgreSQL database
docker-compose exec postgres pg_dump -U postgres n8ndb > n8n-db-backup.sql
```

### Restore data
```bash
# Restore n8n data
docker run --rm -v n8n-docker_n8n_data:/data -v $(pwd):/backup alpine tar xzf /backup/n8n-backup.tar.gz -C /data

# Restore PostgreSQL database
docker-compose exec -T postgres psql -U postgres n8ndb < n8n-db-backup.sql
```

## Configuration Details

### Database Configuration:
- **Database**: `n8ndb`
- **User**: `postgres`
- **Password**: `root`
- **Host**: `postgres` (container name)
- **Port**: `5432`

### Timezone:
- Set to `Asia/Kolkata`
- Both system timezone and n8n timezone configured

### Volumes (Your data is stored here):
- `n8n_data`: n8n workflows, credentials, settings
- `postgres_data`: PostgreSQL database
- `pgadmin_data`: pgAdmin settings

## Troubleshooting

### Services won't start
```bash
# Check what's running
docker-compose ps

# View detailed logs
docker-compose logs postgres
docker-compose logs n8n
```

### Reset everything (⚠️ DELETES ALL DATA)
```bash
docker-compose down -v
docker-compose up -d
```

### Access container shell
```bash
# n8n container
docker-compose exec n8n /bin/sh

# PostgreSQL container
docker-compose exec postgres /bin/bash
```

### Check PostgreSQL connection
```bash
# Test database connection
docker-compose exec postgres psql -U postgres -d n8ndb -c "SELECT version();"
```

## Security Best Practices

### For Production Use:
1. **Change default passwords**:
   ```bash
   # Edit your docker-compose.yml
   POSTGRES_PASSWORD: your-strong-password
   PGADMIN_DEFAULT_PASSWORD: your-admin-password
   ```

2. **Don't expose ports externally**:
   - Remove port mappings if accessing from same machine only
   - Use nginx proxy for external access with SSL

3. **Use environment file**:
   ```bash
   # Create .env file
   echo "POSTGRES_PASSWORD=your-secure-password" > .env
   ```

4. **Regular backups**:
   ```bash
   # Add to crontab for daily backups
   0 2 * * * cd /path/to/n8n-docker && docker-compose exec postgres pg_dump -U postgres n8ndb > backup-$(date +%Y%m%d).sql
   ```

## Advanced Configuration

### Custom n8n Settings:
Add to n8n environment in docker-compose.yml:
```yaml
- N8N_ENCRYPTION_KEY=your-custom-encryption-key
- N8N_HOST=localhost
- N8N_PROTOCOL=http
- WEBHOOK_URL=http://localhost:5678/
```

### Memory Limits:
```yaml
n8n:
  # ... other config
  deploy:
    resources:
      limits:
        memory: 1G
      reservations:
        memory: 512M
```

## Ports Used
- **5678**: n8n web interface
- **5432**: PostgreSQL database  
- **8080**: pgAdmin web interface

## Why This Setup is Secure

✅ **No cloud dependencies** - everything runs locally
✅ **Isolated network** - containers can only talk to each other
✅ **No data transmission** - all data stays on your machine
✅ **Local file system** - volumes are stored on your computer
✅ **No external APIs** - unless you configure workflows to use them
✅ **Self-hosted** - you control everything

**Your workflows, credentials, and data never leave your computer unless you explicitly configure n8n workflows to connect to external services.**
