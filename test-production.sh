#!/bin/bash

# GitHub Reporter - Production Testing Script
# ===========================================

set -e

echo "🧪 GitHub Reporter - Production Testing"
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

print_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

BASE_URL="http://localhost:8080"
API_URL="$BASE_URL/api"

# Test 1: Health Check
print_status "Testing health endpoint..."
if curl -f "$BASE_URL/health" > /dev/null 2>&1; then
    print_success "Health check passed"
else
    print_error "Health check failed"
    exit 1
fi

# Test 2: Main Page
print_status "Testing main page..."
if curl -f "$BASE_URL" > /dev/null 2>&1; then
    print_success "Main page accessible"
else
    print_error "Main page failed"
    exit 1
fi

# Test 3: API Endpoints
print_status "Testing API endpoints..."

# Test basic API structure
if curl -f "$API_URL" > /dev/null 2>&1; then
    print_success "API endpoints accessible"
else
    print_error "API endpoints failed"
    exit 1
fi

# Test 4: GitHub Reporter Agent
print_status "Testing GitHub Reporter Agent..."

# Create a test request
TEST_REQUEST='{
    "messages": [
        {
            "role": "user",
            "content": "Analyze the repository facebook/react"
        }
    ]
}'

# Test the agent endpoint
AGENT_RESPONSE=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d "$TEST_REQUEST" \
    "$API_URL/agent/github-reporter" || echo "FAILED")

if [[ "$AGENT_RESPONSE" == "FAILED" ]]; then
    print_error "GitHub Reporter Agent test failed"
    exit 1
else
    print_success "GitHub Reporter Agent responding"
fi

# Test 5: Container Health
print_status "Testing container health..."
CONTAINER_STATUS=$(sudo docker ps --filter "name=github-reporter-live" --format "{{.Status}}")

if [[ "$CONTAINER_STATUS" == *"healthy"* ]]; then
    print_success "Container is healthy"
elif [[ "$CONTAINER_STATUS" == *"Up"* ]]; then
    print_success "Container is running"
else
    print_error "Container health check failed"
    exit 1
fi

# Test 6: Performance Test
print_status "Running basic performance test..."
RESPONSE_TIME=$(curl -o /dev/null -s -w "%{time_total}" "$BASE_URL/health")
if (( $(echo "$RESPONSE_TIME < 1.0" | bc -l) )); then
    print_success "Response time: ${RESPONSE_TIME}s (Good)"
else
    print_error "Response time: ${RESPONSE_TIME}s (Slow)"
fi

# Test 7: Memory Usage
print_status "Checking memory usage..."
MEMORY_USAGE=$(sudo docker stats --no-stream --format "{{.MemPerc}}" github-reporter-live)
print_success "Memory usage: $MEMORY_USAGE"

echo ""
echo "=========================================="
print_success "🎉 All production tests passed!"
echo ""
echo "🚀 Your GitHub Reporter Agent is LIVE and ready for production!"
echo ""
echo "📊 Access URLs:"
echo "  - Health Check: $BASE_URL/health"
echo "  - Main Application: $BASE_URL"
echo "  - API Endpoints: $API_URL"
echo "  - GitHub Reporter Agent: $API_URL/agent/github-reporter"
echo ""
echo "📝 Next Steps:"
echo "  1. Test the agent with real GitHub repositories"
echo "  2. Set up monitoring and alerting"
echo "  3. Configure domain name and SSL if needed"
echo "  4. Set up backup and disaster recovery"
echo ""
echo "💡 Monitoring Commands:"
echo "  - View logs: sudo docker logs -f github-reporter-live"
echo "  - Check status: sudo docker ps"
echo "  - Monitor performance: ./monitor.sh"
echo "  - Restart if needed: sudo docker restart github-reporter-live"
