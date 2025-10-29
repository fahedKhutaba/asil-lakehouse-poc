# VS Code Setup Guide - From GitHub to Development
## ASIL Lakehouse POC

---

## 🎯 Where You Are Now

✅ GitHub repository created: `asil-lakehouse-poc`  
➡️ **Next:** Set up VS Code and start developing

---

## 📋 Step-by-Step Setup

### Step 1: Clone Repository in VS Code (5 minutes)

#### Option A: Using VS Code UI (Recommended for beginners)

1. **Open VS Code**

2. **Press:** `Ctrl+Shift+P` (Windows/Linux) or `Cmd+Shift+P` (Mac)

3. **Type:** `Git: Clone`

4. **Select:** "Clone from GitHub"
   - If prompted to sign in to GitHub, click "Allow"
   - Authorize VS Code to access your GitHub

5. **Search for:** `asil-lakehouse-poc`
   - Select your repository from the list

6. **Choose folder location:**
   - Select where you want to store the project
   - Recommended: `~/Projects/` or `C:\Projects\`

7. **Click:** "Open" when prompted

✅ **Result:** Repository cloned and opened in VS Code!

---

#### Option B: Using Terminal (Alternative)

1. **Open Terminal/Command Prompt**

2. **Navigate to your projects folder:**
   ```bash
   # Windows
   cd C:\Projects
   
   # Mac/Linux
   cd ~/Projects
   ```

3. **Clone the repository:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/asil-lakehouse-poc.git
   cd asil-lakehouse-poc
   ```

4. **Open in VS Code:**
   ```bash
   code .
   ```

---

### Step 2: Install Essential VS Code Extensions (10 minutes)

#### Install Claude Extension (CRITICAL!)

1. **Click:** Extensions icon in sidebar (or press `Ctrl+Shift+X`)

2. **Search:** "Claude"

3. **Install:** "Claude Dev" by Anthropic
   - Click the "Install" button
   - Wait for installation to complete

4. **Configure Claude:**
   - Click the Claude icon in the sidebar (new icon appears)
   - Click "Sign In" or "Enter API Key"
   - Follow prompts to authenticate

---

#### Install Other Recommended Extensions

**In VS Code, press `Ctrl+Shift+P` and type:** `Extensions: Show Recommended Extensions`

Or manually install these:

1. **Python** (by Microsoft)
   - Search: "Python"
   - Install: Microsoft Python extension
   - Essential for Python development

2. **Docker** (by Microsoft)
   - Search: "Docker"
   - Install: Docker extension
   - Manage containers from VS Code

3. **SQLTools** (by Matheus Teixeira)
   - Search: "SQLTools"
   - Install: SQLTools
   - Database management

4. **SQLTools PostgreSQL Driver**
   - Search: "SQLTools PostgreSQL"
   - Install: PostgreSQL driver for SQLTools

5. **YAML** (by Red Hat)
   - Search: "YAML"
   - Install: YAML extension
   - For docker-compose.yml editing

6. **GitLens** (by GitKraken) - Optional but helpful
   - Search: "GitLens"
   - Install: GitLens
   - Enhanced Git capabilities

---

### Step 3: Create Project Structure (5 minutes)

#### Using Claude (Recommended!)

1. **Open Claude in VS Code:**
   - Click the Claude icon in the left sidebar
   - Or press `Ctrl+Shift+P` and type "Claude: Open"

2. **Give Claude this prompt:**
   ```
   Create the complete project structure for the ASIL Lakehouse POC as defined 
   in the PRD section 8.2. Create all directories and empty __init__.py files 
   where needed. The structure should include:
   
   - src/ (with subdirectories: ai_agent, etl, common)
   - tests/
   - docker/ (with subdirectories: postgres, duckdb, ai-agent, etl)
   - data/ (with subdirectories: sample, seeds)
   - docs/
   - scripts/
   
   Create empty __init__.py files in all Python package directories.
   Also create a basic .gitignore file for Python, Docker, and VS Code.
   ```

3. **Claude will create the structure:**
   - Review what Claude creates
   - Approve the changes

✅ **Result:** Complete project structure created!

---

#### Manual Creation (Alternative)

If you prefer to do it manually:

```bash
# In VS Code terminal (Ctrl+` to open)

# Create main directories
mkdir -p src/{ai_agent,etl,common}
mkdir -p tests
mkdir -p docker/{postgres,duckdb,ai-agent,etl}
mkdir -p data/{sample,seeds}
mkdir -p docs
mkdir -p scripts
mkdir -p .github/workflows

