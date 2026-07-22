# GitHub Upload Guide

## Step-by-Step: Upload AdTech Portfolio to GitHub

### Prerequisites
- GitHub account (free at github.com)
- Git installed locally
- AdTech portfolio zip file extracted

## Method 1: Using GitHub Web Interface (Easiest)

### Step 1: Create New Repository

1. Go to [github.com/new](https://github.com/new)
2. Enter repository name: `adtech-portfolio`
3. Add description: "Production-ready marketing analytics and automation toolkit for Google Ads and GA4"
4. Choose visibility: **Public** (to share with others)
5. ✅ Check "Add a README file"
6. Click **Create repository**

### Step 2: Upload Files

1. Click **"Upload files"** button
2. Drag and drop the extracted project files
3. Or click to select files from your computer
4. Commit message: `Initial commit: AdTech portfolio with bidding strategy, dashboards, and queries`
5. Click **Commit changes**

## Method 2: Using Git Command Line (Recommended)

### Step 1: Create Repository on GitHub
1. Go to [github.com/new](https://github.com/new)
2. Create repository named `adtech-portfolio`
3. Don't initialize with README (we have one)

### Step 2: Setup Local Git

```bash
# Navigate to project folder
cd /path/to/adtech-portfolio

# Initialize git repository
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: AdTech portfolio with bidding strategy, dashboards, and SQL queries"
```

### Step 3: Connect to GitHub

```bash
# Replace YOUR_USERNAME with your GitHub username
git remote add origin https://github.com/YOUR_USERNAME/adtech-portfolio.git

# Rename branch to main (if needed)
git branch -M main

# Push to GitHub
git push -u origin main
```

### Step 4: Verify Upload

Visit: `https://github.com/YOUR_USERNAME/adtech-portfolio`

You should see all your files!

## Method 3: GitHub Desktop (GUI)

1. Download GitHub Desktop from [desktop.github.com](https://desktop.github.com)
2. Install and log in with your GitHub account
3. Click **"Add"** → **"Add Existing Repository"**
4. Select your adtech-portfolio folder
5. Click **"Publish repository"**
6. Set visibility to **Public**
7. Click **Publish Repository**

## After Upload: GitHub Customization

### 1. Add Repository Topics

In repository settings, add tags:
```
marketing
google-ads
bigquery
automation
python
analytics
looker-studio
```

### 2. Update Repository Description

```
Production-ready marketing analytics and automation toolkit featuring:
- Automated bidding strategy with ROAS optimization
- Real-time budget pacing monitor
- 50+ BigQuery analytics queries
- Looker Studio dashboard templates
- Campaign performance analysis
```

### 3. Add to GitHub Topics

Go to **Settings** → **About** (gear icon) → Add these topics:
- marketing-analytics
- google-ads-api
- bigquery
- python
- adtech
- marketing-automation

### 4. Enable GitHub Pages (Optional)

To create project website:
1. Go to **Settings** → **Pages**
2. Select source: **main branch** → **/docs**
3. Your documentation will be at: `https://yourname.github.io/adtech-portfolio/`

### 5. Create GitHub Actions (Optional)

Automate Python tests:

Create `.github/workflows/tests.yml`:

```yaml
name: Tests

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Set up Python
      uses: actions/setup-python@v2
      with:
        python-version: 3.9
    - name: Install dependencies
      run: |
        pip install -r requirements.txt
    - name: Run tests
      run: |
        pytest tests/
```

## File-by-File Breakdown for GitHub

### Root Level
- ✅ README.md - Main documentation
- ✅ QUICKSTART.md - Quick setup
- ✅ requirements.txt - Python dependencies
- ✅ config.example.yaml - Configuration template
- ✅ .gitignore - Ignore sensitive files
- ✅ LICENSE - MIT license

### scripts/ folder
- ✅ automated_bidding_strategy.py - Main optimization script
- ✅ budget_monitor.py - Budget tracking
- ✅ utils.py - Utility functions

### sql_queries/ folder
- ✅ comprehensive_marketing_analytics.sql - 50+ queries

### dashboards/ folder
- ✅ DASHBOARD_SETUP.md - Looker Studio guide

### docs/ folder
- ✅ INSTALLATION.md - Setup instructions
- ✅ USAGE.md - Usage guide
- ✅ TROUBLESHOOTING.md - Common issues

### DO NOT UPLOAD
- ❌ config.yaml (contains credentials!)
- ❌ google-ads.yaml (contains credentials!)
- ❌ logs/ (log files)
- ❌ __pycache__/ (cached Python)
- ❌ venv/ (virtual environment)
- ❌ .env (environment variables)

## Important: Protect Credentials

### .gitignore Protection

Your .gitignore already prevents uploading:
- config.yaml (YOUR credentials)
- google-ads.yaml (API keys)
- .env files
- API keys and tokens

### Extra Safety

Before uploading, verify:

```bash
# Make sure credentials files aren't in git
git status

# Should NOT show:
# - config.yaml
# - google-ads.yaml
# - Any credential files

# If they appear, remove them:
git rm --cached config.yaml
```

## GitHub Repository Best Practices

### 1. Add Meaningful Commits

```bash
git commit -m "Add automated bidding strategy script

- Implements ROAS-based optimization
- Supports CPA targets
- Includes dry-run mode
- Adds Slack notifications"
```

### 2. Create Branches for Features

```bash
git checkout -b feature/new-dashboard
# Make changes
git commit -m "Add new performance dashboard"
git push origin feature/new-dashboard
```

### 3. Create Releases

Go to **Releases** → **Create a new release**:
- Tag: `v1.0.0`
- Title: `v1.0.0 - Initial Release`
- Include changelog and instructions

### 4. Enable Discussions (Optional)

In Settings → **Features**:
- ✅ Enable **Discussions** for community Q&A
- ✅ Enable **Sponsorships** for support

## Sharing Your Project

### Share on Social Media

```
🚀 Just published: AdTech Marketing Analytics Portfolio

Production-ready toolkit for Google Ads automation:
✅ Automated bidding strategy
✅ Real-time budget monitoring
✅ 50+ BigQuery analytics queries
✅ Looker Studio dashboards

Open source, MIT licensed.
👉 github.com/yourname/adtech-portfolio
#MarketingTech #Python #GoogleAds
```

### Add to Portfolio

```markdown
## AdTech Portfolio
Production-ready marketing analytics and automation toolkit.
Features automated bidding, budget monitoring, and 50+ SQL queries.
[View on GitHub](https://github.com/yourname/adtech-portfolio)
```

## Verify Upload Success

After uploading, verify:

✅ All files visible on GitHub
✅ No credential files exposed
✅ README.md renders properly
✅ Code syntax highlighting works
✅ .gitignore prevents commits

## Troubleshooting

### "Permission denied (publickey)"
```bash
# Generate SSH key if needed
ssh-keygen -t ed25519 -C "your-email@example.com"
# Add to GitHub: Settings → SSH Keys
```

### "Remote origin already exists"
```bash
git remote remove origin
git remote add origin https://github.com/YOUR_USERNAME/adtech-portfolio.git
```

### "File too large"
Files > 100 MB won't upload. Use Git LFS for large files:
```bash
git lfs install
git lfs track "*.csv"
git add .gitattributes
```

## Keep Updated

### Pull Latest Changes

If you update locally:
```bash
git add .
git commit -m "Update: description of changes"
git push origin main
```

### Sync Fork

If you forked someone else's repo:
```bash
git fetch upstream
git merge upstream/main
git push origin main
```

## Advanced: GitHub Actions for Automation

### Automated Testing

Create `.github/workflows/test.yml`:

```yaml
name: Python Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-python@v2
      - run: pip install -r requirements.txt
      - run: pytest tests/
```

### Automated Deployment

For cloud deployment, add workflow to deploy to Cloud Functions or Kubernetes.

## Summary Checklist

- [ ] Extract zip file
- [ ] Create GitHub repository
- [ ] Initialize git locally
- [ ] Add and commit files
- [ ] Push to GitHub
- [ ] Verify all files are visible
- [ ] Check no credentials are exposed
- [ ] Add repository description
- [ ] Add topics/tags
- [ ] Update profile with link
- [ ] Share with colleagues

---

**Your AdTech portfolio is now on GitHub! 🎉**

Share the link: `https://github.com/YOUR_USERNAME/adtech-portfolio`
