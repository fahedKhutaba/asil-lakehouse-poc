# Git Workflow & GitHub Best Practices
## ASIL Lakehouse POC (AI Solution)

---

## Repository Information

- **Repository Name:** `asil-lakehouse-poc`
- **Full Name:** ASIL (AI Solution) - Lakehouse Proof of Concept
- **Purpose:** AI-powered data platform integrating OLTP and Lakehouse architectures
- **Visibility:** [Private/Public - configure based on your needs]

---

## Initial Repository Setup

### Step 1: Create Repository on GitHub

**Via GitHub Web Interface:**
1. Go to https://github.com/new
2. Fill in details:
   ```
   Owner: [Your Organization/Username]
   Repository name: asil-lakehouse-poc
   Description: AI-powered Lakehouse POC - OLTP & Analytical Data Platform with Natural Language Querying
   Visibility: ○ Public  ● Private  (recommended for POC)
   
   ✅ Add a README file
   ✅ Add .gitignore: Python
   ✅ Choose a license: MIT License (or your preference)
   ```
3. Click "Create repository"

**Via GitHub CLI (Alternative):**
```bash
gh repo create asil-lakehouse-poc --private --description "AI-powered Lakehouse POC" --gitignore Python --license mit
```

---

### Step 2: Initial Clone and Setup

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/asil-lakehouse-poc.git
cd asil-lakehouse-poc

# Verify remote
git remote -v