# Create __init__.py files
touch src/__init__.py
touch src/ai_agent/__init__.py
touch src/etl/__init__.py
touch src/common/__init__.py
touch tests/__init__.py

# Create basic config files
touch .env.example
touch requirements.txt
touch docker-compose.yml
```

---

### Step 4: Add Documentation Files (5 minutes)

You now need to add the 5 documentation files to your repository:

1. **Create the files in VS Code:**
   - Right-click in Explorer → "New File"
   - Create these files in the root directory:
     - `PROJECT-OVERVIEW.md`
     - `lakehouse-poc-prd.md`
     - `github-workflow-guide.md`
     - `README.md` (replace the default GitHub README)

2. **In the docs/ directory:**
   - Create: `claude-development-guide.md`

3. **Copy content:**
   - Copy the content from each document I provided
   - Paste into the respective files in VS Code

---

### Step 5: Configure VS Code Settings (5 minutes)

#### Create Workspace Settings

1. **Create `.vscode` folder:**
   - In VS Code Explorer, right-click → "New Folder"
   - Name it: `.vscode`

2. **Create `settings.json`:**
   - Inside `.vscode`, create file: `settings.json`
   - Add this content:

```json
{
  "python.defaultInterpreterPath": "${workspaceFolder}/venv/bin/python",
  "python.linting.enabled": true,
  "python.linting.pylintEnabled": false,
  "python.linting.flake8Enabled": true,
  "python.formatting.provider": "black",
  "python.testing.pytestEnabled": true,
  "python.testing.unittestEnabled": false,
  "editor.formatOnSave": true,
  "editor.rulers": [88, 120],
  "files.exclude": {
    "**/__pycache__": true,
    "**/*.pyc": true,
    "**/.pytest_cache": true
  },
  "docker.showStartPage": false,
  "[python]": {
    "editor.defaultFormatter": "ms-python.black-formatter",
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
      "source.organizeImports": true
    }
  },
  "[yaml]": {
    "editor.insertSpaces": true,
    "editor.tabSize": 2,
    "editor.autoIndent": "advanced"
  }
}
```

3. **Create `extensions.json`:**
   - Inside `.vscode`, create file: `extensions.json`
   - Add this content:

```json
{
  "recommendations": [
    "ms-python.python",
    "ms-python.vscode-pylance",
    "ms-python.black-formatter",
    "ms-azuretools.vscode-docker",
    "mtxr.sqltools",
    "mtxr.sqltools-driver-pg",
    "anthropic.claude-dev",
    "redhat.vscode-yaml",
    "eamodio.gitlens"
  ]
}
```

---

### Step 6: Create .gitignore (2 minutes)

**Use Claude:**
```
Create a comprehensive .gitignore file for this Python/Docker project. 
Include patterns for Python artifacts, virtual environments, Docker data, 
IDE files, environment variables, logs, and OS-specific files.
```

Or use this template:

```gitignore
# Python
*.py[cod]
*$py.class
__pycache__/
*.so
.Python
build/
dist/
*.egg-info/
.venv/
venv/
env/

# IDE
.vscode/
.idea/
*.swp
*.swo

# Environment
.env
.env.local
*.env

# Docker
docker-compose.override.yml

# Data
data/raw/
data/processed/
*.csv
*.parquet
minio-data/
postgres-data/

# Logs
*.log
logs/

# Testing
.pytest_cache/
.coverage
htmlcov/

# OS
.DS_Store
Thumbs.db
```

---

### Step 7: Make Your First Commit (5 minutes)

#### Using VS Code Git UI

1. **Open Source Control:**
   - Click Source Control icon in sidebar (or `Ctrl+Shift+G`)

2. **Stage all changes:**
   - Click the "+" icon next to "Changes"
   - Or click "Stage All Changes"

3. **Write commit message:**
   ```
   docs: initial project setup with PRD and guides
   
   - Add complete PRD documentation
   - Add Claude development guide
   - Add GitHub workflow guide
   - Add project overview
   - Create project structure
   - Configure VS Code workspace
   ```

4. **Commit:**
   - Click the "✓" (checkmark) button
   - Or press `Ctrl+Enter`

5. **Push to GitHub:**
   - Click "..." (more actions)
   - Select "Push"
   - Or click the sync button in the status bar

---

#### Using Terminal (Alternative)

```bash
# In VS Code terminal (Ctrl+`)

# Check status
git status

# Stage all files
git add .

