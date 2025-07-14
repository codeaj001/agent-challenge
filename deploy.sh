#!/bin/bash

# GitHub Reporter - Production Deployment Script
# ==============================================

set -e  # Exit on any error

echo "🚀 GitHub Reporter - Production Deployment"
echo "==========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Create necessary directories
print_status "Creating necessary directories..."
mkdir -p data logs ssl

# Check if .env.production exists
if [ ! -f .env.production ]; then
    print_error ".env.production file not found!"
    print_status "Please configure your .env.production file with:"
    echo "  - API_BASE_URL (your production AI endpoint)"
    echo "  - MODEL_NAME_AT_ENDPOINT (your model name)"
    echo "  - GITHUB_TOKEN (your GitHub token for higher rate limits)"
    exit 1
fi

# Build the application
print_status "Building the application..."
pnpm run build

# Stop existing containers
print_status "Stopping existing containers..."
docker-compose down

# Build and start containers
print_status "Building and starting containers..."
docker-compose up -d --build

# Wait for health check
print_status "Waiting for application to be ready..."
sleep 30

# Check health
print_status "Checking application health..."
if curl -f http://localhost:8080/health > /dev/null 2>&1; then
    print_success "Application is healthy and running!"
    print_success "🎉 Deployment successful!"
    echo ""
    echo "📊 Application URLs:"
    echo "  - Health Check: http://localhost:8080/health"
    echo "  - Main Application: http://localhost:8080"
    echo "  - API Endpoints: http://localhost:8080/api"
    echo ""
    echo "📝 Useful Commands:"
    echo "  - View logs: docker-compose logs -f github-reporter"
    echo "  - Stop application: docker-compose down"
    echo "  - Restart application: docker-compose restart"
    echo "  - View container status: docker-compose ps"
else
    print_error "Application health check failed!"
    print_status "Checking logs..."
    docker-compose logs github-reporter
    exit 1
fi

# Show container status
print_status "Container status:"
docker-compose ps
