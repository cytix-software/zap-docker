#!/bin/bash
set -e

# Retrieve the PAT from the environment variable, or prompt if it's not set.
if [ -z "$GHCR_PAT" ]; then
  read -s -p "Enter your GitHub Container Registry PAT: " GHCR_PAT
  echo
fi

# Build the Docker image and capture the image ID.
echo "Building Docker image..."
IMAGE_ID=$(docker build -q .)
echo "Built image ID: $IMAGE_ID"

# Extract the hash part (remove the 'sha256:' prefix) from the image ID.
HASH=$(echo "$IMAGE_ID" | sed 's/^sha256://')

# Construct the final tag based on your previous naming convention.
FINAL_TAG="ghcr.io/cytix-software/zap-docker:sha256-${HASH}.sig"
echo "Tagging image as: $FINAL_TAG"
docker tag "$IMAGE_ID" "$FINAL_TAG"

# Log in to GitHub Container Registry using the PAT.
echo "Logging into GitHub Container Registry..."
echo "$GHCR_PAT" | docker login ghcr.io -u cytix-software --password-stdin

# Push the Docker image with the dynamically generated tag.
echo "Pushing Docker image..."
docker push "$FINAL_TAG"

echo "Docker image pushed successfully!"
