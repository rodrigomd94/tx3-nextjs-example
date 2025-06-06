# Docker Setup for TX3 Next.js Application

This Docker setup allows you to run the entire TX3 Next.js application stack without installing dependencies locally.

## Prerequisites

- Docker
- Docker Compose

## Quick Start

1. **Build and start all services:**
   ```bash
   docker compose up -d
   ```

2. **Access the application:**
   - Next.js app: http://localhost:3000
   - Dolos daemon: http://localhost:8164

3. **Stop the services:**
   ```bash
   docker compose down
   ```

## Development Workflow

### Making Changes to the Next.js App

The Docker setup is configured for live development:

- Your local source code is mounted into the container
- Changes to files are automatically detected by Next.js
- The app will hot-reload in your browser
- No need to restart containers when editing code

### Working with Different Environments

**For Docker development:**
- The containers use `tx3/trix.docker.toml` which points to the `dolos` service
- This happens automatically when running in Docker

**For local development:**
- Keep using `tx3/trix.toml` which points to `localhost:8164`
- You can run dolos locally with: `cd devnet && dolos daemon`

### Port Configuration

If port 3000 or 8164 are already in use on your system, you can change the host ports in `docker-compose.yml`:

```yaml
services:
  app:
    ports:
      - "3001:3000"  # Use port 3001 on host instead of 3000
  dolos:
    ports:
      - "8165:8164"  # Use port 8165 on host instead of 8164
```

## Available Commands

### Start services in background:
```bash
docker compose up -d
```

### View logs:
```bash
docker compose logs -f app    # Next.js app logs
docker compose logs -f dolos  # Dolos daemon logs
```

### Rebuild containers (when Dockerfiles change):
```bash
docker compose up -d --build
```

### Stop and remove containers:
```bash
docker compose down
```

### Clean up everything (containers, networks, volumes):
```bash
docker compose down -v
```

## Troubleshooting

### Container won't start
- Check if ports 3000 and 8164 are available
- Run `docker compose logs <service-name>` to see error messages

### Changes not reflecting
- Ensure your files are being saved
- Check that the volume mounts are working: `docker compose exec app ls -la /app`

### Dolos connection issues
- Verify dolos container is running: `docker compose ps`
- Check dolos logs: `docker compose logs dolos`
- Ensure the containers are on the same network

## Architecture

- **app service**: Runs the Next.js application with live reloading
- **dolos service**: Runs the Cardano dolos daemon
- **tx3-network**: Docker network allowing services to communicate
- **Volume mounts**: Enable live code editing and persistent data
