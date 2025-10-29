# Infrastructure Check & Access Guide

## 🔍 Service Status Check

### Check All Services
```bash
docker-compose ps
```

Expected output:
```
NAME                         STATUS                   PORTS
lakehouse-poc-postgres       Up (healthy)             0.0.0.0:5433->5432/tcp
lakehouse-poc-minio          Up (healthy)             0.0.0.0:9000-9001->9000-9001/tcp
lakehouse-poc-minio-init     Exited (0)               -
lakehouse-poc-iceberg-rest   Up                       0.0.0.0:8181->8181/tcp
lakehouse-poc-duckdb         Up                       0.0.0.0:8082->8082/tcp
```

---

## 🌐 Service Access Points

### 1. PostgreSQL Database
**⚠️ PostgreSQL is NOT a web service - you cannot access it via browser!**

**Access via CLI:**
```bash
# Using psql (if installed)
psql -h localhost -p 5433 -U lakeuser -d socialnet

# Using Docker
docker exec -it lakehouse-poc-postgres psql -U lakeuser -d socialnet
```

**Credentials:**
- Host: `localhost`
- Port: `5433` (changed from 5432 to avoid conflict)
- Database: `socialnet`
- Username: `lakeuser`
- Password: `lakepass123`

**Connection String:**
```
postgresql://lakeuser:lakepass123@localhost:5433/socialnet
```

---

### 2. MinIO Object Storage

**Web Console:** http://localhost:9001

**Credentials:**
- Username: `minioadmin`
- Password: `minioadmin`

**S3 API Endpoint:** http://localhost:9000

**What you'll see:**
- After login, you should see the `warehouse` bucket
- This is where Iceberg table data will be stored

**Test MinIO:**
```bash
# Check if MinIO is responding
curl http://localhost:9000/minio/health/live

# List buckets (requires mc client)
docker run --rm --network asil-lakehouse-poc_lakehouse-network \
  minio/mc ls myminio
```

---

### 3. Iceberg REST Catalog

**API Endpoint:** http://localhost:8181

**⚠️ The root path (/) returns an error - this is normal!**

The Iceberg REST catalog doesn't have a web UI. It's an API service.

**Valid Endpoints:**
```bash
# Check configuration (should return JSON)
curl http://localhost:8181/v1/config

# List namespaces (will be empty initially)
curl http://localhost:8181/v1/namespaces
```

**What the error means:**
- `GET /` → ❌ Not a valid endpoint
- `GET /v1/config` → ✅ Valid endpoint
- `GET /v1/namespaces` → ✅ Valid endpoint

---

### 4. DuckDB Service

**API Endpoint:** http://localhost:8082

**Check if running:**
```bash
# Health check
curl http://localhost:8082/health

# Root endpoint (service info)
curl http://localhost:8082/
```

**If DuckDB is not available:**
```bash
# Check logs
docker-compose logs duckdb

# Check if container is running
docker-compose ps duckdb

# Restart if needed
docker-compose restart duckdb
```

**Test Query:**
```bash
curl -X POST http://localhost:8082/query \
  -H "Content-Type: application/json" \
  -d '{"sql": "SELECT 1 as test"}'
```

---

## 🔧 Troubleshooting

### DuckDB Not Starting

**1. Check logs:**
```bash
docker-compose logs duckdb
```

**2. Check dependencies:**
```bash
# DuckDB depends on MinIO and Iceberg REST
docker-compose ps minio iceberg-rest
```

**3. Restart services in order:**
```bash
# Stop all
docker-compose down

# Start in order
docker-compose up -d postgres minio
sleep 10  # Wait for MinIO to be healthy
docker-compose up -d minio-init iceberg-rest
sleep 5
docker-compose up -d duckdb
```

**4. Check if port 8082 is available:**
```bash
lsof -i :8082
```

---

### PostgreSQL Connection Issues

**If you can't connect:**

1. **Check if running:**
```bash
docker-compose ps postgres
```

2. **Check logs:**
```bash
docker-compose logs postgres
```

3. **Test connection:**
```bash
docker exec -it lakehouse-poc-postgres pg_isready -U lakeuser
```

---

### MinIO Login Issues

**If you can't login to MinIO console:**

1. **Verify credentials:**
   - Username: `minioadmin`
   - Password: `minioadmin`

2. **Check if MinIO is healthy:**
```bash
docker-compose ps minio
# Should show "Up (healthy)"
```

3. **Check logs:**
```bash
docker-compose logs minio
```

4. **Restart MinIO:**
```bash
docker-compose restart minio
```

---

## 📊 Complete Service Check Script

Create this script to check all services:

```bash
#!/bin/bash
# save as: check-services.sh

echo "🔍 Checking Lakehouse Services..."
echo ""

echo "1️⃣ PostgreSQL (Database)"
docker exec lakehouse-poc-postgres pg_isready -U lakeuser && echo "✅ PostgreSQL is ready" || echo "❌ PostgreSQL is not ready"
echo ""

echo "2️⃣ MinIO (Object Storage)"
curl -s http://localhost:9000/minio/health/live > /dev/null && echo "✅ MinIO is healthy" || echo "❌ MinIO is not responding"
echo ""

echo "3️⃣ Iceberg REST Catalog"
curl -s http://localhost:8181/v1/config > /dev/null && echo "✅ Iceberg REST is responding" || echo "❌ Iceberg REST is not responding"
echo ""

echo "4️⃣ DuckDB Service"
curl -s http://localhost:8082/health > /dev/null && echo "✅ DuckDB is healthy" || echo "❌ DuckDB is not responding"
echo ""

echo "📋 Docker Compose Status:"
docker-compose ps
```

**Run it:**
```bash
chmod +x check-services.sh
./check-services.sh
```

---

## 🎯 Quick Access Summary

| Service | Type | Access | Credentials |
|---------|------|--------|-------------|
| **PostgreSQL** | Database | `localhost:5433` | user: `lakeuser`<br>pass: `lakepass123` |
| **MinIO Console** | Web UI | http://localhost:9001 | user: `minioadmin`<br>pass: `minioadmin` |
| **MinIO S3 API** | API | http://localhost:9000 | Same as console |
| **Iceberg REST** | API | http://localhost:8181/v1/* | No auth (internal) |
| **DuckDB** | API | http://localhost:8082 | No auth (internal) |

---

## 📝 Important Notes

### What You CAN'T Do:
- ❌ Access PostgreSQL via browser (it's not a web service)
- ❌ Access Iceberg REST root path `/` (use `/v1/*` endpoints)
- ❌ Access services before they're healthy

### What You CAN Do:
- ✅ Access MinIO console at http://localhost:9001
- ✅ Query DuckDB via HTTP API at http://localhost:8082
- ✅ Connect to PostgreSQL via psql or any PostgreSQL client
- ✅ Use Iceberg REST API endpoints at http://localhost:8181/v1/*

---

## 🚀 Next Steps

Once all services are healthy:

1. **Verify MinIO buckets:**
   - Login to http://localhost:9001
   - Check that `warehouse` bucket exists

2. **Test DuckDB:**
   ```bash
   curl http://localhost:8082/health
   ```

3. **Implement PostgreSQL schema:**
   - Edit `docker/postgres/init.sql`
   - Restart postgres: `docker-compose restart postgres`

4. **Start building ETL and AI Agent services**
