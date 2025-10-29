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

# Initialize counters
POSTGRES_OK=0
MINIO_OK=0
ICEBERG_OK=0
DUCKDB_OK=0
PROMETHEUS_OK=0
GRAFANA_OK=0
JAEGER_OK=0
LOKI_OK=0
OTEL_OK=0
PGEXPORTER_OK=0

echo -e "${BLUE}${INFO} Checking Docker Containers...${NC}"
echo ""

# 1. PostgreSQL Database
echo "1️⃣  PostgreSQL Database"
if docker ps --format '{{.Names}}' | grep -q "lakehouse-poc-postgres"; then
    echo -e "${GREEN}${CHECK}${NC} PostgreSQL is running"
    
    if docker exec lakehouse-poc-postgres pg_isready -U lakeuser >/dev/null 2>&1; then
        echo -e "${GREEN}${CHECK}${NC} PostgreSQL is ready and accepting connections"
        
        if docker exec lakehouse-poc-postgres psql -U lakeuser -lqt 2>/dev/null | cut -d \| -f 1 | grep -qw socialnet; then
            echo -e "${GREEN}${CHECK}${NC} Database 'socialnet' exists"
            POSTGRES_OK=1
        else
            echo -e "${YELLOW}${WARNING}${NC} Database 'socialnet' not found"
        fi
    else
        echo -e "${RED}${CROSS}${NC} PostgreSQL is not ready"
    fi
else
    echo -e "${RED}${CROSS}${NC} PostgreSQL is not running"
fi

# 2. MinIO Object Storage
echo ""
echo "2️⃣  MinIO Object Storage"
if docker ps --format '{{.Names}}' | grep -q "lakehouse-poc-minio"; then
    echo -e "${GREEN}${CHECK}${NC} MinIO is running"
    
    if curl -s http://localhost:9000/minio/health/live >/dev/null 2>&1; then
        echo -e "${GREEN}${CHECK}${NC} MinIO health endpoint responding"
        MINIO_OK=1
        
        if docker exec lakehouse-poc-minio mc ls local/warehouse >/dev/null 2>&1; then
            echo -e "${GREEN}${CHECK}${NC} MinIO 'warehouse' bucket exists"
        else
            echo -e "${YELLOW}${WARNING}${NC} MinIO 'warehouse' bucket not found"
        fi
    else
        echo -e "${RED}${CROSS}${NC} MinIO health endpoint not responding"
    fi
else
    echo -e "${RED}${CROSS}${NC} MinIO is not running"
fi