# Create initial branch structure (optional)
git checkout -b develop
git push -u origin develop
```

---

## Branch Strategy

### Branch Naming Convention

```
main              # Production-ready code
├── develop       # Integration branch (optional for POC)
├── feature/*     # New features
├── bugfix/*      # Bug fixes
├── hotfix/*      # Urgent production fixes
└── docs/*        # Documentation updates
```

### Branch Naming Examples

```bash
# Features
feature/milestone1-docker-setup
feature/etl-extraction-module
feature/ai-agent-query-parser
feature/lakehouse-integration

# Bug fixes
bugfix/postgres-connection-timeout
bugfix/minio-authentication-error

# Documentation
docs/api-documentation
docs/architecture-diagram

# Hotfixes
hotfix/critical-data-loss-in-etl
```

---

## Commit Message Convention

We follow **Conventional Commits** specification.

### Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types
- **feat:** New feature
- **fix:** Bug fix
- **docs:** Documentation changes
- **style:** Code style changes (formatting, no logic change)
- **refactor:** Code refactoring
- **test:** Adding or updating tests
- **chore:** Maintenance tasks
- **perf:** Performance improvements
- **ci:** CI/CD changes

### Examples

```bash
# Good commit messages
git commit -m "feat(etl): implement PostgreSQL extraction module

- Add watermark-based extraction
- Support batch processing of 10K rows
- Include transaction logging
- Implements FR-ETL-001 through FR-ETL-003"

git commit -m "fix(docker): resolve MinIO connection timeout

MinIO container was not starting due to volume permission issues.
Updated docker-compose.yml with explicit user permissions.

Fixes #12"

git commit -m "docs(prd): update milestone 1 completion criteria"

git commit -m "test(ai-agent): add unit tests for query routing

Covers all 8 Tier 1 queries from PRD section 5.1
Achieves 85% code coverage"

# Bad commit messages (avoid these)
git commit -m "fix stuff"
git commit -m "WIP"
git commit -m "Updated files"
git commit -m "changes"
```

---

## Git Workflow

### Daily Development Workflow

```bash
# 1. Start your day - sync with remote
git checkout main
git pull origin main

# 2. Create feature branch
git checkout -b feature/milestone2-etl-pipeline

# 3. Make changes and commit frequently
# ... work on your code ...

git add src/etl/extract.py
git commit -m "feat(etl): implement extraction logic"

# ... more work ...

git add tests/test_etl_extract.py
git commit -m "test(etl): add extraction module unit tests"

# 4. Push to remote regularly
git push origin feature/milestone2-etl-pipeline

# 5. Create Pull Request when ready
# Go to GitHub and create PR from your feature branch to main
```

---

### Working with Claude

**Commit after each major Claude-generated change:**

```bash
# After Claude generates Docker Compose
git add docker-compose.yml
git commit -m "feat(docker): add docker-compose configuration

Generated with Claude following PRD section 6.3
Includes PostgreSQL, MinIO, DuckDB, AI Agent, and ETL services"

# After Claude generates schema
git add docker/postgres/init.sql
git commit -m "feat(database): add PostgreSQL schema

Implements schema from PRD section 2.1
Includes all indexes and foreign key constraints"

# After Claude creates ETL module
git add src/etl/extract.py tests/test_etl_extract.py
git commit -m "feat(etl): implement extraction module

- Watermark-based extraction
- Batch processing support
- Implements FR-ETL-001 through FR-ETL-003
- Includes unit tests"
```

---

## Pull Request Process

### Creating a Pull Request

1. **Push your branch:**
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create PR on GitHub:**
   - Navigate to your repository
   - Click "Pull requests" → "New pull request"
   - Base: `main` ← Compare: `feature/your-feature-name`
   - Fill in the template (see below)

3. **PR Template:**
   ```markdown
   ## Description
   Brief description of what this PR does
   
   ## Milestone
   - [ ] Milestone 1: Foundation
   - [ ] Milestone 2: Data Pipeline
   - [ ] Milestone 3: AI Agent
   - [ ] Milestone 4: Testing & Demo
   
   ## Requirements Addressed
   - FR-XXX-001: [Description]
   - FR-XXX-002: [Description]
   
   ## Changes Made
   - Added feature X
   - Modified component Y
   - Fixed bug Z
   
   ## Testing
   - [ ] Unit tests added/updated
   - [ ] Integration tests pass
   - [ ] Manual testing completed
   
   ## Screenshots (if applicable)
   [Add screenshots]
   
   ## Checklist
   - [ ] Code follows project conventions
   - [ ] Documentation updated
   - [ ] No sensitive data in commits
   - [ ] Tested locally
   - [ ] Ready for review
   ```

### Code Review Process

**For Reviewers:**
- Check compliance with PRD requirements
- Verify code quality and best practices
- Test functionality locally
- Provide constructive feedback
- Approve when satisfied

**For Authors:**
- Address all review comments
- Push updates to the same branch
- Mark conversations as resolved
- Request re-review when ready

---

## Branch Protection Rules

### Recommended Settings for `main` Branch

**In GitHub: Settings → Branches → Add rule**

```yaml
Branch name pattern: main

Protect matching branches:
  ✅ Require a pull request before merging
    ✅ Require approvals: 1
    ✅ Dismiss stale pull request approvals when new commits are pushed
    ✅ Require review from Code Owners (if using CODEOWNERS)
  
  ✅ Require status checks to pass before merging
    ✅ Require branches to be up to date before merging
    Status checks (if CI/CD set up):
      - pytest
      - linting
  
  ✅ Require conversation resolution before merging
  ✅ Require linear history (optional, prevents merge commits)
  ✅ Include administrators
```

---

## GitHub Issues

### Issue Template: Bug Report

```markdown
**Bug Description**
A clear description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Run command '....'
3. See error

**Expected Behavior**
What you expected to happen.

**Actual Behavior**
What actually happened.

**Environment**
- OS: [e.g., macOS, Windows, Linux]
- Docker version:
- Python version:

**PRD Reference**
Which requirement does this relate to? (e.g., FR-ETL-001)

**Screenshots**
If applicable, add screenshots.

**Additional Context**
Any other context about the problem.
```

### Issue Template: Feature Request

```markdown
**Feature Description**
A clear description of the feature.

**PRD Reference**
Which section/requirement is this related to?

**Proposed Solution**
How you think this should be implemented.

**Alternatives Considered**
Other approaches you've thought about.

**Additional Context**
Any other context or screenshots.
```

### Issue Labels

Create these labels in your repository:

| Label | Color | Description |
|-------|-------|-------------|
| `milestone-1` | #0366d6 | Foundation phase |
| `milestone-2` | #0366d6 | Data Pipeline phase |
| `milestone-3` | #0366d6 | AI Agent phase |
| `milestone-4` | #0366d6 | Testing & Demo phase |
| `bug` | #d73a4a | Something isn't working |
| `enhancement` | #a2eeef | New feature or request |
| `documentation` | #0075ca | Documentation improvements |
| `priority-high` | #d93f0b | High priority |
| `priority-medium` | #fbca04 | Medium priority |
| `priority-low` | #d4c5f9 | Low priority |
| `claude-assisted` | #7057ff | Generated with Claude assistance |
| `needs-review` | #fbca04 | Needs code review |
| `blocked` | #d93f0b | Blocked by another issue |

---

## Project Board (Optional)

### GitHub Projects Setup

1. **Go to:** Repository → Projects → New project
2. **Choose template:** Board
3. **Create columns:**
   - 📋 Backlog
   - 🔜 Ready
   - 🏗️ In Progress
   - 👀 In Review
   - ✅ Done

4. **Link to milestones:**
   - Create GitHub Milestones for each PRD milestone
   - Link issues to milestones
   - Track progress

---

## .gitignore Configuration

### Comprehensive .gitignore for ASIL POC

```gitignore
# Python
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# Virtual Environments
venv/
env/
ENV/
env.bak/
venv.bak/
.venv/

# PyCharm
.idea/
*.iml

# VS Code
.vscode/
*.code-workspace

# Jupyter Notebook
.ipynb_checkpoints

# Environment Variables
.env
.env.local
.env.*.local
*.env

# Docker
docker-compose.override.yml
.docker/

# Data files (don't commit large datasets)
data/raw/
data/processed/
*.csv
*.parquet
*.db
*.sqlite

# Logs
*.log
logs/
*.out

# OS
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Testing
.pytest_cache/
.coverage
htmlcov/
.tox/
coverage.xml
*.cover

# MinIO data
minio-data/

# PostgreSQL data
postgres-data/

# Temporary files
*.tmp
*.bak
*.swp
*~

# Secrets (extra safety)
secrets/
credentials/
*.key
*.pem
*.crt

# IDE
*.sublime-*

# Documentation builds
docs/_build/
site/
```

---

## CODEOWNERS File (Optional)

Create `.github/CODEOWNERS`:

```
# CODEOWNERS for ASIL Lakehouse POC

# Default owners for everything
* @your-username

# Specific component owners
/src/etl/ @data-engineer-username
/src/ai_agent/ @ml-engineer-username
/docker/ @devops-username
/docs/ @tech-writer-username

# PRD and architecture docs require team lead approval
/lakehouse-poc-prd.md @tech-lead-username
/docs/ARCHITECTURE.md @tech-lead-username
```

---

## GitHub Actions CI/CD (Optional for Phase 1)

### Basic CI Workflow

Create `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        python-version: [3.11]
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python ${{ matrix.python-version }}
      uses: actions/setup-python@v4
      with:
        python-version: ${{ matrix.python-version }}
    
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt
        pip install pytest pytest-cov flake8
    
    - name: Lint with flake8
      run: |
        flake8 src/ --count --select=E9,F63,F7,F82 --show-source --statistics
        flake8 src/ --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics
    
    - name: Test with pytest
      run: |
        pytest tests/ -v --cov=src --cov-report=xml
    
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage.xml
```

---

## Common Git Commands Reference

### Syncing with Remote

```bash
# Fetch all remote changes
git fetch origin

# Pull changes from main
git pull origin main

# Push your changes
git push origin your-branch-name

# Force push (use carefully!)
git push origin your-branch-name --force-with-lease
```

### Branch Management

```bash
# List all branches
git branch -a

# Create new branch
git checkout -b feature/new-feature

# Switch branches
git checkout main

# Delete local branch
git branch -d feature/old-feature

# Delete remote branch
git push origin --delete feature/old-feature

# Rename current branch
git branch -m new-branch-name
```

### Stashing Changes

```bash
# Save current work temporarily
git stash

# List stashes
git stash list

# Apply most recent stash
git stash apply

# Apply and remove stash
git stash pop

# Stash with message
git stash save "WIP: working on ETL extraction"
```

### Undoing Changes

```bash
# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes - dangerous!)
git reset --hard HEAD~1

# Revert a specific commit
git revert <commit-hash>

# Discard changes in working directory
git checkout -- filename.py

# Discard all local changes
git reset --hard HEAD
```

### Viewing History

```bash
# View commit history
git log --oneline --graph --all

# View changes in last commit
git show

# View changes in specific file
git log -p filename.py

# View who changed what in a file
git blame filename.py
```

---

## Troubleshooting Git Issues

### Issue: Merge Conflicts

```bash
# When you see merge conflicts:
# 1. Open the conflicted files
# 2. Look for conflict markers: <<<<<<<, =======, >>>>>>>
# 3. Resolve conflicts manually
# 4. Add resolved files
git add resolved-file.py

# 5. Continue merge
git commit
```

### Issue: Accidentally Committed Secrets

```bash
# IMMEDIATELY:
# 1. Remove from history (if not pushed yet)
git reset --soft HEAD~1
# Edit files to remove secrets
git add .
git commit -m "fix: remove secrets"

# 2. If already pushed - use BFG Repo Cleaner or git-filter-branch
# Then ROTATE all exposed credentials immediately!

# 3. Add to .gitignore to prevent future commits
echo ".env" >> .gitignore
```

### Issue: Need to Change Last Commit Message

```bash
# If not pushed yet
git commit --amend -m "New commit message"

# If already pushed (creates new commit)
git revert HEAD
git commit -m "Correct commit message"
```

---

## Best Practices Summary

### ✅ Do:
- Commit early and often
- Write descriptive commit messages
- Use branches for all features/fixes
- Pull before you push
- Review your changes before committing
- Keep commits focused (one logical change per commit)
- Reference issue numbers in commits
- Use .gitignore properly

### ❌ Don't:
- Commit directly to main
- Push untested code
- Commit secrets or credentials
- Use vague commit messages
- Commit large binary files
- Force push to shared branches
- Leave merge conflicts unresolved
- Commit commented-out code

---

## Quick Reference: First Week Git Usage

### Day 1: Repository Setup
```bash
git clone https://github.com/YOUR_USERNAME/asil-lakehouse-poc.git
cd asil-lakehouse-poc
git checkout -b feature/milestone1-setup
# Add PRD and docs
git add .
git commit -m "docs: add PRD and development guides"
git push origin feature/milestone1-setup
```

### Day 2-3: Docker Configuration
```bash
git checkout -b feature/docker-compose-setup
# Work with Claude to generate docker-compose.yml
git add docker-compose.yml .env.example docker/
git commit -m "feat(docker): add docker-compose configuration for all services"
git push origin feature/docker-compose-setup
# Create PR, get review, merge
```

### Day 4-5: Database Schema
```bash
git checkout main
git pull origin main
git checkout -b feature/postgres-schema
# Generate schema with Claude
git add docker/postgres/
git commit -m "feat(database): implement PostgreSQL schema with indexes"
git push origin feature/postgres-schema
```

### Week 2+: Continue Pattern
Always: Create branch → Commit frequently → Push → PR → Review → Merge

---

## Resources

- **Git Documentation:** https://git-scm.com/doc
- **GitHub Docs:** https://docs.github.com
- **Conventional Commits:** https://www.conventionalcommits.org/
- **Git Best Practices:** https://github.com/git-guides

---

**Remember:** Good version control is the foundation of successful collaboration. 
Make it a habit to commit often, write clear messages, and communicate through PRs!

---

*Last Updated: October 28, 2025*
