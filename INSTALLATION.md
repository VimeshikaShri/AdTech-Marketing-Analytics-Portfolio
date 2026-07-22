# Installation Guide

## Prerequisites

- Python 3.9 or higher
- Google Ads API access (Developer Token)
- Google Cloud Project with BigQuery enabled
- OAuth 2.0 credentials for Google Ads
- (Optional) Slack workspace for notifications

## Step 1: Clone the Repository

```bash
git clone https://github.com/VimeshikaShri/adtech-portfolio.git
cd adtech-portfolio
```

## Step 2: Create Virtual Environment

```bash
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

## Step 3: Install Dependencies

```bash
pip install -r requirements.txt
```

## Step 4: Set Up Google Ads Credentials

### Option A: Using OAuth 2.0 (Recommended)

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the Google Ads API
4. Create an OAuth 2.0 Client ID (Desktop Application)
5. Download the credentials JSON file

### Option B: Using Service Account

1. Create a service account in Google Cloud Console
2. Generate and download the service account key (JSON)
3. Share your Google Ads account with the service account email

## Step 5: Configure Credentials

1. Create `google-ads.yaml` file:

```bash
cp google-ads.yaml.example google-ads.yaml
```

2. Edit with your credentials:

```yaml
developer_token: "YOUR_DEVELOPER_TOKEN"
client_id: "YOUR_CLIENT_ID.apps.googleusercontent.com"
client_secret: "YOUR_CLIENT_SECRET"
refresh_token: "YOUR_REFRESH_TOKEN"
use_proto_plus: True
```

### Getting OAuth 2.0 Refresh Token

1. Use Google's OAuth 2.0 Playground: https://developers.google.com/oauthplayground
2. Or run the provided authentication script:

```bash
python scripts/authenticate.py
```

## Step 6: Configure Application Settings

1. Copy example config:

```bash
cp config.example.yaml config.yaml
```

2. Edit `config.yaml` with your settings:
   - Google Ads customer ID
   - BigQuery project and dataset
   - Bidding strategy parameters
   - Slack webhook URL (optional)

## Step 7: Set Up BigQuery (Optional)

For advanced analytics and SQL queries:

1. Create a BigQuery dataset in your Google Cloud Project
2. Set up linked Google Ads and GA4 exports
3. Update `config.yaml` with your dataset information

### Create BigQuery Tables

Link your Google Ads account:

```bash
# In Google Cloud Console
1. Go to BigQuery
2. Create dataset: 'marketing_analytics'
3. Link Google Ads account via Data Transfer Service
4. Select 'Google Ads' as source
5. Choose daily export to BigQuery
```

## Step 8: Set Up Slack Integration (Optional)

1. Create a Slack App in your workspace
2. Enable Incoming Webhooks
3. Create a webhook for your channel
4. Copy webhook URL to `config.yaml`:

```yaml
slack:
  enabled: true
  webhook_url: "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
  alert_channel: "#marketing-alerts"
```

## Step 9: Verify Installation

Test the setup:

```bash
# Test Google Ads API connection
python -c "from google.ads.googleads.client import GoogleAdsClient; print('Google Ads API: OK')"

# Test BigQuery connection
python -c "from google.cloud import bigquery; print('BigQuery: OK')"

# Test configuration
python scripts/automated_bidding_strategy.py --config config.yaml --dry-run
```

## Step 10: Create Logs Directory

```bash
mkdir -p logs
```

## Troubleshooting

### "Developer token not set"
- Verify `google-ads.yaml` file exists and contains your developer token
- Check token is enabled in Google Ads account

### "Refresh token invalid"
- Re-authenticate using the OAuth 2.0 process
- Ensure refresh token hasn't expired

### BigQuery Connection Issues
- Verify Google Cloud Project ID in `config.yaml`
- Check service account has BigQuery permissions
- Ensure BigQuery API is enabled

### Slack Webhook Errors
- Verify webhook URL is correct
- Test webhook with curl:
  ```bash
  curl -X POST -H 'Content-type: application/json' \
    --data '{"text":"Test"}' \
    https://hooks.slack.com/services/YOUR/WEBHOOK/URL
  ```

## Next Steps

1. Review `USAGE.md` for running scripts
2. Check `docs/API_REFERENCE.md` for available functions
3. Explore SQL queries in `sql_queries/` directory
4. Configure your first automation campaign

## Support

For issues or questions:
- Check `docs/TROUBLESHOOTING.md`
- Review error logs in `logs/` directory
- Open an issue on GitHub