# 3. Iceberg REST Catalog
echo ""
echo "3️⃣  Iceberg REST Catalog"
if docker ps --format '{{.Names}}' | grep -q "lakehouse-poc-iceberg-rest"; then
    echo -e "${GREEN}${CHECK}${NC} Iceberg REST is running"
    
    if response=$(curl -s http://localhost:8181/v1/config 2>/dev/null); then
        if echo "$response" | grep -q "defaults\|overrides"; then
            echo -e "${GREEN}${CHECK}${NC} Iceberg REST catalog responding"
            
            if curl -s http://localhost:8181/v1/namespaces >/dev/null 2>&1; then
                echo -e "${GREEN}${CHECK}${NC} Iceberg REST namespaces endpoint accessible"
                ICEBERG_OK=1
            fi
        else
            echo -e "${YELLOW}${WARNING}${NC} Iceberg REST returned unexpected response"
        fi
    else
        echo -e "${RED}${CROSS}${NC} Iceberg REST not responding"
    fi
else
    echo -e "${RED}${CROSS}${NC} Iceberg REST is not running"
fi

# 4. DuckDB Query Service
echo ""
echo "4️⃣  DuckDB Query Service"
if docker ps --format '{{.Names}}' | grep -q "lakehouse-poc-duckdb"; then
    echo -e "${GREEN}${CHECK}${NC} DuckDB is running"
    
    if response=$(curl -s http://localhost:8082/health 2>/dev/null); then
        if echo "$response" | grep -q "healthy"; then
            echo -e "${GREEN}${CHECK}${NC} DuckDB service is healthy"
            
            if curl -s -X POST http://localhost:8082/query \
               -H "Content-Type: application/json" \
               -d '{"sql": "SELECT 1 as test"}' 2>/dev/null | grep -q "test"; then
                echo -e "${GREEN}${CHECK}${NC} DuckDB test query successful"
                DUCKDB_OK=1
            else
                echo -e "${YELLOW}${WARNING}${NC} DuckDB test query failed"
            fi
        else
            echo -e "${RED}${CROSS}${NC} DuckDB service unhealthy"
        fi
    else
        echo -e "${RED}${CROSS}${NC} DuckDB service not responding"
    fi
else
    echo -e "${RED}${CROSS}${NC} DuckDB is not running"
fi

# Observability Stack
echo ""
echo "=========================================="
echo "  OBSERVABILITY STACK"
echo "=========================================="

# 5. Prometheus
echo ""
echo "5️⃣  Prometheus (Metrics)"
if docker ps --format '{{.Names}}' | grep -q "lakehouse-poc-prometheus"; then
    echo -e "${GREEN}${CHECK}${NC} Prometheus is running"
    
    if curl -s http://localhost:9090/-/healthy >/dev/null 2>&1; then
        echo -e "${GREEN}${CHECK}${NC} Prometheus is healthy"
        PROMETHEUS_OK=1
    else
        echo -e "${RED}${CROSS}${NC} Prometheus is not responding"
    fi
else
    echo -e "${RED}${CROSS}${NC} Prometheus is not running"
fi

# 6. Grafana
echo ""
echo "6️⃣  Grafana (Visualization)"
if docker ps --format '{{.Names}}' | grep -q "lakehouse-poc-grafana"; then
    echo -e "${GREEN}${CHECK}${NC} Grafana is running"
    
    if curl -s http://localhost:3000/api/health >/dev/null 2>&1; then
        echo -e "${GREEN}${CHECK}${NC} Grafana is healthy"
        GRAFANA_OK=1
    else
        echo -e "${RED}${CROSS}${NC} Grafana is not responding"
    fi
else
    echo -e "${RED}${CROSS}${NC} Grafana is not running"
fi

# 7. Jaeger
echo ""
echo "7️⃣  Jaeger (Tracing)"
if docker ps --format '{{.Names}}' | grep -q "lakehouse-poc-jaeger"; then
    echo -e "${GREEN}${CHECK}${NC} Jaeger is running"
    
    if curl -s http://localhost:16686 >/dev/null 2>&1; then
        echo -e "${GREEN}${CHECK}${NC} Jaeger UI is accessible"
        JAEGER_OK=1
    else
        echo -e "${RED}${CROSS}${NC} Jaeger UI is not responding"
    fi
else
    echo -e "${RED}${CROSS}${NC} Jaeger is not running"
fi

# 8. Loki
echo ""
echo "8️⃣  Loki (Logs)"
if docker ps --format '{{.Names}}' | grep -q "lakehouse-poc-loki"; then
    echo -e "${GREEN}${CHECK}${NC} Loki is running"
    
    if curl -s http://localhost:3100/ready >/dev/null 2>&1; then
        echo -e "${GREEN}${CHECK}${NC} Loki is ready"
        LOKI_OK=1
    else
        echo -e "${RED}${CROSS}${NC} Loki is not responding"
    fi
else
    echo -e "${RED}${CROSS}${NC} Loki is not running"
fi

# 9. OpenTelemetry Collector
echo ""
echo "9️⃣  OpenTelemetry Collector"
if docker ps --format '{{.Names}}' | grep -q "lakehouse-poc-otel-collector"; then
    echo -e "${GREEN}${CHECK}${NC} OTEL Collector is running"
    
    if curl -s http://localhost:13133 >/dev/null 2>&1; then
        echo -e "${GREEN}${CHECK}${NC} OTEL Collector is healthy"
        OTEL_OK=1
    else
        echo -e "${RED}${CROSS}${NC} OTEL Collector is not responding"
    fi
else
    echo -e "${RED}${CROSS}${NC} OTEL Collector is not running"
fi

# 10. PostgreSQL Exporter
echo ""
echo "🔟 PostgreSQL Exporter"
if docker ps --format '{{.Names}}' | grep -q "lakehouse-poc-postgres-exporter"; then
    echo -e "${GREEN}${CHECK}${NC} PostgreSQL Exporter is running"
    
    if curl -s http://localhost:9187/metrics >/dev/null 2>&1; then
        echo -e "${GREEN}${CHECK}${NC} PostgreSQL Exporter metrics available"
        PGEXPORTER_OK=1
    else
        echo -e "${RED}${CROSS}${NC} PostgreSQL Exporter is not responding"
    fi
else
    echo -e "${RED}${CROSS}${NC} PostgreSQL Exporter is not running"
fi

# Summary
echo ""
echo "=========================================="
echo "  Summary"
echo "=========================================="
echo ""

TOTAL=10
HEALTHY=$((POSTGRES_OK + MINIO_OK + ICEBERG_OK + DUCKDB_OK + PROMETHEUS_OK + GRAFANA_OK + JAEGER_OK + LOKI_OK + OTEL_OK + PGEXPORTER_OK))

if [ $HEALTHY -eq $TOTAL ]; then
    echo -e "${GREEN}${CHECK} All services are healthy! (${HEALTHY}/${TOTAL})${NC}"
    EXIT_CODE=0
elif [ $HEALTHY -gt 0 ]; then
    echo -e "${YELLOW}${WARNING} Some services are not healthy (${HEALTHY}/${TOTAL})${NC}"
    EXIT_CODE=1
else
    echo -e "${RED}${CROSS} No services are healthy (${HEALTHY}/${TOTAL})${NC}"
    EXIT_CODE=2
fi

echo ""
echo "🌐 Access Points:"
echo "   • MinIO Console:    http://localhost:9001 (minioadmin/minioadmin)"
echo "   • DuckDB API:       http://localhost:8082"
echo "   • Iceberg REST:     http://localhost:8181/v1/*"
echo "   • PostgreSQL:       localhost:5433 (lakeuser/lakepass123)"
echo ""
echo "   • Grafana:          http://localhost:3000 (admin/admin)"
echo "   • Prometheus:       http://localhost:9090"
echo "   • Jaeger UI:        http://localhost:16686"
echo "   • Loki:             http://localhost:3100"
echo "   • OTEL Collector:   http://localhost:13133 (health)"

echo ""
echo "=========================================="
echo ""

# Show docker-compose status
echo -e "${BLUE}${INFO} Docker Compose Status:${NC}"
echo ""
docker-compose ps
echo ""

exit $EXIT_CODE
