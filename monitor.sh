#!/bin/bash

# GitHub Reporter - Production Monitoring Script
# ==============================================

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

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check application health
check_health() {
    print_status "Checking application health..."
    
    if curl -f http://localhost:8080/health > /dev/null 2>&1; then
        print_success "✅ Application is healthy"
        return 0
    else
        print_error "❌ Application health check failed"
        return 1
    fi
}

# Check container status
check_containers() {
    print_status "Checking container status..."
    
    if docker-compose ps | grep -q "Up"; then
        print_success "✅ Containers are running"
        docker-compose ps
    else
        print_error "❌ Some containers are not running"
        docker-compose ps
        return 1
    fi
}

# Check disk usage
check_disk() {
    print_status "Checking disk usage..."
    
    DISK_USAGE=$(df -h . | awk 'NR==2 {print $5}' | sed 's/%//')
    
    if [ $DISK_USAGE -gt 80 ]; then
        print_error "❌ Disk usage is at ${DISK_USAGE}% - Consider cleanup"
        return 1
    elif [ $DISK_USAGE -gt 60 ]; then
        print_warning "⚠️  Disk usage is at ${DISK_USAGE}% - Monitor closely"
    else
        print_success "✅ Disk usage is healthy (${DISK_USAGE}%)"
    fi
}

# Check memory usage
check_memory() {
    print_status "Checking memory usage..."
    
    CONTAINER_MEMORY=$(docker stats --no-stream --format "table {{.Container}}\t{{.MemUsage}}" | grep github-reporter)
    
    if [ -n "$CONTAINER_MEMORY" ]; then
        print_success "✅ Memory usage: $CONTAINER_MEMORY"
    else
        print_error "❌ Could not get memory usage"
        return 1
    fi
}

# Check logs for errors
check_logs() {
    print_status "Checking recent logs for errors..."
    
    ERROR_COUNT=$(docker-compose logs --tail=100 github-reporter | grep -i "error" | wc -l)
    
    if [ $ERROR_COUNT -gt 0 ]; then
        print_warning "⚠️  Found $ERROR_COUNT error(s) in recent logs"
        print_status "Recent errors:"
        docker-compose logs --tail=10 github-reporter | grep -i "error"
    else
        print_success "✅ No errors found in recent logs"
    fi
}

# Main monitoring function
monitor() {
    echo "🔍 GitHub Reporter - Production Monitoring"
    echo "=========================================="
    echo "$(date)"
    echo ""
    
    OVERALL_STATUS=0
    
    if ! check_health; then
        OVERALL_STATUS=1
    fi
    
    echo ""
    
    if ! check_containers; then
        OVERALL_STATUS=1
    fi
    
    echo ""
    
    if ! check_disk; then
        OVERALL_STATUS=1
    fi
    
    echo ""
    
    if ! check_memory; then
        OVERALL_STATUS=1
    fi
    
    echo ""
    
    check_logs
    
    echo ""
    echo "=========================================="
    
    if [ $OVERALL_STATUS -eq 0 ]; then
        print_success "🎉 All systems are healthy!"
    else
        print_error "⚠️  Some issues detected - please review above"
    fi
    
    return $OVERALL_STATUS
}

# Show help
show_help() {
    echo "GitHub Reporter - Production Monitoring"
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  monitor    Run full monitoring check (default)"
    echo "  health     Check application health only"
    echo "  logs       Show recent logs"
    echo "  stats      Show container statistics"
    echo "  help       Show this help message"
}

# Handle command line arguments
case "${1:-monitor}" in
    "monitor")
        monitor
        ;;
    "health")
        check_health
        ;;
    "logs")
        print_status "Showing recent logs..."
        docker-compose logs --tail=50 -f github-reporter
        ;;
    "stats")
        print_status "Container statistics:"
        docker stats github-reporter-app
        ;;
    "help")
        show_help
        ;;
    *)
        print_error "Unknown option: $1"
        show_help
        exit 1
        ;;
esac
