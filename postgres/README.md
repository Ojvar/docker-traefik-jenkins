# PostgreSQL Stack

This directory contains the PostgreSQL stack configuration with pgAdmin web interface, following the same pattern as the Jenkins stack.

## Components

- **PostgreSQL 17**: Main database server (custom image with extensions)
- **pgAdmin 4**: Web-based administration tool for PostgreSQL (custom image with configuration)

## Configuration

### PostgreSQL
- **Database**: `postgres`
- **Username**: `postgres`
- **Password**: `postgres`
- **Port**: `5432` (routed through Traefik)
- **Direct Access**: Disabled (only accessible through Traefik)

### pgAdmin
- **URL**: http://pg.ojvar.xyz
- **Email**: `admin@ojvar.xyz`
- **Password**: `admin`
- **Port**: `80` (internal, exposed via Traefik)

## Files

- `docker-compose.yml`: Main stack configuration
- `Dockerfile.postgres`: Custom PostgreSQL image with extensions
- `Dockerfile.pgadmin`: Custom pgAdmin image with configuration
- `postgresql.conf`: PostgreSQL configuration
- `pg_hba.conf`: PostgreSQL host-based authentication
- `servers.json`: pgAdmin server configuration
- `deploy.sh`: Deployment script

## Deployment

The deployment will automatically build custom Docker images for both PostgreSQL and pgAdmin with your configurations.

### Using the main deploy script
```bash
# From the root directory
./deploy.sh start
```

### Using the PostgreSQL-specific deploy script
```bash
# From the postgres directory
./deploy.sh
```

### Building images manually
```bash
# Build PostgreSQL image
docker build -f Dockerfile.postgres -t postgres-custom:17 .

# Build pgAdmin image  
docker build -f Dockerfile.pgadmin -t pgadmin-custom:latest .
```

## Access

1. **pgAdmin Web Interface**: Navigate to http://pg.ojvar.xyz
2. **Login**: Use `admin@ojvar.xyz` / `admin`
3. **Connect to PostgreSQL**: The server is pre-configured in pgAdmin as "PostgreSQL Server"
4. **Direct PostgreSQL Access**: Connect to `localhost:5432` (routed through Traefik)

## Data Persistence

- PostgreSQL data: `./postgres_data/`
- pgAdmin data: `./pgadmin_data/`

## Network

Both services are connected to the `public-net` overlay network, allowing communication with other services in the stack.

## Health Checks

- PostgreSQL: Uses `pg_isready` command
- pgAdmin: Uses HTTP ping to `/misc/ping`

## Security Notes

- Default passwords should be changed in production
- Consider using Docker secrets for sensitive data
- pgAdmin is configured for single-user mode (not server mode)
- PostgreSQL is only accessible through Traefik (no direct port exposure)
- Traefik handles all PostgreSQL connections on port 5432

## Troubleshooting

### Check service status
```bash
docker service ls | grep postgres
```

### View logs
```bash
docker service logs postgres-stack_postgres
docker service logs postgres-stack_pgadmin
```

### Connect to PostgreSQL through Traefik
```bash
# Connect via psql through Traefik
psql -h localhost -p 5432 -U postgres

# Or connect directly to container (for admin purposes)
docker exec -it $(docker ps -q -f name=postgres) psql -U postgres
```
