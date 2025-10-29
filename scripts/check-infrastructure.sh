#!/bin/bash

# ASIL Lakehouse POC - Infrastructure Health Check Script
# This script automatically checks all services and provides a detailed status report

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Emojis
CHECK="✅"
CROSS="❌"
WARNING="⚠️"
INFO="ℹ️"

echo ""
echo "=========================================="
echo "  ASIL Lakehouse Infrastructure Check"
echo "=========================================="
echo ""

# Function to check if a service is running
check_service_running() {
    local service_name=$1
    local container_name=$2
    
    if docker ps --format '{{.Names}}' | grep -q "^${container_name}$"; then
        echo -e "${GREEN}${CHECK}${NC} ${service_name} is running"
        return 0
    else
        echo -e "${RED}${CROSS}${NC} ${service_name} is NOT running"
        return 1
    fi
}

# Function to check HTTP endpoint
check_http_endpoint() {
    local service_name=$1
    local url=$2
    local expected_code=${3:-200}
    
    if response=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null); then
        if [ "$response" -eq "$expected_code" ]; then
            echo -e "${GREEN}${CHECK}${NC} ${service_name} HTTP endpoint responding (${response})"
            return 0
        else
            echo -e "${YELLOW}${WARNING}${NC} ${service_name} returned HTTP ${response} (expected ${expected_code})"
            return 1
        fi
    else
        echo -e "${RED}${CROSS}${NC} ${service_name} HTTP endpoint not responding"
        return 1
    fi
}

# Function to check PostgreSQL
check_postgres() {
    if docker exec lakehouse-poc-postgres pg_isready -U lakeuser >/dev/null 2>&1; then
        echo -e "${GREEN}${CHECK}${NC} PostgreSQL is ready and accepting connections"
        
        # Check if database exists
        if docker exec lakehouse-poc-postgres psql -U lakeuser -lqt 2>/dev/null | cut -d \| -f 1 | grep -qw socialnet; then
            echo -e "${GREEN}${CHECK}${NC} Database 'socialnet' exists"
        else
            echo -e "${YELLOW}${WARNING}${NC} Database 'socialnet' not found"
        fi
        return 0
    else
        echo -e "${RED}${CROSS}${NC} PostgreSQL is not ready"
        return 1
    fi
}

# Function to check MinIO
check_minio() {
    if curl -s http://localhost:9000/minio/health/live >/dev/null 2>&1; then
        echo -e "${GREEN}${CHECK}${NC} MinIO health endpoint responding"
        
        # Check if warehouse bucket exists
        if docker run --rm --network asil-lakehouse-poc_lakehouse-network \
           -e MINIO_ROOT_USER=minioadmin \
           -e MINIO_ROOT_PASSWORD=minioadmin \
           minio/mc ls myminio 2>/dev/null | grep -q warehouse; then
            echo -e "${GREEN}${CHECK}${NC} MinIO 'warehouse' bucket exists"
        else
            echo -e "${YELLOW}${WARNING}${NC} MinIO 'warehouse' bucket not found"
        fi
        return 0
    else
        echo -e "${RED}${CROSS}${NC} MinIO health endpoint not responding"
        return 1
    fi
}

# Function to check DuckDB
check_duckdb() {
    if response=$(curl -s http://localhost:8082/health 2>/dev/null); then
        if echo "$response" | grep -q "healthy"; then
            echo -e "${GREEN}${CHECK}${NC} DuckDB service is healthy"
            
            # Try a test query
            if curl -s -X POST http://localhost:8082/query \
               -H "Content-Type: application/json" \
               -d '{"sql": "SELECT 1 as test"}' 2>/dev/null | grep -q "test"; then
                echo -e "${GREEN}${CHECK}${NC} DuckDB test query successful"
            else
                echo -e "${YELLOW}${WARNING}${NC} DuckDB test query failed"
            fi
            return 0
        else
            echo -e "${RED}${CROSS}${NC} DuckDB service unhealthy"
            return 1
        fi
    else
        echo -e "${RED}${CROSS}${NC} DuckDB service not responding"
        return 1
    fi
}

# Function to check Iceberg REST
check_iceberg() {
    if response=$(curl -s http://localhost:8181/v1/config 2>/dev/null); then
        if echo "$response" | grep -q "defaults\|overrides"; then
            echo -e "${GREEN}${CHECK}${NC} Iceberg REST catalog responding"
            
            # Check namespaces endpoint
            if curl -s http://localhost:8181/v1/namespaces >/dev/null 2>&1; then
                echo -e "${GREEN}${CHECK}${NC} Iceberg REST namespaces endpoint accessible"
            fi
            return 0
        else
            echo -e "${YELLOW}${WARNING}${NC} Iceberg REST returned unexpected response"
            return 1
        fi
    else
        echo -e "${RED}${CROSS}${NC} Iceberg REST not responding"
        return 1
    fi
}

# Main checks
echo -e "${BLUE}${INFO} Checking Docker Containers...${NC}"
echo ""

POSTGRES_OK=0
MINIO_OK=0
ICEBERG_OK=0
DUCKDB_OK=0

# Check if containers are running
echo "1️⃣  PostgreSQL Database"
if check_service_running "PostgreSQL" "lakehouse-poc-postgres"; then
    check_postgres && POSTGRES_OK=1
fi
echo ""

echo "2️⃣  MinIO Object Storage"
if check_service_running "MinIO" "lakehouse-poc-minio"; then
    check_minio && MINIO_OK=1
fi
echo ""

echo "3️⃣  Iceberg REST Catalog"
if check_service_running "Iceberg REST" "lakehouse-poc-iceberg-rest"; then
    check_iceberg && ICEBERG_OK=1
fi
echo ""

echo "4️⃣  DuckDB Query Service"
if check_service_running "DuckDB" "lakehouse-poc-duckdb"; then
    check_duckdb && DUCKDB_OK=1
fi
echo ""

# Summary
echo "=========================================="
echo "  Summary"
echo "=========================================="
echo ""

TOTAL=4
HEALTHY=$((POSTGRES_OK + MINIO_OK + ICEBERG_OK + DUCKDB_OK))

if [ $HEALTHY -eq $TOTAL ]; then
    echo -e "${GREEN}${CHECK} All services are healthy! (${HEALTHY}/${TOTAL})${NC}"
    echo ""
    echo "🌐 Access Points:"
    echo "   • MinIO Console:    http://localhost:9001 (minioadmin/minioadmin)"
    echo "   • DuckDB API:       http://localhost:8082"
    echo "   • Iceberg REST:     http://localhost:8181/v1/*"
    echo "   • PostgreSQL:       localhost:5433 (lakeuser/lakepass123)"
    EXIT_CODE=0
elif [ $HEALTHY -gt 0 ]; then
    echo -e "${YELLOW}${WARNING} Some services are not healthy (${HEALTHY}/${TOTAL})${NC}"
    echo ""
    echo "Run 'docker-compose logs <service>' to see details"
    EXIT_CODE=1
else
    echo -e "${RED}${CROSS} No services are healthy (${HEALTHY}/${TOTAL})${NC}"
    echo ""
    echo "Run 'docker-compose up -d' to start services"
    EXIT_CODE=2
fi

echo ""
echo "=========================================="
echo ""

# Show docker-compose status
echo -e "${BLUE}${INFO} Docker Compose Status:${NC}"
echo ""
docker-compose ps
echo ""

exit $EXIT_CODE
