# Usage Guide

## Quick Start

### 1. Run Budget Monitor

Monitor daily spend vs. budget allocation:

```bash
# Run once
python scripts/budget_monitor.py --config config.yaml --once

# Run continuously (check every hour)
python scripts/budget_monitor.py --config config.yaml --interval 3600
```

### 2. Run Automated Bidding Strategy

Optimize bids based on performance:

```bash
# Dry run (no changes made)
python scripts/automated_bidding_strategy.py --config config.yaml --dry-run

# Live run (applies changes)
python scripts/automated_bidding_strategy.py --config config.yaml

# Optimize specific campaign
python scripts/automated_bidding_strategy.py --config config.yaml --campaign-id 123456
```

### 3. Run BigQuery Analytics

Execute SQL queries for analysis:

```bash
# Using bq command-line tool
bq query --use_legacy_sql=false < sql_queries/comprehensive_marketing_analytics.sql

# Or use Python BigQuery client
python scripts/run_bigquery_query.py --query sql_queries/campaign_performance.sql
```

## Configuration

### Edit config.yaml

```yaml
# Google Ads Settings
google_ads:
  customer_id: "1234567890"
  developer_token: "YOUR_TOKEN"

# Bidding Strategy
bidding_strategy:
  daily_budget_usd: 15000.00
  roas_target: 3.5
  cpa_target: 12.50
  daily_bid_adjustment_percent: 5

# Budget Monitoring
budget_monitor:
  check_interval_minutes: 60
  alert_overspend_percent: 110

# Slack Notifications
slack:
  enabled: true
  webhook_url: "https://hooks.slack.com/..."
```

## Common Tasks

### Daily Optimization Workflow

```bash
# 1. Check budget status
python scripts/budget_monitor.py --config config.yaml --once

# 2. Run bidding optimization
python scripts/automated_bidding_strategy.py --config config.yaml

# 3. Generate performance report
python scripts/daily_optimization.py --config config.yaml
```

### Weekly Analysis

```bash
# Export data from BigQuery
bq extract \
  --destination_format CSV \
  gbt-datawarehouse-prod.marketing_analytics.campaign_metrics \
  gs://your-bucket/export-$(date +%Y%m%d).csv

# Analyze trends
python scripts/analyze_trends.py --output reports/weekly_$(date +%Y%m%d).csv
```

### Monthly Reporting

```bash
# Generate comprehensive monthly report
python scripts/generate_monthly_report.py --month $(date +%Y-%m) --output reports/

# Create dashboard snapshot
python scripts/dashboard_snapshot.py --looker-studio-url YOUR_DASHBOARD_URL
```

## Command Reference

### Budget Monitor

```bash
python scripts/budget_monitor.py [OPTIONS]

OPTIONS:
  --config CONFIG          Path to config file (default: config.yaml)
  --interval SECONDS       Check interval (default: 3600)
  --once                   Run once and exit
  --verbose               Verbose logging
```

### Automated Bidding Strategy

```bash
python scripts/automated_bidding_strategy.py [OPTIONS]

OPTIONS:
  --config CONFIG          Path to config file (default: config.yaml)
  --dry-run               Don't make actual changes
  --campaign-id ID         Optimize specific campaign
  --verbose               Verbose logging
  --output FILE           Save results to file
```

## Scheduling Scripts

### Using Cron (Linux/Mac)

```bash
# Edit crontab
crontab -e

# Add these lines:

# Run budget monitor every hour
0 * * * * cd /path/to/adtech-portfolio && python scripts/budget_monitor.py --config config.yaml --once

# Run bidding optimization daily at 6 AM
0 6 * * * cd /path/to/adtech-portfolio && python scripts/automated_bidding_strategy.py --config config.yaml

# Generate daily report at 8 AM
0 8 * * * cd /path/to/adtech-portfolio && python scripts/daily_optimization.py --config config.yaml
```

### Using Windows Task Scheduler

1. Open Task Scheduler
2. Create Basic Task
3. Set trigger (hourly, daily, etc.)
4. Set action: `python scripts/budget_monitor.py --config config.yaml --once`

### Using Cloud Scheduler (Google Cloud)

```bash
# Create Cloud Scheduler job
gcloud scheduler jobs create app-engine bidding-optimization \
  --schedule="0 6 * * *" \
  --http-method=POST \
  --uri=YOUR_APP_URL/run-bidding \
  --oidc-service-account-email=YOUR_SERVICE_ACCOUNT@PROJECT.iam.gserviceaccount.com
```

## Monitoring and Alerts

### Check Logs

```bash
# View recent logs
tail -f logs/adtech.log

# Filter by level
grep ERROR logs/adtech.log
grep WARNING logs/adtech.log

# Search specific script
grep automated_bidding logs/adtech.log
```

### Slack Notifications

The scripts automatically send Slack messages for:
- Budget overages (> 110% of daily budget)
- Underspending (< 50% of daily budget)
- Campaign optimizations
- Bid changes summary
- Errors and warnings

### Email Reports

Configure email notifications in `config.yaml`:

```yaml
email:
  enabled: true
  smtp_server: "smtp.gmail.com"
  from_email: "your-email@gmail.com"
  to_emails:
    - "recipient@example.com"
```

## SQL Query Examples

### Run Campaign Performance Query

```bash
bq query --use_legacy_sql=false <<'EOF'
SELECT 
  campaign_name,
  SUM(conversions) as conversions,
  SUM(revenue) as revenue,
  SUM(cost) as cost_usd,
  SUM(revenue) / SUM(cost) as roas
FROM `gbt-datawarehouse-prod.marketing_analytics.daily_metrics`
WHERE DATE(date) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY campaign_name
ORDER BY revenue DESC
EOF
```

### Export Results to CSV

```bash
bq query --format=csv --use_legacy_sql=false \
  "SELECT * FROM gbt-datawarehouse-prod.marketing_analytics.campaign_summary" \
  > campaign_summary.csv
```

## Troubleshooting

### Script Not Running

```bash
# Check Python installation
python --version

# Verify dependencies
pip list | grep google

# Test imports
python -c "from google.ads.googleads.client import GoogleAdsClient; print('OK')"
```

### Google Ads API Errors

```bash
# Enable debug logging
export GOOGLE_ADS_DEBUG=1
python scripts/automated_bidding_strategy.py --config config.yaml --verbose
```

### BigQuery Timeouts

- Reduce query complexity
- Add partition pruning with date filters
- Use _TABLE_SUFFIX for date filtering
- Check estimated bytes before running

### Slack Integration Issues

```bash
# Test webhook
curl -X POST -H 'Content-type: application/json' \
  --data '{"text":"Test message"}' \
  YOUR_WEBHOOK_URL
```

## Best Practices

1. **Always do a dry run first**
   ```bash
   python scripts/automated_bidding_strategy.py --dry-run
   ```

2. **Monitor logs continuously**
   ```bash
   tail -f logs/adtech.log
   ```

3. **Set up alerts for failures**
   - Configure Slack error notifications
   - Set up email alerts for critical errors

4. **Regular backups**
   ```bash
   # Backup campaign settings weekly
   python scripts/backup_campaigns.py
   ```

5. **Test in staging first**
   - Create test campaigns
   - Run scripts in dry-run mode
   - Verify results before going live

## Performance Tips

- Run budget monitor more frequently (hourly) for tight budgets
- Run bidding optimization once daily (early morning recommended)
- Use caching for BigQuery results to reduce API calls
- Batch API requests when possible

## Support

See `docs/TROUBLESHOOTING.md` for common issues and solutions.
