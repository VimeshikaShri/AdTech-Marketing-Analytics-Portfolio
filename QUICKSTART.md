# Quick Start Guide

Get your AdTech portfolio up and running in 10 minutes.

## 1. Clone & Install (2 minutes)

```bash
git clone https://github.com/VimeshikaShri/adtech-portfolio.git
cd adtech-portfolio
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

## 2. Configure Credentials (3 minutes)

```bash
# Copy example config
cp config.example.yaml config.yaml

# Edit with your credentials
nano config.yaml  # or use your editor
```

**Required:**
- `google_ads.customer_id`: Your Google Ads account ID
- `google_ads.developer_token`: Get from Google Ads account
- `bidding_strategy.daily_budget_usd`: Your daily budget

## 3. Test Connection (2 minutes)

```bash
# Test budget monitor
python scripts/budget_monitor.py --config config.yaml --once

# Test bidding strategy (dry run)
python scripts/automated_bidding_strategy.py --config config.yaml --dry-run
```

## 4. Set Up Scheduling (3 minutes)

### Option A: Linux/Mac (Cron)

```bash
crontab -e
# Add these lines:
0 * * * * cd /path/to/adtech-portfolio && python scripts/budget_monitor.py --once
0 6 * * * cd /path/to/adtech-portfolio && python scripts/automated_bidding_strategy.py
```

### Option B: Windows (Task Scheduler)
1. Open Task Scheduler
2. Create Basic Task
3. Set trigger and action

## 5. Start Optimizing

```bash
# Monitor budget
python scripts/budget_monitor.py --once

# Optimize bids
python scripts/automated_bidding_strategy.py --dry-run  # Test first
python scripts/automated_bidding_strategy.py            # Run live
```

## Key Files

| File | Purpose |
|------|---------|
| `config.yaml` | Configuration (KEEP PRIVATE!) |
| `scripts/` | Python automation scripts |
| `sql_queries/` | BigQuery analytics queries |
| `dashboards/` | Looker Studio setup guides |
| `docs/` | Detailed documentation |

## Next Steps

1. **📊 Set up dashboards** → See `dashboards/DASHBOARD_SETUP.md`
2. **📈 Run SQL queries** → See `sql_queries/comprehensive_marketing_analytics.sql`
3. **⚙️ Advanced setup** → See `docs/INSTALLATION.md`
4. **📚 Full documentation** → See `docs/USAGE.md`

## Common Commands

```bash
# Budget monitoring
python scripts/budget_monitor.py --config config.yaml --once

# Bidding optimization (dry run)
python scripts/automated_bidding_strategy.py --config config.yaml --dry-run

# Bidding optimization (live)
python scripts/automated_bidding_strategy.py --config config.yaml

# View logs
tail -f logs/adtech.log

# Run specific campaign
python scripts/automated_bidding_strategy.py --config config.yaml --campaign-id 123456
```

## Troubleshooting

### "Developer token not set"
→ Add to `config.yaml`: `developer_token: "YOUR_TOKEN"`

### "Customer ID not found"
→ Find your account ID: Google Ads → Settings → Account settings → Customer ID

### "BigQuery not connected"
→ See `docs/INSTALLATION.md` → Step 7

## Support

- Installation issues → `docs/INSTALLATION.md`
- Usage questions → `docs/USAGE.md`
- Common problems → `docs/TROUBLESHOOTING.md`
- API reference → `docs/API_REFERENCE.md`

---

**Ready to start?** Run this command:
```bash
python scripts/budget_monitor.py --config config.yaml --once
```

You should see your account's daily spend and budget pace!
