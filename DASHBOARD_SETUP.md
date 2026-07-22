# Looker Studio Dashboard Setup Guide

## Overview

This guide helps you set up professional marketing dashboards in Looker Studio for real-time monitoring of Google Ads and GA4 performance.

## Prerequisites

- Google Account
- Access to Looker Studio (free)
- Google Analytics 4 property or Google Ads account linked to BigQuery
- BigQuery dataset with marketing data

## Dashboard 1: Budget Pacing Dashboard

### Purpose
Real-time monitoring of daily spend vs. allocated budgets with alerts and forecasting.

### Setup Steps

1. **Create New Report**
   - Go to [Looker Studio](https://lookerstudio.google.com)
   - Click "Create" → "Report"
   - Name: "Budget Pacing Dashboard"

2. **Add Data Source**
   - Click "Create new data source"
   - Select "BigQuery"
   - Project: `gbt-datawarehouse-prod`
   - Dataset: `marketing_analytics`
   - Table: `daily_metrics`

3. **Add Scorecard Widget**
   - Add → Scorecard
   - Metric: `SUM(cost_micros) / 1000000`
   - Name: "Total Spend Today"
   - Filter: `DATE(date) = TODAY()`

4. **Add Budget Pace Gauge**
   - Add → Gauge
   - Value: `SUM(cost_micros) / 1000000 / 15000 * 100`
   - Min: 0, Max: 200
   - Title: "Budget Pace %"

5. **Add Daily Spend Line Chart**
   - Add → Time Series
   - Dimension: `date`
   - Metric: `SUM(cost_micros) / 1000000`
   - Group by: `date`

6. **Add Campaign Table**
   - Add → Table
   - Dimensions: `campaign_name`
   - Metrics: `SUM(cost_micros) / 1000000`, `SUM(conversions)`, `SUM(revenue)`

### Sample SQL Query for Data Source

```sql
SELECT
  DATE(event_timestamp) as date,
  campaign_name,
  SUM(cost_micros) as cost_micros,
  SUM(CASE WHEN event_name = 'purchase' THEN 1 ELSE 0 END) as conversions,
  SUM(CAST(JSON_EXTRACT_SCALAR(event_params, '$.value') AS FLOAT64)) as revenue
FROM `gbt-datawarehouse-prod.analytics_events.events_*`
WHERE _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', CURRENT_DATE() - 30)
GROUP BY date, campaign_name
```

## Dashboard 2: Campaign Performance Dashboard

### Purpose
Deep analysis of campaign-level metrics, ROAS, and efficiency.

### Key Components

1. **Campaign KPI Cards**
   - Total Revenue
   - Total Spend
   - Total Conversions
   - Blended ROAS

2. **Campaign Comparison Table**
   - Campaign Name
   - Impressions
   - Clicks
   - CTR
   - Conversions
   - Conversion Rate
   - Cost/Conversion
   - ROAS

3. **Performance Trends**
   - Line chart: ROAS over time
   - Line chart: CPA over time
   - Line chart: Revenue vs. Spend

4. **Top/Bottom Campaigns**
   - Bar chart: Top 10 by ROAS
   - Bar chart: Bottom 10 by ROAS

### Setup Query

```sql
SELECT
  DATE(event_timestamp) as date,
  campaign_name,
  SUM(CASE WHEN event_name = 'page_view' THEN 1 ELSE 0 END) as impressions,
  SUM(CASE WHEN event_name = 'click' THEN 1 ELSE 0 END) as clicks,
  SUM(CASE WHEN event_name = 'purchase' THEN 1 ELSE 0 END) as conversions,
  SUM(cost_micros) / 1e6 as cost_usd,
  SUM(CAST(JSON_EXTRACT_SCALAR(event_params, '$.value') AS FLOAT64)) as revenue
FROM `gbt-datawarehouse-prod.analytics_events.events_*`
WHERE _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', CURRENT_DATE() - 30)
GROUP BY date, campaign_name
```

## Dashboard 3: Attribution & Journey Dashboard

### Purpose
Understand customer journey and attribution across channels.

### Components

1. **Multi-Touch Attribution**
   - Table showing attributed revenue by channel
   - Stacked bar chart: Attribution by source/medium

2. **Top Journey Paths**
   - List of most common customer paths
   - Conversion rate per path

3. **Channel Performance**
   - Bar chart: Revenue by source
   - Line chart: Channel trends

4. **Funnel Visualization**
   - Impression → Click → Lead → Purchase

## Dashboard 4: Keyword Performance Dashboard

### Purpose
Keyword-level analysis for SEM optimization.

### Components

1. **Top Keywords by ROAS**
   - Table: Keyword, Impressions, Clicks, ROAS

2. **Keywords Below Threshold**
   - Table: Keywords needing optimization
   - CPA, ROAS, Status

3. **Bid Opportunity Analysis**
   - Chart: Current vs. Recommended Bids

4. **Keyword Trends**
   - Line chart: Top 5 keywords ROAS trend

## Best Practices

### 1. Refresh Rate
- Set data source to refresh every 4 hours
- Critical metrics: 1-hour refresh

### 2. Filters
- Add date range filter (default: last 30 days)
- Add campaign filter for drill-down

### 3. Alerts
- Set up Looker Studio alerts for:
  - ROAS drops below 2.0x
  - Budget pace exceeds 120%
  - CPA exceeds target by 25%

### 4. Access Control
- Share with team members (view-only)
- Restrict edit access to admins

### 5. Styling
- Use consistent color scheme
- Brand colors: Primary (Blue), Secondary (Green)
- Use red for negative metrics, green for positive

## Connecting to BigQuery

### Step 1: Enable BigQuery Integration
1. In Looker Studio, click "Create new data source"
2. Select "BigQuery"
3. Grant permissions when prompted

### Step 2: Query Builder vs. SQL
- **Query Builder**: For simple queries, drag-and-drop
- **Custom Query**: For complex calculations and multiple tables

### Step 3: Create Calculated Fields
Example: Calculate ROAS
```
SUM(revenue) / (SUM(cost_micros) / 1000000)
```

## Troubleshooting

### Data Not Showing
- Check BigQuery table exists
- Verify data is being exported daily
- Check date filters

### Slow Dashboard
- Reduce date range
- Aggregate data at table level
- Use sampling for large datasets

### Permission Issues
- Ensure BigQuery project is linked
- Check service account permissions
- Verify data source is shared

## Advanced Features

### 1. Custom Metrics
Create calculated fields for common metrics:
- Cost Per Conversion: `SUM(cost) / SUM(conversions)`
- CTR: `SUM(clicks) / SUM(impressions) * 100`
- Conversion Rate: `SUM(conversions) / SUM(clicks) * 100`

### 2. Parameter Filters
Add parameters for:
- Dynamic ROAS targets
- Budget thresholds
- Date ranges

### 3. Scorecard Formatting
- Green background if ROAS > 3.0
- Yellow background if ROAS 2.0-3.0
- Red background if ROAS < 2.0

### 4. Scheduled Reports
- Schedule daily email reports
- Include key KPIs in email
- Add insights and recommendations

## Sample Dashboard URLs

Once created, share these links with your team:
- Production: [Your Dashboard URL]
- Test: [Your Test Dashboard URL]

## Support

- Looker Studio Help: https://support.google.com/looker-studio
- BigQuery Documentation: https://cloud.google.com/bigquery/docs
- Google Ads API: https://developers.google.com/google-ads/api