# Commit
git commit -m "docs: initial project setup with PRD and guides"

# Push
git push origin main
```

---

### Step 8: Create Python Virtual Environment (5 minutes)

1. **Open VS Code Terminal:** `Ctrl+\``

2. **Create virtual environment:**
   ```bash
   # Windows
   python -m venv venv
   
   # Mac/Linux
   python3 -m venv venv
   ```

3. **Activate virtual environment:**
   ```bash
   # Windows (PowerShell)
   .\venv\Scripts\Activate.ps1
   
   # Windows (Command Prompt)
   .\venv\Scripts\activate.bat
   
   # Mac/Linux
   source venv/bin/activate
   ```

4. **Verify activation:**
   - Your terminal prompt should now show `(venv)`

5. **Install basic dependencies:**
   ```bash
   pip install --upgrade pip
   pip install pylint flake8 black pytest pytest-cov
   ```

6. **Create requirements.txt:**
   ```bash
   pip freeze > requirements.txt
   ```

---

### Step 9: Configure Environment Variables (5 minutes)

1. **Create `.env` file:**
   - In root directory, create file: `.env`
   - **Important:** This file is in .gitignore (won't be committed)

2. **Add configuration:**
   ```bash
   # PostgreSQL
   POSTGRES_HOST=localhost
   POSTGRES_PORT=5432
   POSTGRES_DB=socialnet
   POSTGRES_USER=lakeuser
   POSTGRES_PASSWORD=changeme123
   
   # MinIO
   MINIO_ROOT_USER=minioadmin
   MINIO_ROOT_PASSWORD=minioadmin123
   MINIO_ENDPOINT=localhost:9000
   MINIO_BUCKET=lakehouse
   
   # AI Agent
   OPENAI_API_KEY=your-openai-key-here
   AI_MODEL=gpt-4
   
   # General
   ENVIRONMENT=development
   LOG_LEVEL=INFO
   ```

3. **Create `.env.example`:**
   - Copy `.env` to `.env.example`
   - Replace sensitive values with placeholders
   - This file WILL be committed (as a template)

---

### Step 10: Verify Your Setup (5 minutes)

#### Checklist

**File Structure:**
```
asil-lakehouse-poc/
├── .vscode/
│   ├── settings.json ✓
│   └── extensions.json ✓
├── src/
│   ├── ai_agent/
│   ├── etl/
│   └── common/
├── tests/
├── docker/
├── docs/
│   └── claude-development-guide.md ✓
├── data/
├── scripts/
├── .env ✓
├── .env.example ✓
├── .gitignore ✓
├── requirements.txt ✓
├── PROJECT-OVERVIEW.md ✓
├── lakehouse-poc-prd.md ✓
├── github-workflow-guide.md ✓
└── README.md ✓
```

**VS Code Extensions Installed:**
- [ ] Python
- [ ] Claude Dev
- [ ] Docker
- [ ] SQLTools
- [ ] YAML

**Git Status:**
- [ ] All files committed
- [ ] Pushed to GitHub
- [ ] Can see files on GitHub web interface

**Environment:**
- [ ] Virtual environment created
- [ ] Virtual environment activated (shows `(venv)`)
- [ ] Basic packages installed

---

## 🚀 You're Ready! Next Steps

### Your First Development Task with Claude

Now that setup is complete, let's create your first file using Claude!

**Open Claude in VS Code and use this prompt:**

```
I'm starting Milestone 1 of the ASIL Lakehouse POC. Based on section 6.3 
of lakehouse-poc-prd.md, please create a docker-compose.yml file that 
includes:

1. PostgreSQL 15 with:
   - Persistent volume
   - Environment variables from .env
   - Port 5432 exposed
   - Health check

2. MinIO with:
   - Persistent volume
   - Web console on port 9000
   - API on port 9001
   - Environment variables from .env

3. Placeholder services for:
   - ai-agent (Python FastAPI)
   - etl-service (Python)

Include proper networks, depends_on, and restart policies.
Follow the requirements from PRD section 6.3.
```

**Claude will generate the docker-compose.yml file for you!**

---

## 💡 VS Code Tips for This Project

### Keyboard Shortcuts You'll Use Often

| Action | Windows/Linux | Mac |
|--------|--------------|-----|
| Command Palette | `Ctrl+Shift+P` | `Cmd+Shift+P` |
| Open Terminal | `Ctrl+\`` | `Cmd+\`` |
| Git: Stage | `Ctrl+K Ctrl+S` | `Cmd+K Cmd+S` |
| Git: Commit | `Ctrl+Enter` | `Cmd+Enter` |
| Search Files | `Ctrl+P` | `Cmd+P` |
| Search in Files | `Ctrl+Shift+F` | `Cmd+Shift+F` |
| Toggle Sidebar | `Ctrl+B` | `Cmd+B` |

---

### Using Integrated Terminal

**Multiple Terminals:**
- Click "+" in terminal panel to create new terminal
- Use dropdown to switch between terminals
- Recommended setup:
  - Terminal 1: Main development (with venv activated)
  - Terminal 2: Docker commands
  - Terminal 3: Git commands

---

### Using Claude Effectively in VS Code

**Best Practices:**

1. **Keep PRD Open:**
   - Split editor: drag `lakehouse-poc-prd.md` to right side
   - Reference requirements while Claude generates code

2. **Use @-mentions:**
   - In Claude chat, type `@filename.py` to give Claude context
   - Example: "Review @extract.py against PRD requirements"

3. **Multi-step Tasks:**
   - Break large tasks into smaller Claude prompts
   - Review each output before proceeding

4. **File Operations:**
   - Claude can create, edit, and read files
   - Always review changes before accepting

---

### VS Code Docker Extension Usage

Once docker-compose.yml is created:

1. **View Containers:**
   - Click Docker icon in sidebar
   - See running/stopped containers

2. **Manage Containers:**
   - Right-click container → Start/Stop/Restart
   - Right-click → View Logs
   - Right-click → Attach Shell

3. **Quick Actions:**
   - Right-click docker-compose.yml
   - Select "Compose Up" to start all services
   - Select "Compose Down" to stop all services

---

## 🐛 Troubleshooting

### Issue: Claude Extension Not Working

**Solution:**
1. Verify installation: Extensions → Search "Claude Dev"
2. Sign in: Click Claude icon → Sign In
3. Restart VS Code
4. Check API key if using Claude API

---

### Issue: Python Interpreter Not Found

**Solution:**
1. Press `Ctrl+Shift+P`
2. Type: "Python: Select Interpreter"
3. Choose: `./venv/bin/python` (or `.\venv\Scripts\python.exe` on Windows)

---

### Issue: Git Push Fails (Authentication)

**Solution:**
1. GitHub may require Personal Access Token
2. Go to: GitHub → Settings → Developer settings → Personal access tokens
3. Generate new token (classic)
4. Use token as password when pushing

Or use GitHub CLI:
```bash
gh auth login
```

---

### Issue: Terminal Shows "command not found"

**Solution:**
1. Ensure virtual environment is activated
2. Check PATH configuration
3. Restart VS Code
4. Reinstall Python packages

---

## 📚 Quick Reference

### Daily Workflow in VS Code

```
Morning:
1. Open VS Code
2. Pull latest changes: Source Control → Pull
3. Check README.md milestone tracker
4. Activate virtual environment: source venv/bin/activate

During Development:
1. Use Claude for code generation
2. Test locally
3. Commit frequently
4. Push at end of major changes

End of Day:
1. Commit all changes
2. Push to GitHub
3. Update README.md milestone tracker
```

---

### Essential Commands in VS Code Terminal

```bash
# Git
git status
git add .
git commit -m "message"
git push origin main

# Docker
docker-compose up -d
docker-compose down
docker-compose logs -f [service]

# Python
source venv/bin/activate  # Mac/Linux
.\venv\Scripts\Activate.ps1  # Windows
pip install -r requirements.txt
pytest tests/ -v

# Project
python scripts/seed_data.py
python -m src.etl.main
```

---

## ✅ Setup Complete Checklist

Before moving to development, verify:

- [ ] Repository cloned in VS Code
- [ ] All 5 documentation files added
- [ ] VS Code extensions installed (especially Claude!)
- [ ] Project structure created
- [ ] .gitignore configured
- [ ] .env file created and configured
- [ ] Virtual environment created and activated
- [ ] requirements.txt exists
- [ ] Initial commit made and pushed
- [ ] Can see files on GitHub
- [ ] Claude extension working in VS Code
- [ ] Ready to start Milestone 1 tasks!

---

## 🎯 Next Step

**You're now ready to start actual development!**

Go to: `README.md` → "Your First Hour Tasks" → Task 1: Docker Setup

Use Claude with the prompt provided above to generate your docker-compose.yml file.

**Happy coding!** 🚀

---

*If you run into any issues, check the Troubleshooting section or refer to github-workflow-guide.md for Git-specific questions.*
