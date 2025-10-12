# Docker Swarm Stack with Traefik, Jenkins, and PostgreSQL

This repository provides a **Docker Swarm-based deployment** of:

- **Traefik v3** as a reverse proxy and load balancer
- **Jenkins** for continuous integration and delivery (CI/CD)
- **PostgreSQL** database with **pgAdmin** web interface

It is designed to run on **Manjaro Linux** (or any Linux with Docker Swarm), with separate stacks for Traefik and Jenkins, using a shared overlay network `public-net`.  

---

## 🚀 Features

- Traefik reverse proxy with **dynamic configuration**
- Local volumes for persistent Jenkins and Traefik data
- Dashboard accessible at `http://dashboard.traefik.ojvar.xyz`
- Jenkins accessible at `http://jenkins.ojvar.xyz`
- PostgreSQL with pgAdmin accessible at `http://pg.ojvar.xyz`
- Separate Docker stacks for easier management
- Optional HTTPS support for production
- BasicAuth protection for Traefik dashboard

---

## 📂 Project Structure

project-root/  
│
├── deploy.sh # Script to start/stop/restart stacks  
├── .gitignore  
├── README.md  
├── traefik/  
│ ├── docker-compose.yml  
│ ├── traefik.yml  
│ ├── dynamic.yml  
│ └── data/  
│ └── acme.json  
├── jenkins/  
│ ├── docker-compose.yml  
│ └── jenkins_home/  
└── postgres/  
├── docker-compose.yml  
├── Dockerfile.postgres  
├── Dockerfile.pgadmin  
├── postgresql.conf  
├── pg_hba.conf  
├── servers.json  
├── deploy.sh  
├── README.md  
├── postgres_data/  
└── pgadmin_data/  

---

## ⚙️ Requirements

- Docker >= 23.x
- Docker Compose >= 2.x (or native Swarm stack support)
- Git (optional, for cloning repo)


## 🔧 Setup Instructions

### 1. Initialize Docker Swarm
```bash
docker swarm init
```

### 2. Update /etc/hosts for local testing
```
127.0.0.1 traefik.ojvar.xyz
127.0.0.1 dashboard.traefik.ojvar.xyz
127.0.0.1 jenkins.ojvar.xyz
127.0.0.1 pg.ojvar.xyz
```

### 3. Run the deploy script
```
# Start all services
./deploy.sh start

# Stop all services
./deploy.sh stop

# Restart services
./deploy.sh restart

# Check stack and service status
./deploy.sh status
```

## 🔑 Access

| Service                     | URL                                 | Notes                             |
|------------------------------|------------------------------------|----------------------------------|
| Traefik Dashboard             | `http://dashboard.traefik.ojvar.xyz` | Protected by BasicAuth            |
| Jenkins                       | `http://jenkins.ojvar.xyz`         | Default Jenkins port 8080 inside container |
| pgAdmin (PostgreSQL)          | `http://pg.ojvar.xyz`              | Default: admin@ojvar.xyz / admin  |
| PostgreSQL (Direct)           | `localhost:5432`                   | Routed through Traefik           |
| Traefik (main entrypoint)     | `http://traefik.ojvar.xyz`         | Can route other apps via labels   |

> **BasicAuth** credentials for the dashboard are defined in `traefik/dynamic.yml`. Update as needed.


## 🔒 Production Notes

- To enable HTTPS with Let's Encrypt, uncomment websecure and ACME sections in traefik.yml and dynamic.yml.

- Redirect HTTP → HTTPS using the redirect-to-https middleware.

- For security, disable api.insecure in production.

## 💾 Data Persistence

- Traefik certificates: traefik/data/acme.json
- Jenkins data: jenkins/jenkins_home/
- PostgreSQL data: postgres/postgres_data/
- pgAdmin data: postgres/pgadmin_data/

These directories are mounted as volumes and should not be committed to Git (.gitignore).

## ⚡ Tips

- Update your Jenkins container to include Docker inside if you need to run builds with Docker.
- Traefik logs can be enabled via `traefik.yml` and stored in `traefik/logs/`.
- Use `docker service logs <service_name> -f` to debug issues in real-time.

## 📜 References

- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [Jenkins Official Docker Image](https://hub.docker.com/r/jenkins/jenkins)
- [Docker Swarm Stack Docs](https://docs.docker.com/engine/swarm/stack-deploy/)
