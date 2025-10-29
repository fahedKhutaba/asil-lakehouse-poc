# Lakehouse Architecture

## Overview

This document explains how Apache Iceberg is integrated into our lakehouse architecture.

## Apache Iceberg Integration

### What is Apache Iceberg?

Apache Iceberg is an open table format for huge analytic datasets. It provides:
- **ACID transactions** on data lakes
- **Schema evolution** without rewriting data
- **Time travel** and versioning
- **Hidden partitioning** for better performance
- **Efficient metadata management**

### How We Use Iceberg

#### 1. **Iceberg REST Catalog** (Port 8181)

```yaml
iceberg-rest:
  image: tabulario/iceberg-rest:latest
  ports:
    - "8181:8181"
```

**Purpose:**
- Manages Iceberg table metadata
- Tracks table schemas, partitions, and snapshots
- Provides REST API for table operations

**Why no separate Docker folder?**
- We use the official pre-built image from Tabular
- No custom configuration needed beyond environment variables
- Configuration is done via environment variables in docker-compose.yml

#### 2. **Storage Layer** (MinIO)

```yaml
minio:
  image: minio/minio:latest
  ports:
    - "9000:9000"  # S3 API
    - "9001:9001"  # Web Console
```

**Purpose:**
- Stores actual Iceberg table data files (Parquet format)
- Stores Iceberg metadata files
- S3-compatible object storage

**Bucket Structure:**
```
s3://warehouse/
├── namespace1/
│   ├── table1/
│   │   ├── metadata/
│   │   │   ├── v1.metadata.json
│   │   │   ├── v2.metadata.json
│   │   │   └── snap-*.avro
│   │   └── data/
│   │       ├── part-00000.parquet
│   │       └── part-00001.parquet
│   └── table2/
└── namespace2/
```

#### 3. **ETL Service** (Uses PyIceberg)

```python
# In src/etl/ - Python code using PyIceberg library
from pyiceberg.catalog import load_catalog

# Connect to Iceberg REST Catalog
catalog = load_catalog(
    "default",
    **{
        "uri": "http://iceberg-rest:8181",
        "s3.endpoint": "http://minio:9000",
        "s3.access-key-id": "minioadmin",
        "s3.secret-access-key": "minioadmin",
    }
)

# Create/write to Iceberg tables
table = catalog.create_table(
    "social.users",
    schema=schema,
    location="s3://warehouse/social/users"
)
```

**Why no Spark?**
- PyIceberg is a pure Python library
- No JVM overhead
- Perfect for POC and moderate data volumes
- Can add Spark later if needed for large-scale processing

#### 4. **DuckDB Service** (Queries Iceberg)

```python
# In src/duckdb_service/ - DuckDB can query Iceberg tables
import duckdb

conn = duckdb.connect()

# Install and load Iceberg extension
conn.execute("INSTALL iceberg")
conn.execute("LOAD iceberg")

# Query Iceberg tables directly
result = conn.execute("""
    SELECT * FROM iceberg_scan(
        's3://warehouse/social/users',
        allow_moved_paths=true
    )
""").fetchall()
```

---

## Data Flow

### 1. **Write Path (ETL)**

```
PostgreSQL → ETL Service → PyIceberg → MinIO
                ↓
         Iceberg REST Catalog
         (registers metadata)
```

**Steps:**
1. ETL extracts data from PostgreSQL
2. PyIceberg writes data as Parquet files to MinIO
3. Iceberg REST Catalog tracks metadata (schema, partitions, snapshots)
4. Each write creates a new snapshot (time travel capability)

### 2. **Read Path (Queries)**

```
User Query → AI Agent → DuckDB → Iceberg Tables (MinIO)
                                      ↓
                              Iceberg REST Catalog
                              (reads metadata)
```

**Steps:**
1. User sends natural language query to AI Agent
2. AI Agent converts to SQL
3. DuckDB queries Iceberg tables via S3 (MinIO)
4. Iceberg REST Catalog provides table metadata
5. DuckDB reads only necessary Parquet files (predicate pushdown)

---

## Why This Architecture?

### ✅ **Advantages:**

1. **No Spark Complexity**
   - PyIceberg is simpler for POC
   - Easier to debug and maintain
   - Faster development cycle

2. **True Lakehouse**
   - ACID transactions via Iceberg
   - Schema evolution support
   - Time travel capabilities
   - Efficient metadata management

3. **Scalable**
   - Can add Spark later if needed
   - MinIO can be replaced with AWS S3
   - Iceberg REST can be replaced with AWS Glue

4. **Cost-Effective**
   - All open-source components
   - Runs on single machine for POC
   - No cloud costs during development

### 📊 **Comparison:**

| Component | Traditional Data Lake | Our Lakehouse |
|-----------|----------------------|---------------|
| Format | Raw files (CSV, JSON) | Iceberg (Parquet) |
| ACID | ❌ No | ✅ Yes |
| Schema Evolution | ❌ Manual | ✅ Automatic |
| Time Travel | ❌ No | ✅ Yes |
| Query Performance | 🐌 Slow | ⚡ Fast |
| Metadata | 🤷 File listing | 📊 Structured |

---

## File Organization

```
docker/
├── postgres/          # OLTP source
│   └── init.sql
├── duckdb/           # Query engine
│   └── Dockerfile
├── ai-agent/         # Application layer
│   └── Dockerfile
└── etl/              # Data pipeline
    └── Dockerfile

# Iceberg components:
# - iceberg-rest: Uses official image (no folder needed)
# - minio: Uses official image (no folder needed)
# - PyIceberg: Python library in ETL service
```

---

## Configuration Files

### docker-compose.yml
- Defines all services including Iceberg REST
- Sets up networking between services
- Configures environment variables

### .env.example
- Iceberg REST URI
- S3/MinIO credentials
- Warehouse location

---

## Next Steps

1. **Implement ETL with PyIceberg**
   - Create Iceberg tables
   - Write data from PostgreSQL
   - Handle schema evolution

2. **Implement DuckDB queries**
   - Query Iceberg tables
   - Leverage Iceberg metadata
   - Optimize query performance

3. **Test Iceberg features**
   - Time travel queries
   - Schema evolution
   - Partition pruning
   - Snapshot management

---

## Resources

- [Apache Iceberg Docs](https://iceberg.apache.org/)
- [PyIceberg Docs](https://py.iceberg.apache.org/)
- [Tabular REST Catalog](https://github.com/tabular-io/iceberg-rest-image)
- [DuckDB Iceberg Extension](https://duckdb.org/docs/extensions/iceberg)
