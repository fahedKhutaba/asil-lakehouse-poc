# Lakehouse POC - Quick Start Guide

**AI-Powered Data Platform with OLTP & Lakehouse Integration**

---

## 🚀 Quick Start (30 Minutes to Running System)

### Prerequisites
- Docker Desktop (20.10+) with 16GB RAM allocated
- VS Code with Claude extension
- Git
- Python 3.11+ (for local development)
- OpenAI API key (or alternative LLM)

### Installation

```bash
# 1. Create GitHub repository (ASIL - AI Solution)
# Go to GitHub and create a new repository:
# - Name: asil-lakehouse-poc
# - Description: AI-powered Lakehouse POC integrating OLTP and analytical layers
# - Visibility: Private (or Public based on your needs)
# - Initialize with: README, .gitignore (Python), LICENSE (MIT or your choice)

# 2. Clone the repository
git clone https://github.com/YOUR_USERNAME/asil-lakehouse-poc.git
cd asil-lakehouse-poc

# 3. Set up branch protection (optional but recommended)
# In GitHub: Settings → Branches → Add rule
# - Branch name pattern: main
# - Require pull request reviews before merging
# - Require status checks to pass

# 4. Create project structure (use Claude!)
# In VS Code with Claude: "Create the project structure from lakehouse-poc-prd.md section 8.2"

# 5. Copy the PRD and guides to the repository
# Place the three documents:
# - lakehouse-poc-prd.md (root directory)
# - docs/claude-development-guide.md
# - README.md (replace the default one)

# 6. Commit the initial structure
git add .
git commit -m "docs: initial project structure and PRD"
git push origin main

# 7. Set up environment
cp .env.example .env
# Edit .env with your OpenAI API key and other settings

# 8. Start services
docker-compose up -d

# 9. Verify everything is running
docker-compose ps

# 10. Check service health
curl http://localhost:8000/health  # AI Agent
curl http://localhost:9000         # MinIO Console
```

---

## 📋 Your First Hour Tasks

### Task 0: Create GitHub Repository (10 min)
**Manual Steps:**

1. **Create Repository on GitHub:**
   - Navigate to https://github.com/new
   - Repository name: `asil-lakehouse-poc`
   - Description: "AI-powered Lakehouse POC - OLTP & Analytical Data Platform"
   - Visibility: Choose based on your needs (Private recommended for POC)
   - ✅ Initialize with README
   - ✅ Add .gitignore: Python
   - ✅ Choose a license: MIT (or your preference)

2. **Configure Repository Settings:**
   - Go to Settings → General
   - ✅ Enable Issues
   - ✅ Enable Discussions (optional)
   - ✅ Allow merge commits
   
3. **Set Up Branch Protection (Recommended):**
   - Settings → Branches → Add rule
   - Branch name pattern: `main`
   - ✅ Require a pull request before merging
   - ✅ Require approvals: 1
   - ✅ Dismiss stale pull request approvals

4. **Clone and Initial Setup:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/asil-lakehouse-poc.git
   cd asil-lakehouse-poc
   
   # Create docs directory
   mkdir -p docs
   
   # Copy the three documents you received:
   # - lakehouse-poc-prd.md (root)
   # - docs/claude-development-guide.md
   # - Replace README.md with the new one
   
   # Initial commit
   git add .
   git commit -m "docs: add project PRD and development guides"
   git push origin main
   ```

**Expected Output:**
- GitHub repository: `https://github.com/YOUR_USERNAME/asil-lakehouse-poc`
- Three core documents committed
- Branch protection configured

---

### Task 1: Set Up Docker Environment (15 min)
**Use Claude:**
```
"Based on lakehouse-poc-prd.md section 6.3, create a docker-compose.yml 
file with PostgreSQL, MinIO, and placeholder services for ai-agent and etl."
```

**Expected Output:**
- `docker-compose.yml`
- `.env.example`
- `docker/` directory with Dockerfiles

**Verify:**
```bash
docker-compose up postgres minio -d
docker-compose ps  # Should show postgres and minio running
```

