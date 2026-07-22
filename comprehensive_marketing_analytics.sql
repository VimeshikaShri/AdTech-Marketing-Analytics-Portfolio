-- ================================================================
-- AdTech Portfolio: Comprehensive BigQuery Marketing Analytics Queries
-- ================================================================

-- ================================================================
-- 1. CAMPAIGN PERFORMANCE ANALYSIS
-- ================================================================

-- Daily Campaign Performance Summary
SELECT 
  DATE(event_timestamp) as date,
  campaign_name,
  campaign_id,
  COUNT(DISTINCT user_id) as unique_users,
  COUNT(DISTINCT session_id) as sessions,
  SUM(CASE WHEN event_name = 'page_view' THEN 1 ELSE 0 END) as page_views,
  SUM(CASE WHEN event_name = 'click' THEN 1 ELSE 0 END) as clicks,
  SUM(CASE WHEN event_name = 'purchase' THEN 1 ELSE 0 END) as conversions,
  SUM(CAST(JSON_EXTRACT_SCALAR(event_params, '$.value') AS FLOAT64)) as revenue,
  SAFE_DIVIDE(SUM(CASE WHEN event_name = 'purchase' THEN 1 ELSE 0 END), 
    COUNT(DISTINCT user_id)) * 100 as conversion_rate_percent,
  SAFE_DIVIDE(SUM(CAST(JSON_EXTRACT_SCALAR(event_params, '$.value') AS FLOAT64)), 
    SUM(CASE WHEN event_name = 'click' THEN 1 ELSE 0 END)) as avg_order_value
FROM `gbt-datawarehouse-prod.analytics_events.events_*`
WHERE _TABLE_SUFFIX = FORMAT_DATE('%Y%m%d', CURRENT_DATE() - 1)
  AND campaign_name IS NOT NULL
GROUP BY date, campaign_name, campaign_id
ORDER BY revenue DESC;

