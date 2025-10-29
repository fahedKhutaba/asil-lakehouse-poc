FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install DuckDB and related packages
RUN pip install --no-cache-dir \
    duckdb==0.9.2 \
    pyarrow==14.0.1 \
    pandas==2.1.4 \
    fastapi==0.104.1 \
    uvicorn[standard]==0.24.0 \
    python-dotenv==1.0.0 \
    boto3==1.34.0 \
    s3fs==2023.12.0

# Create data directory
RUN mkdir -p /app/data /app/duckdb

# Copy DuckDB service code (will be created later)
COPY src/duckdb_service /app/duckdb_service

# Expose port for HTTP API
EXPOSE 8082

# Run DuckDB HTTP service
CMD ["uvicorn", "duckdb_service.main:app", "--host", "0.0.0.0", "--port", "8082"]