### Task 2: Create Database Schema (15 min)
**Use Claude:**
```
"Generate the PostgreSQL initialization script (docker/postgres/init.sql) 
with the schema from PRD section 2.1, including all indexes."
```

**Expected Output:**
- `docker/postgres/init.sql`
- `docker/postgres/Dockerfile`

**Verify:**
```bash
docker-compose restart postgres
docker exec -it lakehouse-poc-postgres-1 psql -U lakeuser -d socialnet -c "\dt"
# Should show: users, posts, comments, likes
```

### Task 3: Generate Sample Data (20 min)
**Use Claude:**
```
"Create a Python script (scripts/seed_data.py) that generates synthetic 
social network data following PRD section 4.2 requirements: 10K users, 
1M posts, 5M comments, 10M likes."
```

**Expected Output:**
- `scripts/seed_data.py`
- `requirements.txt` (with Faker, psycopg2)

**Run:**
```bash
pip install -r requirements.txt
python scripts/seed_data.py
```

**Verify:**
```bash
docker exec -it lakehouse-poc-postgres-1 psql -U lakeuser -d socialnet -c "SELECT COUNT(*) FROM posts;"
# Should show ~1,000,000
```

### Task 4: Configure MinIO (10 min)
**Use Claude:**
```
"Create a MinIO initialization script that creates the 'lakehouse' bucket 
and sets up access policies."
```

**Access MinIO Console:**
- URL: http://localhost:9000
- Username: minioadmin
- Password: minioadmin

**Create Bucket:**
- Name: `lakehouse`
- Versioning: Enabled

---

## 📚 Key Documents

| Document | Purpose | When to Use |
|----------|---------|-------------|
| **lakehouse-poc-prd.md** | Complete requirements specification | Before implementing any feature |
| **claude-development-guide.md** | Claude prompt templates and workflows | During development with Claude |
| **github-workflow-guide.md** | Git commands and GitHub best practices | Setting up repository and daily commits |
| **README.md** (this file) | Quick reference and setup | Getting started |

---

## 🏗️ Development Workflow

### Daily Development Pattern

1. **Morning Standup (Self)**
   - Review PRD milestone for the week
   - Identify today's tasks from the milestone
   - Check off completed items

2. **Implementation with Claude**
   ```
   Pattern:
   1. Read PRD section for feature
   2. Use Claude template from development guide
   3. Implement code
   4. Test locally
   5. Commit with descriptive message
   ```

3. **End of Day**
   - Update milestone checklist
   - Document any blockers
   - Commit all changes

### Example Development Session

**Scenario:** You're starting Milestone 2 (ETL Pipeline)

```bash
# Step 1: Review requirements
# Read PRD section 2.4 and Milestone 2 tasks

# Step 2: Use Claude for extraction module
# In VS Code:
Prompt: "Implement the ETL extraction module (src/etl/extract.py) following 
requirements FR-ETL-001 through FR-ETL-004 from the PRD."

# Step 3: Review generated code
# Check against PRD requirements

# Step 4: Test locally
python -m pytest tests/test_etl_extract.py

# Step 5: Commit
git add src/etl/extract.py tests/test_etl_extract.py
git commit -m "feat(etl): implement extraction module (FR-ETL-001 to FR-ETL-004)"
```

---

## 🎯 Milestone Tracker

### ✅ Milestone 1: Foundation (Weeks 1-2)
**Status:** 🟡 In Progress

**GitHub & Project Setup:**
- [ ] GitHub repository created (asil-lakehouse-poc)
- [ ] Branch protection rules configured
- [ ] .gitignore configured for Python/Docker
- [ ] CONTRIBUTING.md added
- [ ] Initial README committed
- [ ] Team members added with permissions

**Infrastructure:**
- [ ] Docker Compose configuration
- [ ] PostgreSQL schema created
- [ ] Sample data loaded (1M rows)
- [ ] MinIO configured
- [ ] Iceberg catalog setup
- [ ] Health checks implemented

**Documentation:**
- [ ] PRD committed to repository
- [ ] Claude development guide in docs/
- [ ] Architecture diagram created
- [ ] API documentation started