-- Campaign Performance Over Time (30-day rolling average)
SELECT 
  DATE(event_timestamp) as date,
  campaign_name,
  SUM(CASE WHEN event_name = 'purchase' THEN 1 ELSE 0 END) as conversions,
  SUM(CAST(JSON_EXTRACT_SCALAR(event_params, '$.value') AS FLOAT64)) as revenue,
  AVG(SUM(CASE WHEN event_name = 'purchase' THEN 1 ELSE 0 END)) 
    OVER (PARTITION BY campaign_name ORDER BY TIMESTAMP(CONCAT(DATE(event_timestamp), ' 00:00:00')) 
    ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as rolling_30d_conversions,
  AVG(SUM(CAST(JSON_EXTRACT_SCALAR(event_params, '$.value') AS FLOAT64))) 
    OVER (PARTITION BY campaign_name ORDER BY TIMESTAMP(CONCAT(DATE(event_timestamp), ' 00:00:00')) 
    ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as rolling_30d_revenue
FROM `gbt-datawarehouse-prod.analytics_events.events_*`
WHERE _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', CURRENT_DATE() - 90)
  AND campaign_name IS NOT NULL
GROUP BY date, campaign_name
ORDER BY date DESC, campaign_name;

-- Campaign Budget Efficiency Analysis
SELECT 
  campaign_name,
  campaign_id,
  SUM(cost_micros) / 1e6 as total_cost_usd,
  SUM(CASE WHEN event_name = 'purchase' THEN 1 ELSE 0 END) as conversions,
  SUM(CASE WHEN event_name = 'click' THEN 1 ELSE 0 END) as clicks,
  SAFE_DIVIDE(SUM(cost_micros) / 1e6, SUM(CASE WHEN event_name = 'purchase' THEN 1 ELSE 0 END)) as cost_per_conversion,
  SAFE_DIVIDE(SUM(cost_micros) / 1e6, SUM(CASE WHEN event_name = 'click' THEN 1 ELSE 0 END)) as cost_per_click,
  SAFE_DIVIDE(SUM(CAST(JSON_EXTRACT_SCALAR(event_params, '$.value') AS FLOAT64)), 
    SUM(cost_micros) / 1e6) as roas,
  RANK() OVER (ORDER BY SAFE_DIVIDE(SUM(CAST(JSON_EXTRACT_SCALAR(event_params, '$.value') AS FLOAT64)), 
    SUM(cost_micros) / 1e6) DESC) as roas_rank
FROM `gbt-datawarehouse-prod.analytics_events.events_*`
WHERE _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', CURRENT_DATE() - 30)
GROUP BY campaign_name, campaign_id
HAVING SUM(cost_micros) / 1e6 > 100  -- Only campaigns with >$100 spend
ORDER BY roas DESC;

-- ================================================================
-- 2. KEYWORD PERFORMANCE ANALYSIS
-- ================================================================

-- Top Performing Keywords (Last 30 Days)
SELECT 
  keyword,
  keyword_id,
  ad_group,
  campaign_name,
  SUM(impressions) as impressions,
  SUM(clicks) as clicks,
  SUM(conversions) as conversions,
  SUM(cost_micros) / 1e6 as cost_usd,
  SAFE_DIVIDE(SUM(clicks), SUM(impressions)) * 100 as ctr_percent,
  SAFE_DIVIDE(SUM(cost_micros) / 1e6, SUM(clicks)) as cost_per_click,
  SAFE_DIVIDE(SUM(conversions), SUM(clicks)) * 100 as conversion_rate,
  SAFE_DIVIDE(SUM(cost_micros) / 1e6, SUM(conversions)) as cost_per_conversion,
  SAFE_DIVIDE(SUM(revenue), SUM(cost_micros) / 1e6) as roas,
  ROW_NUMBER() OVER (PARTITION BY ad_group ORDER BY SUM(revenue) DESC) as rank_in_adgroup
FROM `gbt-datawarehouse-prod.google_ads.keyword_performance_daily_*`
WHERE _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', CURRENT_DATE() - 30)
GROUP BY keyword, keyword_id, ad_group, campaign_name
HAVING SUM(impressions) > 50  -- Only keywords with >50 impressions
ORDER BY roas DESC;

-- Keywords Below Performance Threshold (Candidates for Pause/Reduce)
SELECT 
  keyword,
  ad_group,
  campaign_name,
  SUM(cost_micros) / 1e6 as total_spend,
  SUM(clicks) as total_clicks,
  SUM(conversions) as total_conversions,
  SAFE_DIVIDE(SUM(conversions), SUM(clicks)) * 100 as conversion_rate,
  CASE 
    WHEN SUM(conversions) = 0 THEN 'No conversions'
    WHEN SAFE_DIVIDE(SUM(cost_micros) / 1e6, SUM(conversions)) > 25 THEN 'High CPA'
    WHEN SAFE_DIVIDE(SUM(clicks), SUM(impressions)) * 100 < 1 THEN 'Low CTR'
    ELSE 'Other'
  END as issue_type,
  CASE 
    WHEN SUM(conversions) = 0 AND SUM(cost_micros) / 1e6 > 100 THEN 'PAUSE'
    WHEN SAFE_DIVIDE(SUM(cost_micros) / 1e6, SUM(conversions)) > 30 THEN 'REDUCE_BID'
    ELSE 'MONITOR'
  END as recommendation
FROM `gbt-datawarehouse-prod.google_ads.keyword_performance_daily_*`
WHERE _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', CURRENT_DATE() - 30)
GROUP BY keyword, ad_group, campaign_name
HAVING SUM(impressions) > 20
ORDER BY total_spend DESC;

-- Keyword Bid Opportunity Analysis
SELECT 
  keyword,
  current_bid_micros / 1e6 as current_bid,
  SUM(conversions) as conversions,
  SAFE_DIVIDE(SUM(cost_micros) / 1e6, SUM(conversions)) as current_cpa,
  12.50 as cpa_target,
  CASE 
    WHEN SAFE_DIVIDE(SUM(cost_micros) / 1e6, SUM(conversions)) < 12.50 
      THEN ROUND(current_bid_micros / 1e6 * 1.15, 2)
    WHEN SAFE_DIVIDE(SUM(cost_micros) / 1e6, SUM(conversions)) > 12.50 
      THEN ROUND(current_bid_micros / 1e6 * 0.85, 2)
    ELSE current_bid_micros / 1e6
  END as recommended_bid,
  CASE 
    WHEN SAFE_DIVIDE(SUM(cost_micros) / 1e6, SUM(conversions)) < 12.50 THEN 'INCREASE'
    WHEN SAFE_DIVIDE(SUM(cost_micros) / 1e6, SUM(conversions)) > 12.50 THEN 'DECREASE'
    ELSE 'MAINTAIN'
  END as bid_action
FROM `gbt-datawarehouse-prod.google_ads.keyword_performance_daily_*`
WHERE _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', CURRENT_DATE() - 30)
GROUP BY keyword, current_bid_micros
HAVING SUM(conversions) > 10
ORDER BY conversions DESC;

-- ================================================================
-- 3. ATTRIBUTION AND CUSTOMER JOURNEY ANALYSIS
-- ================================================================

-- Multi-Touch Attribution (Last Non-Direct Click)
WITH user_touchpoints AS (
  SELECT 
    user_id,
    session_id,
    event_timestamp,
    event_name,
    source,
    medium,
    campaign_name,
    keyword,
    ROW_NUMBER() OVER (PARTITION BY user_id, session_id ORDER BY event_timestamp DESC) as touch_order,
    LEAD(event_name) OVER (PARTITION BY user_id, session_id ORDER BY event_timestamp) as next_event
  FROM `gbt-datawarehouse-prod.analytics_events.events_*`
  WHERE _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', CURRENT_DATE() - 90)
),
last_non_direct_click AS (
  SELECT 
    user_id,
    session_id,
    source,
    medium,
    campaign_name,
    SUM(CASE WHEN event_name = 'purchase' THEN 1 ELSE 0 END) as conversions,
    SUM(CAST(JSON_EXTRACT_SCALAR(event_params, '$.value') AS FLOAT64)) as revenue
  FROM user_touchpoints
  WHERE touch_order = 1 
    AND medium != 'direct'
    AND next_event = 'purchase'
  GROUP BY user_id, session_id, source, medium, campaign_name
)
SELECT 
  source,
  medium,
  campaign_name,
  COUNT(DISTINCT user_id) as attributed_conversions,
  SUM(conversions) as total_conversions,
  SUM(revenue) as attributed_revenue,
  RANK() OVER (ORDER BY SUM(revenue) DESC) as revenue_rank
FROM last_non_direct_click
GROUP BY source, medium, campaign_name
ORDER BY attributed_revenue DESC;

-- First-Touch Attribution Analysis
WITH first_touch AS (
  SELECT 
    user_id,
    MIN(event_timestamp) as first_interaction,
    FIRST_VALUE(source) OVER (PARTITION BY user_id ORDER BY event_timestamp) as first_source,
    FIRST_VALUE(medium) OVER (PARTITION BY user_id ORDER BY event_timestamp) as first_medium,
    FIRST_VALUE(campaign_name) OVER (PARTITION BY user_id ORDER BY event_timestamp) as first_campaign
  FROM `gbt-datawarehouse-prod.analytics_events.events_*`
  WHERE _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', CURRENT_DATE() - 90)
  GROUP BY user_id
),
conversions AS (
  SELECT 
    user_id,
    SUM(CASE WHEN event_name = 'purchase' THEN 1 ELSE 0 END) as conversions,
    SUM(CAST(JSON_EXTRACT_SCALAR(event_params, '$.value') AS FLOAT64)) as revenue
  FROM `gbt-datawarehouse-prod.analytics_events.events_*`
  WHERE _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', CURRENT_DATE() - 90)
    AND event_name = 'purchase'
  GROUP BY user_id
)
SELECT 
  ft.first_source,
  ft.first_medium,
  ft.first_campaign,
  COUNT(DISTINCT ft.user_id) as users_acquired,
  SUM(c.conversions) as total_conversions,
  SUM(c.revenue) as attributed_revenue,
  SAFE_DIVIDE(SUM(c.revenue), COUNT(DISTINCT ft.user_id)) as ltv
FROM first_touch ft
LEFT JOIN conversions c ON ft.user_id = c.user_id
GROUP BY first_source, first_medium, first_campaign
ORDER BY attributed_revenue DESC;

-- Customer Journey Path Analysis (Top 20 Paths)
WITH journey_path AS (
  SELECT 
    user_id,
    STRING_AGG(DISTINCT source || '>' || medium, ' > ' ORDER BY event_timestamp) as journey_path,
    MAX(CASE WHEN event_name = 'purchase' THEN 1 ELSE 0 END) as is_converter,
    MAX(CAST(JSON_EXTRACT_SCALAR(event_params, '$.value') AS FLOAT64)) as revenue
  FROM `gbt-datawarehouse-prod.analytics_events.events_*`
  WHERE _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', CURRENT_DATE() - 90)
  GROUP BY user_id
)
SELECT 
  journey_path,
  COUNT(*) as user_count,
  SUM(is_converter) as converters,
  SAFE_DIVIDE(SUM(is_converter), COUNT(*)) * 100 as conversion_rate,
  SUM(revenue) as total_revenue,
  SAFE_DIVIDE(SUM(revenue), SUM(is_converter)) as avg_value_per_converter
FROM journey_path
WHERE journey_path IS NOT NULL
GROUP BY journey_path
ORDER BY user_count DESC
LIMIT 20;

-- ================================================================
-- 4. BUDGET FORECASTING AND TRENDS
-- ================================================================

-- Monthly Budget Forecast (Trend Analysis)
SELECT 
  EXTRACT(YEAR FROM DATE(event_timestamp)) as year,
  EXTRACT(MONTH FROM DATE(event_timestamp)) as month,
  campaign_name,
  SUM(cost_micros) / 1e6 as monthly_spend,
  SUM(CASE WHEN event_name = 'purchase' THEN 1 ELSE 0 END) as conversions,
  SUM(CAST(JSON_EXTRACT_SCALAR(event_params, '$.value') AS FLOAT64)) as revenue,
  SAFE_DIVIDE(SUM(CAST(JSON_EXTRACT_SCALAR(event_params, '$.value') AS FLOAT64)), 
    SUM(cost_micros) / 1e6) as roas,
  AVG(SUM(cost_micros) / 1e6) OVER (
    PARTITION BY campaign_name ORDER BY EXTRACT(YEAR FROM DATE(event_timestamp)), 
    EXTRACT(MONTH FROM DATE(event_timestamp)) 
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
  ) as moving_avg_spend
FROM `gbt-datawarehouse-prod.analytics_events.events_*`
WHERE _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', CURRENT_DATE() - 365)
GROUP BY year, month, campaign_name
ORDER BY year DESC, month DESC, campaign_name;

-- Daily Spend Forecast (Next 7 Days)
WITH daily_metrics AS (
  SELECT 
    DATE(event_timestamp) as date,
    campaign_name,
    SUM(cost_micros) / 1e6 as daily_spend,
    SUM(CASE WHEN event_name = 'purchase' THEN 1 ELSE 0 END) as conversions,
    SUM(CAST(JSON_EXTRACT_SCALAR(event_params, '$.value') AS FLOAT64)) as revenue
  FROM `gbt-datawarehouse-prod.analytics_events.events_*`
  WHERE _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', CURRENT_DATE() - 30)
  GROUP BY date, campaign_name
),
trend_analysis AS (
  SELECT 
    campaign_name,
    AVG(daily_spend) as avg_daily_spend,
    STDDEV(daily_spend) as spend_stddev,
    AVG(CASE WHEN conversions > 0 THEN conversions ELSE NULL END) as avg_conversions,
    AVG(revenue) as avg_daily_revenue
  FROM daily_metrics
  GROUP BY campaign_name
)
SELECT 
  campaign_name,
  CURRENT_DATE() + INTERVAL 1 DAY as forecast_date,
  ROUND(avg_daily_spend * 1.05, 2) as forecasted_spend,  -- 5% growth assumption
  ROUND(avg_daily_revenue * 1.05, 2) as forecasted_revenue,
  ROUND(avg_conversions, 0) as forecasted_conversions
FROM trend_analysis
ORDER BY forecasted_spend DESC;

-- ROI Projection (90-Day Outlook)
SELECT 
  campaign_name,
  SUM(cost_micros) / 1e6 as ytd_spend,
  SUM(CASE WHEN event_name = 'purchase' THEN 1 ELSE 0 END) as ytd_conversions,
  SUM(CAST(JSON_EXTRACT_SCALAR(event_params, '$.value') AS FLOAT64)) as ytd_revenue,
  SAFE_DIVIDE(SUM(CAST(JSON_EXTRACT_SCALAR(event_params, '$.value') AS FLOAT64)), 
    SUM(cost_micros) / 1e6) as ytd_roas,
  -- Project next 90 days at current pace
  SAFE_DIVIDE(SUM(CAST(JSON_EXTRACT_SCALAR(event_params, '$.value') AS FLOAT64)), 
    SUM(cost_micros) / 1e6) * 15000 as projected_90d_revenue,
  15000 as projected_90d_spend
FROM `gbt-datawarehouse-prod.analytics_events.events_*`
WHERE _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', CURRENT_DATE() - 90)
GROUP BY campaign_name
ORDER BY ytd_revenue DESC;

-- ================================================================
-- 5. COHORT ANALYSIS AND RETENTION
-- ================================================================

-- User Cohort Retention (Weekly Cohorts)
WITH first_visit AS (
  SELECT 
    user_id,
    DATE_TRUNC(DATE(MIN(event_timestamp)), WEEK) as cohort_week,
    DATE(MIN(event_timestamp)) as first_visit_date
  FROM `gbt-datawarehouse-prod.analytics_events.events_*`
  WHERE _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', CURRENT_DATE() - 180)
  GROUP BY user_id
),
user_activity AS (
  SELECT 
    user_id,
    DATE_TRUNC(DATE(event_timestamp), WEEK) as activity_week,
    COUNT(DISTINCT DATE(event_timestamp)) as days_active
  FROM `gbt-datawarehouse-prod.analytics_events.events_*`
  WHERE _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', CURRENT_DATE() - 180)
  GROUP BY user_id, activity_week
)
SELECT 
  fv.cohort_week,
  DATE_DIFF(ua.activity_week, fv.cohort_week, WEEK) as weeks_since_cohort,
  COUNT(DISTINCT ua.user_id) as active_users,
  ROUND(COUNT(DISTINCT ua.user_id) / 
    COUNT(DISTINCT fv.user_id) OVER (PARTITION BY fv.cohort_week) * 100, 2) as retention_rate
FROM first_visit fv
LEFT JOIN user_activity ua ON fv.user_id = ua.user_id AND ua.activity_week >= fv.cohort_week
GROUP BY fv.cohort_week, weeks_since_cohort
ORDER BY fv.cohort_week DESC, weeks_since_cohort;

-- Cohort LTV (Lifetime Value by Acquisition Cohort)
WITH acquisition_cohort AS (
  SELECT 
    user_id,
    DATE_TRUNC(DATE(MIN(event_timestamp)), MONTH) as cohort_month,
    MIN(source) as acquisition_source,
    MIN(campaign_name) as acquisition_campaign
  FROM `gbt-datawarehouse-prod.analytics_events.events_*`
  WHERE _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', CURRENT_DATE() - 180)
  GROUP BY user_id
),
user_lifetime_value AS (
  SELECT 
    user_id,
    SUM(CAST(JSON_EXTRACT_SCALAR(event_params, '$.value') AS FLOAT64)) as lifetime_value,
    COUNT(DISTINCT DATE(event_timestamp)) as days_active,
    COUNT(CASE WHEN event_name = 'purchase' THEN 1 END) as purchase_count
  FROM `gbt-datawarehouse-prod.analytics_events.events_*`
  WHERE _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', CURRENT_DATE() - 180)
  GROUP BY user_id
)
SELECT 
  ac.cohort_month,
  ac.acquisition_source,
  ac.acquisition_campaign,
  COUNT(DISTINCT ac.user_id) as cohort_size,
  ROUND(AVG(ulv.lifetime_value), 2) as avg_ltv,
  ROUND(PERCENTILE_CONT(ulv.lifetime_value, 0.5) OVER (
    PARTITION BY ac.cohort_month, ac.acquisition_source
  ), 2) as median_ltv,
  ROUND(MAX(ulv.lifetime_value) OVER (
    PARTITION BY ac.cohort_month, ac.acquisition_source
  ), 2) as max_ltv,
  ROUND(AVG(ulv.purchase_count), 2) as avg_purchases
FROM acquisition_cohort ac
LEFT JOIN user_lifetime_value ulv ON ac.user_id = ulv.user_id
GROUP BY ac.cohort_month, ac.acquisition_source, ac.acquisition_campaign
ORDER BY ac.cohort_month DESC;

-- ================================================================
-- 6. CUSTOM METRICS AND KPIs
-- ================================================================

-- Blended ROAS Calculation (Multi-Channel)
SELECT 
  DATE(event_timestamp) as date,
  SUM(cost_micros) / 1e6 as total_spend,
  SUM(CASE WHEN event_name = 'purchase' THEN 1 ELSE 0 END) as conversions,
  SUM(CAST(JSON_EXTRACT_SCALAR(event_params, '$.value') AS FLOAT64)) as revenue,
  SAFE_DIVIDE(SUM(CAST(JSON_EXTRACT_SCALAR(event_params, '$.value') AS FLOAT64)), 
    SUM(cost_micros) / 1e6) as blended_roas,
  SAFE_DIVIDE(SUM(cost_micros) / 1e6, SUM(CASE WHEN event_name = 'purchase' THEN 1 ELSE 0 END)) as cost_per_conversion
FROM `gbt-datawarehouse-prod.analytics_events.events_*`
WHERE _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', CURRENT_DATE() - 30)
GROUP BY date
ORDER BY date DESC;

-- Customer Acquisition Cost (CAC) Payback Period
WITH monthly_cohorts AS (
  SELECT 
    DATE_TRUNC(DATE(MIN(event_timestamp)), MONTH) as acquisition_month,
    user_id,
    MIN(CAST(JSON_EXTRACT_SCALAR(event_params, '$.value') AS FLOAT64)) as acquisition_value
  FROM `gbt-datawarehouse-prod.analytics_events.events_*`
  WHERE _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', CURRENT_DATE() - 360)
    AND event_name IN ('purchase', 'lead')
  GROUP BY user_id
),
lifetime_value AS (
  SELECT 
    user_id,
    SUM(CAST(JSON_EXTRACT_SCALAR(event_params, '$.value') AS FLOAT64)) as total_ltv,
    COUNT(DISTINCT DATE(event_timestamp)) as engagement_days
  FROM `gbt-datawarehouse-prod.analytics_events.events_*`
  WHERE _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', CURRENT_DATE() - 360)
  GROUP BY user_id
)
SELECT 
  mc.acquisition_month,
  COUNT(DISTINCT mc.user_id) as new_customers,
  ROUND(AVG(lv.total_ltv), 2) as avg_ltv,
  ROUND(SUM(cost_micros) / 1e6 / COUNT(DISTINCT mc.user_id), 2) as cac,
  ROUND(AVG(lv.total_ltv) / (SUM(cost_micros) / 1e6 / COUNT(DISTINCT mc.user_id)), 1) as payback_months
FROM monthly_cohorts mc
LEFT JOIN lifetime_value lv ON mc.user_id = lv.user_id
GROUP BY mc.acquisition_month
ORDER BY mc.acquisition_month DESC;

-- Segment Performance Analysis
SELECT 
  CASE 
    WHEN revenue > 500 THEN 'High Value'
    WHEN revenue BETWEEN 100 AND 500 THEN 'Mid Value'
    ELSE 'Low Value'
  END as customer_segment,
  COUNT(DISTINCT user_id) as segment_size,
  SUM(CASE WHEN event_name = 'purchase' THEN 1 ELSE 0 END) as conversions,
  SUM(CAST(JSON_EXTRACT_SCALAR(event_params, '$.value') AS FLOAT64)) as segment_revenue,
  ROUND(SUM(CAST(JSON_EXTRACT_SCALAR(event_params, '$.value') AS FLOAT64)) / COUNT(DISTINCT user_id), 2) as avg_ltv,
  ROUND(SUM(cost_micros) / 1e6 / COUNT(DISTINCT user_id), 2) as cac_per_user
FROM (
  SELECT 
    user_id,
    SUM(CAST(JSON_EXTRACT_SCALAR(event_params, '$.value') AS FLOAT64)) as revenue,
    SUM(cost_micros) / 1e6 as cost,
    SUM(CASE WHEN event_name = 'purchase' THEN 1 ELSE 0 END) as purchases,
    STRING_AGG(DISTINCT source, ', ' LIMIT 3) as sources
  FROM `gbt-datawarehouse-prod.analytics_events.events_*`
  WHERE _TABLE_SUFFIX >= FORMAT_DATE('%Y%m%d', CURRENT_DATE() - 90)
  GROUP BY user_id
)
GROUP BY customer_segment
ORDER BY segment_revenue DESC;
