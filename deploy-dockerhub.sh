#!/bin/bash

# GitHub Reporter - Docker Hub Deployment Script
# ==============================================

set -e

echo "🚀 GitHub Reporter - Docker Hub Deployment"
echo "==========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Configuration
DOCKER_USERNAME=${DOCKER_USERNAME:-"your-docker-username"}
IMAGE_NAME="github-reporter-agent"
TAG="latest"
FULL_IMAGE_NAME="$DOCKER_USERNAME/$IMAGE_NAME:$TAG"

print_status "Building Docker image for production deployment..."
print_status "Target: $FULL_IMAGE_NAME"

# Check if user is logged in to Docker Hub
if ! docker info | grep -q "Username:"; then
    print_warning "Not logged in to Docker Hub"
    print_status "Please login to Docker Hub:"
    echo "docker login"
    echo ""
    print_status "Or set your Docker Hub username:"
    echo "export DOCKER_USERNAME=your-docker-username"
    echo ""
    exit 1
fi

# Build the production image
print_status "Building production Docker image..."
sudo docker build -f Dockerfile.production -t $FULL_IMAGE_NAME .

print_success "Docker image built successfully!"

# Test the image locally first
print_status "Testing image locally..."
sudo docker run -d -p 8081:8080 --name github-reporter-test $FULL_IMAGE_NAME

# Wait for container to start
sleep 30

# Test health
if curl -f http://localhost:8081/health > /dev/null 2>&1; then
    print_success "Local test passed!"
    sudo docker stop github-reporter-test
    sudo docker rm github-reporter-test
else
    print_error "Local test failed!"
    sudo docker logs github-reporter-test
    sudo docker stop github-reporter-test
    sudo docker rm github-reporter-test
    exit 1
fi

# Push to Docker Hub
print_status "Pushing to Docker Hub..."
sudo docker push $FULL_IMAGE_NAME

print_success "Successfully pushed to Docker Hub!"
print_success "Image available at: $FULL_IMAGE_NAME"

echo ""
echo "🎉 Docker Hub deployment complete!"
echo ""
echo "📦 Your image is now available at:"
echo "   https://hub.docker.com/r/$DOCKER_USERNAME/$IMAGE_NAME"
echo ""
echo "🚀 Ready for Nosana deployment!"
echo ""
echo "Next steps:"
echo "1. Update nosana_mastra.json with your Docker Hub image"
echo "2. Deploy to Nosana network"
echo "3. Get public URL for global access"