**Current Priority:** Create GitHub repository and complete Docker setup

---

### ⏳ Milestone 2: Data Pipeline (Weeks 3-4)
**Status:** ⚪ Not Started

- [ ] ETL extraction logic
- [ ] Parquet conversion
- [ ] MinIO upload service
- [ ] Iceberg registration
- [ ] DuckDB query interface
- [ ] Scheduling mechanism
- [ ] Transaction logging
- [ ] Monitoring dashboard

**Blocked By:** Milestone 1 completion

---

### ⏳ Milestone 3: AI Agent (Weeks 5-6)
**Status:** ⚪ Not Started

- [ ] OpenAI/LLM setup
- [ ] Schema context embedding
- [ ] NL to SQL conversion
- [ ] Query routing logic
- [ ] REST API endpoints
- [ ] Result formatting
- [ ] Query validation
- [ ] Error handling

**Blocked By:** Milestone 2 completion

---

### ⏳ Milestone 4: Testing & Demo (Weeks 7-8)
**Status:** ⚪ Not Started

- [ ] Unit tests (80% coverage)
- [ ] Integration tests
- [ ] Performance tests
- [ ] Security review
- [ ] Documentation complete
- [ ] Demo script
- [ ] Presentation ready

**Blocked By:** Milestone 3 completion

---

## 🔧 Common Commands

### Docker
```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f [service_name]

# Restart service
docker-compose restart [service_name]

# Stop all services
docker-compose down

# Clean everything (including volumes)
docker-compose down -v
```

### Database
```bash
# Connect to PostgreSQL
docker exec -it lakehouse-poc-postgres-1 psql -U lakeuser -d socialnet

# Common queries
SELECT COUNT(*) FROM posts;
SELECT COUNT(*) FROM users;
SELECT MAX(created_at) FROM posts;

# Check indexes
\di
```

### Python
```bash
# Install dependencies
pip install -r requirements.txt

# Run tests
pytest tests/ -v

# Run specific test file
pytest tests/test_etl.py -v

# Check code coverage
pytest --cov=src tests/
```

### MinIO
```bash
# List buckets
docker exec lakehouse-poc-minio-1 mc ls local

# List files in bucket
docker exec lakehouse-poc-minio-1 mc ls local/lakehouse
```

---

## 🐛 Troubleshooting

### Issue: PostgreSQL won't start
```bash
# Check logs
docker-compose logs postgres

# Common fixes:
# 1. Port 5432 already in use
docker ps | grep 5432  # Find conflicting container
# 2. Volume corruption
docker-compose down -v  # Remove volumes and recreate
```

### Issue: MinIO authentication fails
```bash
# Verify credentials in .env match docker-compose.yml
cat .env | grep MINIO
# Reset: docker-compose down -v && docker-compose up -d
```

### Issue: Python import errors
```bash
# Ensure you're in the right directory
pwd  # Should be project root

# Reinstall dependencies
pip install -r requirements.txt --upgrade

# Check Python version
python --version  # Should be 3.11+
```

### Issue: Claude gives outdated code
```
Always remind Claude: "Please follow the latest requirements from 
lakehouse-poc-prd.md version 1.0"
```

---

## 📞 Getting Help

### When Using Claude
1. **Reference the PRD:** Always mention specific sections
   ```
   "Following PRD section 2.3, implement..."
   ```

2. **Break Down Tasks:** Don't ask for everything at once
   ```
   ❌ "Build the entire AI agent"
   ✅ "Implement the query parser from FR-AI-001"
   ```

3. **Provide Context:** Share relevant code and errors
   ```
   "I'm getting error X when running Y. Here's my code: [paste]
   This should satisfy requirement FR-AI-004."
   ```

### Self-Help Checklist
Before asking for help:
- [ ] Read the PRD section
- [ ] Check docker-compose logs
- [ ] Verify .env configuration
- [ ] Ensure all dependencies installed
- [ ] Check Docker has enough resources
- [ ] Review the Troubleshooting section above

---

## 📊 Success Metrics Dashboard

Track these metrics throughout development:

