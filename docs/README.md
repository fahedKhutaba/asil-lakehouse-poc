# Documentation Organization Guide

This directory contains all project documentation organized by purpose and lifecycle.

## 📁 Directory Structure

```
docs/
├── README.md                    # This file - documentation guide
├── project/                     # Core project documentation
│   ├── lakehouse-poc-prd.md    # Product Requirements Document
│   └── PROJECT-OVERVIEW.md      # Project overview and guide
├── development/                 # Development guides and workflows
│   ├── claude-development-guide.md
│   ├── github-workflow-guide.md
│   └── VSCODE-SETUP-GUIDE.md
├── architecture/                # Architecture diagrams and decisions
│   └── (architecture docs will go here)
└── generated/                   # Auto-generated documentation
    └── (summaries, reports, etc.)
```

## 📋 Documentation Categories

### 1. **project/** - Core Project Documentation
**Purpose:** Essential project documents that define requirements and scope  
**Contents:**
- `lakehouse-poc-prd.md` - Complete Product Requirements Document
- `PROJECT-OVERVIEW.md` - Project overview and documentation guide

**When to use:**
- Before starting any feature implementation
- During planning and design phases
- When validating requirements

**Keep these files:**
- ✅ Version controlled
- ✅ Updated when requirements change
- ✅ Referenced in all development work

---

### 2. **development/** - Development Guides
**Purpose:** Guides for development workflows and tools  
**Contents:**
- `claude-development-guide.md` - AI-assisted development prompts
- `github-workflow-guide.md` - Git and GitHub best practices
- `VSCODE-SETUP-GUIDE.md` - IDE setup instructions

**When to use:**
- Daily development work
- Setting up development environment
- Creating commits and PRs
- Using AI assistance effectively

**Keep these files:**
- ✅ Version controlled
- ✅ Updated as workflows evolve
- ✅ Shared with team members

---

### 3. **architecture/** - Architecture Documentation
**Purpose:** System design, architecture decisions, and diagrams  
**Contents:** (To be created as needed)
- Architecture diagrams
- Database schemas
- API specifications
- Design decisions (ADRs)
- System flow diagrams

**When to create:**
- After major design decisions
- When documenting system architecture
- For onboarding new team members

**Keep these files:**
- ✅ Version controlled
- ✅ Updated with major changes
- ✅ Include diagrams and visuals

---

### 4. **generated/** - Auto-Generated Documentation
**Purpose:** Temporary documentation, summaries, and reports  
**Contents:**
- AI-generated summaries
- Progress reports
- Meeting notes
- Temporary analysis files
- Code generation artifacts

**Characteristics:**
- ⚠️ **NOT version controlled** (in .gitignore)
- ⚠️ Can be deleted/regenerated
- ⚠️ Temporary by nature
- ⚠️ Used for reference only

**When to use:**
- Storing AI conversation summaries
- Temporary analysis and reports
- Draft documentation
- Work-in-progress notes

---

## 🔄 Documentation Workflow

### Creating New Documentation

1. **Determine the category:**
   - Core requirements → `project/`
   - Development guide → `development/`
   - Architecture/design → `architecture/`
   - Temporary/generated → `generated/`

2. **Create the file in the appropriate directory**

3. **Update this README if adding a new category**

### Managing Generated Documentation

The `generated/` folder is specifically for files that:
- Are created automatically (by AI, scripts, tools)
- Don't need to be version controlled
- Can be safely deleted and recreated
- Are used for temporary reference

**Best practices:**
- Clean up old generated files regularly
- Don't rely on generated files for critical information
- Move important insights to permanent documentation
- Use descriptive filenames with dates (e.g., `summary-2025-10-29.md`)

---

## 🚫 What's Ignored in Git

The `.gitignore` file excludes:
```
# Generated documentation (not version controlled)
docs/generated/

# Temporary files
docs/**/*.tmp
docs/**/*~
```

---

## 📝 Documentation Best Practices

### For Permanent Documentation (project/, development/, architecture/)

1. **Keep it current:** Update docs when code changes
2. **Be specific:** Include examples and code snippets
3. **Use clear structure:** Headers, lists, and formatting
4. **Link related docs:** Cross-reference when helpful
5. **Version control:** Commit documentation with related code changes

### For Generated Documentation (generated/)

1. **Use timestamps:** Include dates in filenames
2. **Clean regularly:** Delete old files you don't need
3. **Extract insights:** Move important information to permanent docs
4. **Don't depend on it:** Treat as temporary reference only

---

## 🔍 Finding Documentation

### By Purpose

| I need to... | Look in... |
|-------------|-----------|
| Understand requirements | `project/lakehouse-poc-prd.md` |
| Get project overview | `project/PROJECT-OVERVIEW.md` |
| Use AI assistance | `development/claude-development-guide.md` |
| Work with Git/GitHub | `development/github-workflow-guide.md` |
| Set up VS Code | `development/VSCODE-SETUP-GUIDE.md` |
| View architecture | `architecture/` (to be created) |
| Find AI summaries | `generated/` (temporary) |

### By Development Phase

| Phase | Primary Documents |
|-------|------------------|
| **Planning** | `project/lakehouse-poc-prd.md` |
| **Setup** | `development/VSCODE-SETUP-GUIDE.md` |
| **Development** | `development/claude-development-guide.md` |
| **Collaboration** | `development/github-workflow-guide.md` |
| **Architecture** | `architecture/` (as needed) |

---

## 🎯 Quick Reference

### Essential Reading (Start Here)
1. `project/PROJECT-OVERVIEW.md` - Understand the project
2. `project/lakehouse-poc-prd.md` - Know the requirements
3. `development/github-workflow-guide.md` - Set up Git workflow

### Daily Development
- `development/claude-development-guide.md` - AI assistance
- `project/lakehouse-poc-prd.md` - Requirement reference

### Generate
