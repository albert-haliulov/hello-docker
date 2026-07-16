# Hello Docker - Multi-Container Application with Docker Compose

This project demonstrates how Docker Compose simplifies the development, deployment, and management of multi-container applications.

## Application Architecture

The application consists of:

- **3 Node.js backend services** (`hello1`, `hello2`, `hello3`) - Each runs a simple web server that displays:
  - A welcome message
  - The hostname of the container
  - The OS platform and release
- **1 HAProxy load balancer** (`balancer1`) - Distributes incoming HTTP requests across the 3 backend services

```
┌─────────────────┐
│   HAProxy       │
│   (Port 80)     │
└────────┬────────┘
         │
    ┌────┴───┬─────────┐
    │        │         │
┌───▼────┐ ┌─▼─────┐  ┌▼─────┐
│ hello1 │ │ hello2 │ │hello3│
│ 8080   │ │ 8080   │ │8080  │
└────────┘ └────────┘ └──────┘
```

## Prerequisites

- [Docker Engine](https://docs.docker.com/engine/install/) (v20.10+)
- [Docker Compose](https://docs.docker.com/compose/install/) (v2.0+)

## Quick Start

### Using Docker Compose (Recommended)

```bash
# Build all services
BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') docker compose build

# Start all services in detached mode
docker compose up -d

# View running containers
docker compose ps

# Check logs
docker compose logs -f

# Access the application
curl http://localhost

# Access HAProxy stats
curl http://localhost:9000

# Stop and remove all services
docker compose down

# Stop and remove volumes
docker compose down -v
```

### Using Docker CLI (Manual Approach)

For comparison, here's how you would manage the same application using only Docker CLI commands:

```bash
# 1. Create a custom network
docker network create net

# 2. Build the application image
docker build -t hello-docker https://github.com/albert-haliulov/hello-docker.git

# 3. Start 3 backend services (requires individual commands)
docker run -d --rm --name hello1 --net-alias hello --network net -p 8081:8080 hello-docker
docker run -d --rm --name hello2 --net-alias hello --network net -p 8082:8080 hello-docker
docker run -d --rm --name hello3 --net-alias hello --network net -p 8083:8080 hello-docker

# 4. Start the load balancer (requires manual volume mapping)
docker run -d --rm --name lb --network net \
  -v /home/user1/hello-docker/haproxy/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg \
  -p 80:80 -p 9000:9000 haproxy:2.5.0

# 5. Test the application
while true; do curl -s http://localhost; sleep 1; done

# 6. Stop all services (requires listing each container)
docker stop hello1 hello2 hello3 balancer1
```

## Docker Compose vs Docker CLI Comparison

| Task | Docker CLI | Docker Compose |
|------|-----------|----------------|
| **Network creation** | `docker create network net` | Automatic |
| **Build images** | `docker build` (per image) | `docker compose build` |
| **Start services** | Multiple `docker run` commands | `docker compose up -d` |
| **Service dependencies** | Manual `--link` or network aliases | `depends_on` in compose file |
| **Volume mounting** | `-v` flag per container | Declarative in compose file |
| **Stop services** | `docker stop` per container | `docker compose down` |
| **View logs** | `docker logs` per container | `docker compose logs` |
| **Environment variables** | `-e` flag per container | `environment` in compose file |

## Key Docker Compose Benefits

### 1. **Single Configuration File**
All service definitions are in [`docker-compose.yml`](docker-compose.yml), making the entire application architecture visible and version-controllable.

### 2. **Automatic Network Management**
Docker Compose creates a shared network automatically, allowing containers to communicate using service names as hostnames.

### 3. **Declarative Dependencies**
The `depends_on` directive ensures services start in the correct order:
- `hello2` and `hello3` wait for `hello1`
- `balancer1` waits for all backend services

### 4. **Simplified Commands**
- Start everything: `docker compose up`
- Stop everything: `docker compose down`
- View all logs: `docker compose logs`
- Scale services: `docker compose up --scale hello1=5`

### 5. **Environment Variables**
Build arguments and environment variables are defined once and applied consistently across all services.

## Project Structure

```
.
├── app/                    # Node.js application source
│   ├── package.json       # Dependencies
│   ├── package-lock.json  # Lock file
│   └── server.js          # Express server
├── haproxy/
│   └── haproxy.cfg        # HAProxy load balancer configuration
├── Dockerfile             # Application image definition
├── docker-compose.yml     # Multi-container orchestration
└── README.md
```

## Environment Variables

### Build Arguments (Dockerfile)
- `IMAGE_CREATE_DATE` - Image creation timestamp
- `IMAGE_VERSION` - Application version
- `IMAGE_SOURCE_REVISION` - Git commit hash

### Service Environment (docker-compose.yml)
- `SERVICE_NAME` - Unique identifier for each service
- `PORT` - Port the application listens on (default: 8080)

## Useful Docker Compose Commands

```bash
# Build images
docker compose build
docker compose build --no-cache

# Start services
docker compose up
docker compose up -d          # Detached mode
docker compose up --build     # Rebuild before starting

# View logs
docker compose logs
docker compose logs -f        # Follow logs
docker compose logs hello1    # Logs for specific service

# Manage services
docker compose start
docker compose stop
docker compose restart

# Scale services
docker compose up --scale hello1=3

# Inspect
docker compose ps
docker compose config         # Validate and view configuration

# Cleanup
docker compose down           # Stop and remove containers
docker compose down -v        # Also remove volumes
docker compose down --rmi all # Also remove images
```

## Access Points

- **Application**: http://localhost
- **HAProxy Stats**: http://localhost:9000

## Learning Objectives

This project helps Docker learners understand:

1. **Multi-container orchestration** - How containers work together
2. **Service discovery** - Using service names for internal communication
3. **Network isolation** - Custom networks for security
4. **Volume management** - Bind mounts for configuration files
5. **Dependency management** - Ensuring proper startup order
6. **Configuration as code** - Version-controllable service definitions

## References

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Docker CLI Reference](https://docs.docker.com/engine/reference/run/)
- [HAProxy Documentation](http://www.haproxy.org/)
- [Node.js Docker Best Practices](https://nodejs.org/en/docs/guides/nodejs-docker-webapp/)