| Metric | Target | Current | Status |
|--------|--------|---------|--------|
| **Development Progress** |
| Milestones completed | 4/4 | 0/4 | 🔴 |
| Test coverage | 80% | 0% | 🔴 |
| **Performance** |
| OLTP query time | <2s | - | ⚪ |
| Lakehouse query time | <5s | - | ⚪ |
| ETL throughput | 100K rows/min | - | ⚪ |
| **Quality** |
| NL query accuracy | 90% | - | ⚪ |
| Query routing accuracy | 95% | - | ⚪ |
| Code review issues | 0 | - | ⚪ |

Update this table weekly!

---

## 🎬 Demo Preparation (Week 8)

### Pre-Demo Checklist
- [ ] All services running smoothly
- [ ] Sample data loaded and verified
- [ ] All 8 Tier 1 queries tested
- [ ] Performance metrics collected
- [ ] Demo script written
- [ ] Backup plan prepared
- [ ] Stakeholders invited

### Demo Script Template
```
1. Introduction (2 min)
   - Project goals
   - Architecture overview

2. Live Demo (10 min)
   - Show OLTP query: "Show me posts from last week"
   - Show Lakehouse query: "What are the trends over last year?"
   - Demonstrate query routing
   - Show ETL pipeline in action

3. Technical Deep Dive (5 min)
   - Architecture diagram
   - Query routing logic
   - ETL process flow

4. Results & Metrics (3 min)
   - Performance benchmarks
   - Success criteria met
   - Lessons learned

5. Q&A (5 min)
```

---

## 📝 Next Steps After Setup

1. **Day 1: GitHub Repository Setup** ⭐ **START HERE**
   - Create GitHub repository: `asil-lakehouse-poc`
   - Configure branch protection rules
   - Clone repository locally
   - Commit PRD and guides
   - Review `github-workflow-guide.md` for Git best practices

2. **Days 2-3: Complete Milestone 1 Foundation**
   - Complete Docker setup (Tasks 1-4 from Quick Start)
   - Load full dataset
   - Verify all connections
   - Commit all infrastructure code

3. **Week 3: Start ETL development**
   - Use prompts from claude-development-guide.md
   - Implement extraction first
   - Test with small dataset
   - Create PRs for review

4. **Week 4: Complete ETL**
   - Implement transformation and load
   - Set up scheduling
   - Add monitoring
   - Full integration testing

5. **Week 5-6: Build AI Agent**
   - Start with query parser
   - Add OpenAI integration
   - Implement routing logic
   - Test with all Tier 1 queries

6. **Week 7-8: Testing and Demo**
   - Write comprehensive tests
   - Collect performance metrics
   - Prepare demo
   - Present to stakeholders

---

## 🔗 Useful Links

- **PostgreSQL Docs:** https://www.postgresql.org/docs/15/
- **MinIO Docs:** https://min.io/docs/
- **DuckDB Docs:** https://duckdb.org/docs/
- **Apache Iceberg:** https://iceberg.apache.org/docs/latest/
- **FastAPI Docs:** https://fastapi.tiangolo.com/
- **OpenAI API:** https://platform.openai.com/docs/
- **Docker Compose:** https://docs.docker.com/compose/
- **Claude Docs:** https://docs.claude.com/

---

## 💡 Tips for Success

1. **Use the PRD religiously** - It's your source of truth
2. **Commit often** - Small, frequent commits with good messages
3. **Test early** - Don't wait until the end
4. **Document as you go** - Update docs when you implement features
5. **Ask Claude for reviews** - Use it as a code reviewer
6. **Keep it simple** - This is a POC, not production
7. **Track metrics** - Update the success metrics dashboard weekly
8. **Have fun!** - You're building something cool!

---

## 📄 License

[Your License Here]

---

## 👥 Team

- **Owner:** Software Architecture Team
- **Tech Lead:** [Your Name]
- **Contributors:** [Team Members]

---

**Ready to start? Begin with Task 1 above and use Claude to help you build!** 🚀

For detailed implementation guidance, see `claude-development-guide.md`.
For complete requirements, see `lakehouse-poc-prd.md`.

---

*Last Updated: October 28, 2025*
