# AdTech Marketing Analytics Portfolio

A comprehensive, production-ready toolkit for Google Ads and marketing analytics automation. Includes real-time dashboards, advanced SQL analytics, Python automation scripts, and budget management tools.

## 📊 Project Overview

This portfolio contains:

- **Interactive Dashboards**: Looker Studio templates for budget pacing, campaign performance, and ROI analysis
- **SQL Analytics**: 50+ BigQuery queries for campaign analysis, attribution modeling, and forecasting
- **Python Automation**: Scripts for bid optimization, budget monitoring, and daily performance adjustments
- **Complete Documentation**: Setup guides, API references, and troubleshooting

## 🎯 Key Features

### 1. Real-Time Budget Pacing Dashboard
- Daily spend tracking vs. allocated budgets
- Campaign-level pace monitoring
- Automated alerts for overspend/underspend
- Budget rebalancing recommendations

### 2. Advanced SQL Analytics
- Campaign performance analysis
- Multi-touch attribution modeling
- Keyword performance benchmarking
- Budget forecasting and trend analysis
- Cohort retention and LTV analysis

### 3. Automated Bidding Strategy
- ROAS-based bid optimization
- Daily budget reallocation
- Performance-based campaign pausing
- Cost-per-acquisition (CPA) targets
- Automated reporting and alerts

### 4. Supporting Tools
- Budget monitoring with Slack integration
- Daily optimization reports
- Configuration management
- Error handling and logging

## 🚀 Quick Start

### Prerequisites
- Python 3.9+
- Google Ads API access (Developer Token)
- Google Cloud Project with BigQuery enabled
- OAuth 2.0 credentials

### Installation

1. Clone the repository:
```bash
git clone https://github.com/VimeshikaShri/adtech-portfolio.git
cd adtech-portfolio
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Set up credentials:
```bash
cp config.example.yaml config.yaml
# Edit config.yaml with your credentials
```

4. Run initial setup:
```bash
python scripts/setup.py
```

## 📁 Project Structure

```
adtech-portfolio/
├── dashboards/
│   ├── looker_studio_template.json
│   ├── dashboard_setup_guide.md
│   └── sample_metrics.csv
├── sql_queries/
│   ├── campaign_performance.sql
│   ├── keyword_analysis.sql
│   ├── attribution_model.sql
│   ├── budget_forecasting.sql
│   ├── cohort_analysis.sql
│   └── custom_metrics.sql
├── scripts/
│   ├── automated_bidding_strategy.py
│   ├── budget_monitor.py
│   ├── daily_optimization.py
│   ├── utils.py
│   └── setup.py
├── configs/
│   ├── google_ads_config.yaml
│   └── bigquery_config.yaml
├── docs/
│   ├── INSTALLATION.md
│   ├── USAGE.md
│   ├── API_REFERENCE.md
│   └── TROUBLESHOOTING.md
├── tests/
│   └── test_bidding_strategy.py
├── .gitignore
├── requirements.txt
├── config.example.yaml
└── LICENSE
```

## 🔧 Configuration

Edit `config.yaml` with your credentials:

```yaml
google_ads:
  developer_token: "YOUR_DEVELOPER_TOKEN"
  client_id: "YOUR_CLIENT_ID"
  client_secret: "YOUR_CLIENT_SECRET"
  refresh_token: "YOUR_REFRESH_TOKEN"
  customer_id: "1234567890"

bigquery:
  project_id: "gbt-datawarehouse-prod"
  dataset_id: "marketing_analytics"
  location: "US"

bidding_strategy:
  daily_budget_usd: 15000
  roas_target: 3.5
  cpa_target: 12.50
  min_bid_micros: 100000
  max_bid_micros: 5000000

slack:
  webhook_url: "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
  alert_channel: "#marketing-alerts"
```

## 📊 Dashboards

### Budget Pacing Dashboard
Real-time monitoring of daily spend vs. budget allocation:
- Campaign-level pace tracking
- Automated over/under spend alerts
- Budget rebalancing recommendations
- Historical spend trends

**Setup**: Import `dashboards/looker_studio_template.json` into Looker Studio

### Performance Dashboard
Campaign and keyword performance metrics:
- ROAS by campaign and keyword
- Cost per conversion trends
- Click-through rate (CTR) analysis
- Impression share tracking

### Attribution Dashboard
Multi-touch attribution analysis:
- First-click, last-click, and linear attribution
- Customer journey visualization
- Top-performing touchpoints
- Channel performance comparison

## 🐍 Python Scripts

### Automated Bidding Strategy
Runs daily to optimize bids based on ROAS targets:

```bash
python scripts/automated_bidding_strategy.py --config config.yaml --dry-run
```

Features:
- ROAS-based bid optimization
- Daily budget reallocation
- Campaign performance pausing
- CPA target enforcement

### Budget Monitor
Real-time budget tracking with Slack alerts:

```bash
python scripts/budget_monitor.py --config config.yaml --interval 3600
```

### Daily Optimization
Automated daily performance adjustments:

```bash
python scripts/daily_optimization.py --config config.yaml
```

## 📈 SQL Queries

### Campaign Performance Analysis
Find top/bottom performing campaigns:
```sql
-- See sql_queries/campaign_performance.sql
SELECT campaign_name, impressions, clicks, cost, conversions, roas
FROM campaign_metrics
ORDER BY roas DESC
```

### Attribution Modeling
Multi-touch attribution analysis:
```sql
-- See sql_queries/attribution_model.sql
WITH attribution AS (
  SELECT user_id, touchpoint, revenue
  FROM events
)
SELECT touchpoint, SUM(revenue) as attributed_revenue
FROM attribution
GROUP BY touchpoint
```

### Budget Forecasting
Predict spend and ROI:
```sql
-- See sql_queries/budget_forecasting.sql
SELECT 
  DATE_TRUNC(event_date, MONTH) as month,
  SUM(cost) as projected_spend,
  SUM(revenue) / SUM(cost) as projected_roas
FROM daily_metrics
GROUP BY month
```

## 🔐 Security

- Store credentials in `config.yaml` (never commit to git)
- Use OAuth 2.0 refresh tokens for authentication
- Rotate API keys regularly
- Use `.gitignore` to exclude sensitive files
- Implement rate limiting for API calls

## 📝 Documentation

- [Installation Guide](docs/INSTALLATION.md)
- [Usage Documentation](docs/USAGE.md)
- [API Reference](docs/API_REFERENCE.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Add tests for new features
4. Submit a pull request

## 📄 License

MIT License - See LICENSE file for details

## 🆘 Support

For issues, questions, or suggestions:
- Open an issue on GitHub
- Check the Troubleshooting guide
- Review API documentation

## 🔄 Updates

This portfolio is actively maintained. Check back for:
- New dashboard templates
- Additional SQL queries
- Enhanced bidding strategies
- Integration with new platforms

## ⭐ Credits

Built for marketers and advertisers who need powerful analytics and automation without the enterprise price tag.

---

**Last Updated**: January 2025
**Python Version**: 3.9+
**Status**: Production Ready
