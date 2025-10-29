# Observability Stack Documentation

## Overview

The ASIL Lakehouse POC includes a comprehensive observability stack for monitoring, tracing, and logging.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                  VISUALIZATION LAYER                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │            Grafana (Port 3000)                       │   │
│  │  • Metrics Dashboards                                │   │
│  │  • Trace Visualization                               │   │
│  │  • Log Exploration                                   │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            ↑ ↑ ↑
         ┌──────────────────┘ │ └────────────────┐
         │                    │                   │
┌────────▼────────┐  ┌───────▼────────┐  ┌──────▼──────┐
│   Prometheus    │  │     Jaeger     │  │    Loki     │
│   (Metrics)     │  │    (Traces)    │  │   (Logs)    │
│   Port 9090     │  │   Port 16686   │  │  Port 3100  │
└────────▲────────┘  └───────▲────────┘  └──────▲──────┘
         │                    │                   │
         │           ┌────────▼──────────┐        │
         │           │  OpenTelemetry    │        │
         └───────────┤     Collector     ├────────┘
                     │  Ports 4317/4318  │
                     └────────▲──────────┘
                              │
         ┌────────────────────┼────────────────────┐
         │                    │                    │
┌────────▼────────┐  ┌───────▼────────┐  ┌───────▼────────┐
│   AI Agent      │  │  ETL Pipeline  │  │ DuckDB Service │
│ (instrumented)  │  │ (instrumented) │  │ (instrumented) │
└─────────────────┘  └────────────────┘  └────────────────┘
         │                    │                    │
         └────────────────────┼────────────────────┘
                              │
         ┌────────────────────┼────────────────────┐
         │                    │                    │
┌────────▼────────┐  ┌───────▼────────┐  ┌───────▼────────┐
│   PostgreSQL    │  │     MinIO      │  │ Iceberg REST   │
│   + Exporter    │  │  (Prometheus)  │  │                │
└─────────────────┘  └────────────────┘  └────────────────┘
```

## Components

### 1. Prometheus (Metrics Collection)
- **Port:** 9090
- **Purpose:** Time-series metrics storage and querying
- **Scrapes:**
  - PostgreSQL metrics (via postgres-exporter)
  - MinIO metrics (native endpoint)
  - DuckDB service metrics
  - AI Agent metrics
  - ETL pipeline metrics
  - OTEL Collector metrics

### 2. Grafana (Visualization)
- **Port:** 3000
- **Default Credentials:** admin/admin
- **Datasources:**
  - Prometheus (metrics)
  - Jaeger (traces)
  - Loki (logs)
- **Purpose:** Unified dashboard for all observability data

### 3. OpenTelemetry Collector
- **Ports:**
  - 4317: OTLP gRPC
  - 4318: OTLP HTTP
  - 8888: Prometheus metrics (collector itself)
  - 8889: Prometheus exporter
  - 13133: Health check
  - 55679: zPages (debugging)
- **Purpose:** Central telemetry data collection and processing

### 4. Jaeger (Distributed Tracing)
- **Port:** 16686 (UI)
- **Purpose:** Trace requests across services
- **Features:**
  - End-to-end request tracing
  - Service dependency visualization
  - Performance bottleneck identification

### 5. Loki (Log Aggregation)
- **Port:** 3100
- **Purpose:** Centralized log storage and querying
- **Features:**
  - Label-based log indexing
  - Integration with Grafana
  - Efficient log storage

### 6. PostgreSQL Exporter
- **Port:** 9187
- **Purpose:** Export PostgreSQL metrics to Prometheus
- **Metrics:**
  - Connection pool stats
  - Query performance
  - Database size
  - Table statistics

## Access Points

| Service | URL | Credentials |
|---------|-----|-------------|
| **Grafana** | http://localhost:3000 | admin / admin |
| **Prometheus** | http://localhost:9090 | No auth |
| **Jaeger UI** | http://localhost:16686 | No auth |
| **OTEL Collector Health** | http://localhost:13133 | No auth |
| **OTEL Collector zPages** | http://localhost:55679/debug/servicez | No auth |

## Key Metrics to Monitor

### Query Performance
```promql
# OLTP query latency (p95)
histogram_quantile(0.95, rate(oltp_query_duration_seconds_bucket[5m]))

# Lakehouse query latency (p95)
histogram_quantile(0.95, rate(lakehouse_query_duration_seconds_bucket[5m]))
```

### ETL Throughput
```promql
# Records processed per second
rate(etl_records_processed_total[5m])

# ETL batch duration
rate(etl_batch_duration_seconds_sum[5m]) / rate(etl_batch_duration_seconds_count[5m])
```

### AI Agent Performance
```promql
# AI routing accuracy
(ai_query_routing_correct_total / ai_query_routing_total) * 100

# LLM token usage
rate(openai_tokens_total[5m])

# LLM cost
rate(openai_cost_dollars_total[1h])
```

### Resource Utilization
```promql
# PostgreSQL connections
pg_stat_database_numbackends

# MinIO throughput
rate(minio_s3_requests_total[5m])

# DuckDB query rate
rate(duckdb_queries_total[5m])
```

## Instrumentation Guide

### Python Services (FastAPI)

```python
from opentelemetry import trace, metrics
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.exporter.otlp.proto.grpc.metric_exporter import OTLPMetricExporter
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.resources import Resource

# Configure resource
resource = Resource.create({
    "service.name": "ai-agent",
    "service.namespace": "lakehouse-poc",
    "deployment.environment": "development"
})

# Setup tracing
trace.set_tracer_provider(TracerProvider(resource=resource))
tracer = trace.get_tracer(__name__)
trace.get_tracer_provider().add_span_processor(
    BatchSpanProcessor(OTLPSpanExporter(endpoint="http://otel-collector:4317"))
)

# Setup metrics
metrics.set_meter_provider(MeterProvider(resource=resource))
meter = metrics.get_meter(__name__)

# Create custom metrics
query_counter = meter.create_counter(
    "queries_total",
    description="Total number of queries processed"
)

query_duration = meter.create_histogram(
    "query_duration_seconds",
    description="Query execution duration"
)

# Use in code
with tracer.start_as_current_span("process_query"):
    start_time = time.time()
    result = process_query(query)
    duration = time.time() - start_time
    
    query_counter.add(1, {"query_type": "oltp"})
    query_duration.record(duration, {"query_type": "oltp"})
```

## Troubleshooting

### Service Not Starting

```bash
# Check logs
docker-compose logs <service-name>

# Common issues:
# 1. Port conflicts
lsof -i :<port>

# 2. Configuration errors
docker-compose config

# 3. Volume permissions
docker-compose down -v
docker-compose up -d
```

### No Metrics Appearing

```bash
# Check Prometheus targets
open http://localhost:9090/targets

# Check OTEL Collector health
curl http://localhost:13133

# Verify service is exposing metrics
curl http://localhost:
