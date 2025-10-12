#!/usr/bin/env bash
# ================================================================
# build-images.sh
# Build and optionally push Docker images for PostgreSQL and pgAdmin
# for Docker Swarm deployment.
# ================================================================

# Exit immediately on error
set -e

# ------------------------------
# CONFIGURATION
# ------------------------------
# Change these if pushing to Docker Hub or another registry
REGISTRY_USER="ojvar"   # <-- change this to your Docker Hub username
POSTGRES_IMAGE="postgres-custom"
PGADMIN_IMAGE="pgadmin-custom"

POSTGRES_TAG="17"
PGADMIN_TAG="latest"

# ------------------------------
# BUILD IMAGES
# ------------------------------
echo "🔧 Building custom PostgreSQL image..."
docker build -t ${POSTGRES_IMAGE}:${POSTGRES_TAG} -f Dockerfile.postgres .

echo "🔧 Building custom pgAdmin image..."
docker build -t ${PGADMIN_IMAGE}:${PGADMIN_TAG} -f Dockerfile.pgadmin .

# ------------------------------
# OPTIONAL: TAG FOR REGISTRY
# ------------------------------
if [ -n "$REGISTRY_USER" ]; then
  echo "🏷️  Tagging images for Docker Hub registry..."
  docker tag ${POSTGRES_IMAGE}:${POSTGRES_TAG} ${REGISTRY_USER}/${POSTGRES_IMAGE}:${POSTGRES_TAG}
  docker tag ${PGADMIN_IMAGE}:${PGADMIN_TAG} ${REGISTRY_USER}/${PGADMIN_IMAGE}:${PGADMIN_TAG}
fi

# ------------------------------
# OPTIONAL: PUSH TO REGISTRY
# ------------------------------
read -p "Do you want to push images to registry ($REGISTRY_USER)? [y/N]: " PUSH
if [[ "$PUSH" =~ ^[Yy]$ ]]; then
  echo "🚀 Pushing images to Docker Hub..."
  docker push ${REGISTRY_USER}/${POSTGRES_IMAGE}:${POSTGRES_TAG}
  docker push ${REGISTRY_USER}/${PGADMIN_IMAGE}:${PGADMIN_TAG}
  echo "✅ Images pushed successfully."
else
  echo "ℹ️ Skipped pushing images to registry."
fi

# ------------------------------
# DONE
# ------------------------------
echo "✅ All images built successfully!"
echo ""
echo "Available images:"
docker images | grep -E "${POSTGRES_IMAGE}|${PGADMIN_IMAGE}"
echo ""
echo "You can now deploy with:"
echo "  docker stack deploy -c docker-compose.yml ojvar-postgres-stack"
