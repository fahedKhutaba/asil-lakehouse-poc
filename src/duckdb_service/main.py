"""
DuckDB Service - HTTP API for querying Iceberg tables with DuckDB
"""
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import duckdb
import os
from typing import List, Dict, Any

app = FastAPI(title="DuckDB Lakehouse Service")

# Environment variables
S3_ENDPOINT = os.getenv("S3_ENDPOINT", "http://minio:9000")
AWS_ACCESS_KEY_ID = os.getenv("AWS_ACCESS_KEY_ID", "minioadmin")
AWS_SECRET_ACCESS_KEY = os.getenv("AWS_SECRET_ACCESS_KEY", "minioadmin")
ICEBERG_REST_URI = os.getenv("ICEBERG_REST_URI", "http://iceberg-rest:8181")


class QueryRequest(BaseModel):
    """Request model for SQL queries"""
    sql: str


class QueryResponse(BaseModel):
    """Response model for query results"""
    columns: List[str]
    data: List[List[Any]]
    row_count: int


@app.on_event("startup")
async def startup_event():
    """Initialize DuckDB connection and install extensions"""
    global conn
    conn = duckdb.connect(":memory:")
    
    # Install and load httpfs extension (required for S3)
    try:
        conn.execute("INSTALL httpfs")
        conn.execute("LOAD httpfs")
        print("✅ DuckDB httpfs extension loaded successfully")
    except Exception as e:
        print(f"⚠️  Warning: Could not load httpfs extension: {e}")
        print("   Continuing without S3 support...")
    
    # Try to install and load Iceberg extension (optional for now)
    try:
        conn.execute("INSTALL iceberg")
        conn.execute("LOAD iceberg")
        print("✅ DuckDB Iceberg extension loaded successfully")
    except Exception as e:
        print(f"⚠️  Warning: Could not load Iceberg extension: {e}")
        print("   Iceberg queries will not be available")
    
    # Configure S3 settings for MinIO (only if httpfs loaded)
    try:
        conn.execute(f"""
            SET s3_endpoint='{S3_ENDPOINT}';
            SET s3_access_key_id='{AWS_ACCESS_KEY_ID}';
            SET s3_secret_access_key='{AWS_SECRET_ACCESS_KEY}';
            SET s3_use_ssl=false;
            SET s3_url_style='path';
        """)
        print("✅ DuckDB S3 configuration set")
    except Exception as e:
        print(f"⚠️  Warning: Could not configure S3: {e}")


@app.get("/")
async def root():
    """Health check endpoint"""
    return {
        "service": "DuckDB Lakehouse Service",
        "status": "running",
        "s3_endpoint": S3_ENDPOINT,
        "iceberg_rest_uri": ICEBERG_REST_URI
    }


@app.get("/health")
async def health():
    """Detailed health check"""
    try:
        # Test DuckDB connection
        result = conn.execute("SELECT 1 as test").fetchone()
        return {
            "status": "healthy",
            "duckdb": "connected",
            "test_query": result[0] == 1
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Health check failed: {str(e)}")


@app.post("/query", response_model=QueryResponse)
async def execute_query(request: QueryRequest):
    """
    Execute a SQL query on Iceberg tables
    
    Example:
    ```
    POST /query
    {
        "sql": "SELECT * FROM iceberg_scan('s3://warehouse/social/users') LIMIT 10"
    }
    ```
    """
    try:
        result = conn.execute(request.sql)
        rows = result.fetchall()
        columns = [desc[0] for desc in result.description]
        
        return QueryResponse(
            columns=columns,
            data=rows,
            row_count=len(rows)
        )
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Query execution failed: {str(e)}")


@app.get("/tables")
async def list_tables():
    """
    List available tables (placeholder - will be implemented with Iceberg catalog integration)
    """
    return {
        "message": "Table listing will be implemented with Iceberg catalog integration",
        "warehouse": "s3://warehouse/"
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8082)
