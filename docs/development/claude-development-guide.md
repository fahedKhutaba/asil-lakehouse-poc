# Claude Development Guide for Lakehouse POC

This guide provides ready-to-use prompts and workflows for developing the Lakehouse POC using Claude in VS Code.

---

## Table of Contents
1. [Setup Phase](#setup-phase)
2. [Development Workflows](#development-workflows)
3. [Best Practices](#best-practices)
4. [Prompt Templates](#prompt-templates)
5. [Troubleshooting](#troubleshooting)

---

## Setup Phase

### Task 0: GitHub Repository Setup

**Prompt 1: .gitignore Configuration**
```
Create a comprehensive .gitignore file for the Lakehouse POC project that includes:
- Python artifacts (*.pyc, __pycache__, .pytest_cache, etc.)
- Virtual environments (venv/, env/, .venv/)
- IDE files (VS Code, PyCharm)
- Environment files (.env, .env.local)
- Docker volumes and data
- OS files (.DS_Store, Thumbs.db)
- Build artifacts
- Logs and temporary files

Organize by category with clear comments.
```

**Prompt 2: Repository README Template**
```
Create an initial README.md for the GitHub repository 'asil-lakehouse-poc' that includes:
- Project title and description
- Architecture overview (brief)
- Prerequisites
- Quick start instructions
- Project structure
- Documentation links
- License

This will be replaced later with the full README, but we need a good first impression.
```

**Prompt 3: Contributing Guidelines**
```
Create a CONTRIBUTING.md file that defines:
- Branch naming conventions (feature/, bugfix/, hotfix/)
- Commit message format (conventional commits)
- Pull request process
- Code review guidelines
- Testing requirements

Follow standard open-source practices but keep it simple for a POC.
```

**Prompt 4: GitHub Actions Workflow (Optional)**
```
Create a basic GitHub Actions workflow (.github/workflows/ci.yml) that:
- Runs on push to main and pull requests
- Sets up Python 3.11
- Installs dependencies
- Runs linting (flake8)
- Runs tests (pytest)
- Reports coverage

This is optional for Phase 1 but good to have early.
```

---

### Initial Project Setup

**Prompt 1: Docker Compose Setup**
```
I'm building a Lakehouse POC as defined in lakehouse-poc-prd.md. 
Please create a docker-compose.yml file that includes:
- PostgreSQL 15 with persistent volume
- MinIO with web console
- Custom DuckDB container
- Python-based AI Agent service
- Python-based ETL service

Refer to section 6.3 of the PRD for service details.
```

**Prompt 2: Project Structure**
```
Create the complete project directory structure as defined in section 8.2 
of the PRD. Include all folders and empty __init__.py files where needed.
```

**Prompt 3: Environment Configuration**
```
Generate a complete .env.example file based on section 8.4 of the PRD, 
with additional comments explaining each variable.
```

---

## Development Workflows

### Phase 1: Database & Schema (Milestone 1)

**Workflow:**
```
Step 1: "Create the PostgreSQL schema as defined in section 2.1 of the PRD, 
        including all indexes and foreign key constraints."

Step 2: "Write a Python script (seed_data.py) that generates synthetic 
        social network data matching the requirements in section 4.2:
        - 10K users
        - 1M posts
        - 5M comments
        - 10M likes
        Use the Faker library and ensure data spans 2 years."

Step 3: "Create a Docker init script for PostgreSQL that:
        1. Creates the database schema
        2. Sets up initial indexes
        3. Configures connection pooling"

Step 4: "Write a health check script that verifies:
        - PostgreSQL is running
        - Schema is created
        - Sample data exists
        - Connections work"
```

### Phase 2: MinIO & Iceberg Setup (Milestone 1)

**Workflow:**
```
Step 1: "Create a MinIO initialization script that:
        - Creates the 'lakehouse' bucket
        - Sets up appropriate access policies
        - Configures bucket versioning"

Step 2: "Write Python code to configure Apache Iceberg catalog with:
        - REST catalog pointing to MinIO
        - Proper S3 credentials
        - Table namespace: lakehouse.socialnet"

Step 3: "Create a DuckDB Dockerfile that:
        - Installs DuckDB CLI
        - Adds Iceberg extension
        - Configures S3 access to MinIO
        - Includes test queries"
```

### Phase 3: ETL Pipeline (Milestone 2)

**Prompt Templates:**

**ETL Extraction:**
```
Implement the ETL extraction module (src/etl/extract.py) that:
1. Connects to PostgreSQL
2. Identifies records older than 30 days using watermark approach (FR-ETL-003)
3. Extracts data in batches of 10K rows (configurable)
4. Returns a pandas DataFrame
5. Logs extraction metrics

Follow requirements FR-ETL-001 through FR-ETL-004 from the PRD.
```

**ETL Transformation:**
```
Implement the ETL transformation module (src/etl/transform.py) that:
1. Takes pandas DataFrame from extraction
2. Adds metadata columns:
   - _migrated_at (current timestamp)
   - _source_db ('oltp')
   - _batch_id (UUID)
3. Validates data quality (no nulls in required fields)
4. Converts data types for Parquet compatibility
5. Partitions data by year/month based on created_at

Reference section 2.2 of the PRD for Lakehouse requirements.
```

**ETL Load:**
```
Implement the ETL load module (src/etl/load.py) that:
1. Converts DataFrame to Parquet with Snappy compression
2. Uploads to MinIO bucket: lakehouse/iceberg/tables/{table_name}/
3. Registers table with Iceberg catalog
4. Updates watermark in metadata table
5. Implements rollback on failure

Follow FR-ETL-005 through FR-ETL-009 from the PRD.
```

**ETL Orchestration:**
```
Create the main ETL pipeline (src/etl/main.py) that:
1. Orchestrates extract → transform → load
2. Implements scheduling using APScheduler
3. Provides manual trigger endpoint
4. Logs all operations
5. Exposes metrics via /metrics endpoint
6. Handles errors gracefully with rollback

Include dry-run mode for testing.
```

### Phase 4: AI Agent (Milestone 3)

**Query Parser:**
```
Implement the query parser (src/ai_agent/query_parser.py) that:
1. Accepts natural language query string
2. Identifies query intent (aggregation, filter, ranking, etc.)
3. Extracts temporal keywords (today, last week, historical, etc.)
4. Identifies mentioned tables and columns
5. Returns structured query metadata

This feeds into the SQL generator. Use NLP techniques or simple regex 
patterns for the POC.
```

**SQL Generator with AI:**
```
Implement the SQL generator (src/ai_agent/sql_generator.py) using OpenAI:
1. Load schema context from database
2. Construct prompt with:
   - Database schema
   - Table relationships
   - Data freshness rules (section 2.3, FR-AI-003)
   - Natural language query
   - Example queries (section 5.1)
3. Call OpenAI API with temperature=0 for consistency
4. Parse and validate generated SQL
5. Handle errors and retry if needed

Follow FR-AI-002 and FR-AI-003 requirements.
```

**Query Router:**
```
Implement the query router (src/ai_agent/router.py) that:
1. Analyzes the generated SQL and query metadata
2. Applies routing rules from FR-AI-004:
   - Route to OLTP if temporal window ≤ 30 days
   - Route to Lakehouse for historical queries
   - Route to Lakehouse for large aggregations
3. Executes query against correct data layer
4. Returns results with execution metadata
5. Logs routing decisions

Include reasoning explanation in the response.
```

**API Layer:**
```
Implement FastAPI service (src/ai_agent/main.py) with endpoints:
- POST /api/v1/query (with rate limiting)
- GET /api/v1/health
- GET /api/v1/schema
- GET /api/v1/metrics

Follow API specification in section 2.5 of the PRD.
Include request validation, error handling, and CORS configuration.
```

### Phase 5: Testing (Milestone 4)

**Unit Tests:**
```
Generate pytest test cases for the AI Agent covering:
1. All 8 Tier 1 queries from section 5.1
2. Query parsing edge cases
3. SQL validation
4. Routing logic correctness
5. Error handling

Include test fixtures for mock database connections.
Target 80% code coverage.
```

**Integration Tests:**
```
Create integration tests that:
1. Spin up test database with sample data
2. Test full query flow: NL → SQL → Results
3. Verify ETL pipeline end-to-end
4. Test data integrity after migration
5. Verify Lakehouse queries return correct results

Use pytest-docker for container management.
```

**Performance Tests:**
```
Create performance test script that:
1. Measures query response times for OLTP (<2s target)
2. Measures query response times for Lakehouse (<5s target)
3. Tests concurrent query handling (10 users)
4. Measures ETL throughput (100K rows/min target)
5. Generates performance report

Use pytest-benchmark or locust for load testing.
```

---

## Best Practices with Claude

### 1. Reference the PRD
Always mention the PRD in your prompts:
```
"Following section X.Y of lakehouse-poc-prd.md, implement..."
```

### 2. Iterative Development
Break large tasks into smaller steps:
```
❌ "Build the entire ETL pipeline"
✅ "Implement the extraction module, then I'll ask for transformation"
```

### 3. Include Requirements
Reference specific requirement IDs:
```
"Implement FR-ETL-001 (scheduled execution) using APScheduler with 
configurable cron expressions"
```

### 4. Request Explanations
Ask Claude to explain decisions:
```
"Explain why you chose this approach for query routing and what 
alternatives you considered"
```

### 5. Validate Against PRD
Have Claude verify compliance:
```
"Review this code against requirements FR-AI-004 through FR-AI-008 
and identify any gaps"
```

---

## Prompt Templates

### Code Generation Template
```
Context: [Describe what you're building]
Requirements: [List specific PRD requirements]
Constraints: [Any technical constraints]
Input: [Expected inputs]
Output: [Expected outputs]

Please implement [component name] that [functionality description].

Include:
- Type hints
- Docstrings
- Error handling
- Logging
- Unit test suggestions
```

### Code Review Template
```
Please review this code for:
1. Compliance with PRD requirements [list requirement IDs]
2. Python best practices (PEP 8)
3. Error handling completeness
4. Performance considerations
5. Security issues
6. Missing edge cases

Suggest specific improvements with code examples.
```

### Debugging Template
```
I'm encountering [error/issue] in [component].

Expected behavior: [describe]
Actual behavior: [describe]
Relevant code: [paste code]
Error message: [paste error]
PRD requirement: [reference if applicable]

Please help me:
1. Identify the root cause
2. Suggest a fix
3. Explain why it happened
4. Recommend prevention strategies
```

### Documentation Template
```
Generate documentation for [component/module] that includes:
1. Overview and purpose
2. Architecture diagram (Mermaid)
3. API/function reference
4. Usage examples
5. Configuration options
6. Common issues and solutions

Format as Markdown following the style in docs/ folder.
```

---

## Common Development Sequences

### Sequence 1: New Feature Implementation
```
1. "Review PRD section [X] and summarize the requirements"
2. "Propose an implementation approach with pros/cons"
3. "Create the module skeleton with type hints and docstrings"
4. "Implement the core logic"
5. "Add error handling and logging"
6. "Generate unit tests"
7. "Review the code for PRD compliance"
8. "Update documentation"
```

### Sequence 2: Bug Fix
```
1. "Help me understand this error: [paste error]"
2. "Review the relevant code: [paste code]"
3. "Suggest potential fixes"
4. "Implement the fix"
5. "Add test case to prevent regression"
```

### Sequence 3: Refactoring
```
1. "Analyze this code for improvement opportunities: [paste code]"
2. "Suggest refactoring approaches that maintain PRD compliance"
3. "Implement the refactoring"
4. "Verify tests still pass"
5. "Update documentation if needed"
```

---

## Troubleshooting with Claude

### Docker Issues
```
"My Docker container [container name] is failing to start. Here's the error:
[paste error]

Here's my Dockerfile:
[paste Dockerfile]

And docker-compose.yml:
[paste relevant section]

Please help me diagnose and fix the issue."
```

### Database Connection Issues
```
"I can't connect to PostgreSQL from my Python service. 

Error: [paste error]
Connection string: [paste sanitized connection string]
Docker network setup: [paste docker-compose network config]

The services are defined in docker-compose.yml as shown in the PRD.
Help me troubleshoot the connection."
```

### Query Routing Problems
```
"The query router is sending this query to the wrong layer:
Query: '[natural language query]'
Expected layer: [OLTP/Lakehouse]
Actual layer: [OLTP/Lakehouse]

Here's my routing logic:
[paste code]

This should follow FR-AI-004 from the PRD. What's wrong?"
```

### ETL Performance Issues
```
"My ETL pipeline is processing only [X] rows/minute, but the requirement 
(NFR-PERF-004) is 100K rows/minute.

Current implementation:
[paste relevant code]

Please suggest optimizations while maintaining data integrity (FR-ETL-002)."
```

---

## Example Development Session

Here's a complete example of developing the SQL generator:

```
Developer: "I need to implement the SQL generator for the AI Agent. 
This is part of Milestone 3. Let's start by reviewing the requirements."

Claude: [Reviews FR-AI-002, FR-AI-003, and related sections]

Developer: "Create the basic structure for sql_generator.py with schema 
context loading."

Claude: [Generates code with schema loading]

Developer: "Now implement the OpenAI integration following the prompt 
structure in FR-AI-003."

Claude: [Implements OpenAI API call with proper prompt engineering]

Developer: "Add SQL validation to ensure generated queries are safe 
and match our schema."

Claude: [Adds validation logic using sqlparse or similar]

Developer: "Generate pytest test cases for the 8 Tier 1 queries from 
section 5.1."

Claude: [Creates comprehensive test suite]

Developer: "Review the complete implementation against requirements 
FR-AI-002 through FR-AI-007 and identify any gaps."

Claude: [Performs requirement compliance review]

Developer: "Great! Now help me document this module in docs/API.md."

Claude: [Generates documentation following project standards]
```

---

## Tips for Efficient Claude Usage

### Do's ✅
- Reference specific PRD sections and requirement IDs
- Break complex tasks into smaller steps
- Provide context (what you're building, why, constraints)
- Ask for explanations of design decisions
- Request multiple approaches when uncertain
- Have Claude validate against requirements
- Use Claude for code review before committing

### Don'ts ❌
- Don't paste entire large files (use relevant excerpts)
- Don't ask vague questions ("make it better")
- Don't skip requirement references
- Don't implement without understanding
- Don't ignore Claude's warnings or suggestions
- Don't forget to validate generated code

---

## Milestone Checklists

### Milestone 1 Checklist (with Claude)

**GitHub & Repository Setup:**
- [ ] "Create a comprehensive .gitignore for Python, Docker, and VS Code"
- [ ] "Generate CONTRIBUTING.md with branch naming and commit conventions"
- [ ] "Create GitHub issue templates for bug reports and feature requests"
- [ ] "Write initial repository README with project overview"

**Docker & Infrastructure:**
- [ ] "Generate Docker Compose for all services"
- [ ] "Create PostgreSQL schema with indexes"
- [ ] "Write data seeding script with 1M rows"
- [ ] "Implement MinIO bucket setup"
- [ ] "Configure Iceberg catalog"
- [ ] "Create health check endpoints"

**Documentation:**
- [ ] "Generate setup documentation"
- [ ] "Create architecture diagram in Mermaid format"
- [ ] "Review all code against Milestone 1 requirements"

### Milestone 2 Checklist (with Claude)
- [ ] "Implement ETL extraction module"
- [ ] "Implement ETL transformation with Parquet"
- [ ] "Implement ETL load to MinIO/Iceberg"
- [ ] "Create ETL orchestration and scheduling"
- [ ] "Add transaction logging"
- [ ] "Implement rollback mechanism"
- [ ] "Create monitoring dashboard config"
- [ ] "Generate ETL documentation"
- [ ] "Write integration tests for ETL"

### Milestone 3 Checklist (with Claude)
- [ ] "Implement NL query parser"
- [ ] "Build SQL generator with OpenAI"
- [ ] "Create query router with logic"
- [ ] "Implement FastAPI endpoints"
- [ ] "Add rate limiting and validation"
- [ ] "Test all Tier 1 queries"
- [ ] "Add error handling"
- [ ] "Generate API documentation"
- [ ] "Create Postman collection"

### Milestone 4 Checklist (with Claude)
- [ ] "Generate unit tests (80% coverage)"
- [ ] "Create integration test suite"
- [ ] "Implement performance tests"
- [ ] "Run security review"
- [ ] "Generate complete documentation"
- [ ] "Create demo script"
- [ ] "Write deployment guide"
- [ ] "Prepare presentation"

---

## Quick Reference Commands

### Ask Claude to Review PRD
```
"Review lakehouse-poc-prd.md section [X] and summarize the key 
requirements I need to implement for [component]"
```

### Generate Boilerplate
```
"Generate the boilerplate code structure for [module] following 
Python best practices and including type hints, docstrings, and 
logging setup"
```

### Code Review
```
"Review this code for compliance with requirements [FR-XXX-YYY], 
code quality, and potential issues:
[paste code]"
```

### Generate Tests
```
"Generate pytest tests for this function covering normal cases, 
edge cases, and error conditions:
[paste function]"
```

### Fix Bug
```
"This code is producing error [error]. Expected behavior is [X] 
but actual is [Y]. Help me debug:
[paste code]"
```

### Update Documentation
```
"Update the documentation in docs/[FILE].md to reflect these 
changes:
[describe changes]"
```

---

## Resources

- **PRD:** `/lakehouse-poc-prd.md`
- **API Docs:** `/docs/API.md`
- **Architecture:** `/docs/ARCHITECTURE.md`
- **Claude Tips:** https://docs.claude.com

---

**Remember:** Claude is your pair programming partner. Be specific, 
reference the PRD, iterate in steps, and always validate the output!

