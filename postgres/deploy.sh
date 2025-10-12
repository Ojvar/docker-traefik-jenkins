#!/bin/bash

# PostgreSQL Stack Deployment Script
# This script deploys the PostgreSQL stack with pgAdmin

set -e

echo "� Building PostgreSQL image..."
docker build -f Dockerfile.postgres -t ojvar/postgres-custom:17 .

echo "🚀 Building pgAdmin image..."
docker build -f Dockerfile.pgadmin -t ojvar/pgadmin-custom:latest .

echo "🐘 Deploying PostgreSQL Stack..."

# Check if Docker Swarm is initialized
if ! docker info | grep -q "Swarm: active"; then
    echo "❌ Docker Swarm is not initialized. Please run 'docker swarm init' first."
    exit 1
fi

# Check if the public-net network exists
if ! docker network ls | grep -q "public-net"; then
    echo "🌐 Creating public-net network..."
    docker network create --driver overlay --attachable public-net
else
    echo "✅ public-net network already exists"
fi

# Deploy the PostgreSQL stack
echo "🚀 Building and deploying PostgreSQL services..."
docker stack deploy -c docker-compose.yml postgres-stack

echo "✅ PostgreSQL Stack deployed successfully!"
echo ""
echo "📋 Service Information:"
echo "  - PostgreSQL Database: Available on port 5432 (internal)"
echo "  - pgAdmin Web Interface: http://pg.ojvar.xyz"
echo "  - Default pgAdmin credentials: admin@ojvar.xyz / admin"
echo ""
echo "🔧 To check service status:"
echo "  docker service ls | grep postgres"
echo ""
echo "📊 To view logs:"
echo "  docker service logs postgres-stack_pgadmin"
echo "  docker service logs postgres-stack_postgres"
