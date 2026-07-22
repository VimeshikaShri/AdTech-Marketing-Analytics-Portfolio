#!/usr/bin/env python3
"""
Budget Monitor for Google Ads
Real-time monitoring of daily spend vs. allocated budgets with Slack alerts.
"""

import logging
import yaml
from datetime import datetime, date
from typing import Dict, List
from google.ads.googleads.client import GoogleAdsClient
import requests

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class BudgetMonitor:
    """Monitor and alert on budget pacing"""
    
    def __init__(self, config_path: str):
        """Initialize budget monitor"""
        with open(config_path, 'r') as f:
            self.config = yaml.safe_load(f)
        
        self.client = GoogleAdsClient.load_from_storage('google-ads.yaml')
        self.customer_id = self.config['google_ads']['customer_id']
        self.daily_budget = self.config['bidding_strategy']['daily_budget_usd']
    
    def get_today_spend(self) -> Dict:
        """Get today's spending across all campaigns"""
        ga_service = self.client.get_service("GoogleAdsService")
        
        query = """
            SELECT 
                campaign.id,
                campaign.name,
                campaign.daily_budget_micros,
                metrics.cost_micros
            FROM campaign
            WHERE campaign.status = 'ENABLED'
                AND segments.date = TODAY()
        """
        
        campaigns = []
        total_spend = 0
        
        try:
            results = ga_service.search_stream(customer_id=self.customer_id, query=query)
            
            for batch in results:
                for row in batch.results:
                    daily_budget_usd = row.campaign.daily_budget_micros / 1e6
                    spend_usd = row.metrics.cost_micros / 1e6
                    pace = (spend_usd / daily_budget_usd * 100) if daily_budget_usd > 0 else 0
                    
                    campaigns.append({
                        'campaign_id': row.campaign.id,
                        'campaign_name': row.campaign.name,
                        'daily_budget': daily_budget_usd,
                        'spend': spend_usd,
                        'pace_percent': pace,
                        'status': self._get_pace_status(pace)
                    })
                    
                    total_spend += spend_usd
            
            return {
                'campaigns': campaigns,
                'total_spend': total_spend,
                'total_budget': self.daily_budget,
                'account_pace': (total_spend / self.daily_budget * 100) if self.daily_budget > 0 else 0
            }
        
        except Exception as e:
            logger.error(f"Error fetching budget data: {e}")
            return {}
    
    @staticmethod
    def _get_pace_status(pace: float) -> str:
        """Determine pace status"""
        if pace < 50:
            return '🟦 UNDER'
        elif pace < 110:
            return '🟩 ON_TRACK'
        else:
            return '🟥 OVERSPEND'
    
    def generate_budget_report(self) -> str:
        """Generate budget report"""
        data = self.get_today_spend()
        
        if not data:
            return "Error retrieving budget data"
        
        report = f"📊 Daily Budget Report - {date.today()}\n"
        report += "=" * 60 + "\n\n"
        
        # Account summary
        account_pace = data['account_pace']
        report += f"Account Pace: {account_pace:.1f}%\n"
        report += f"Total Spend: ${data['total_spend']:.2f} / ${data['total_budget']:.2f}\n"
        report += f"Status: {self._get_pace_status(account_pace)}\n\n"
        
        # Campaign breakdown
        report += "Campaign Breakdown:\n"
        report += "-" * 60 + "\n"
        
        for campaign in sorted(data['campaigns'], key=lambda x: x['spend'], reverse=True):
            status = campaign['status']
            name = campaign['campaign_name'][:30]
            spend = campaign['spend']
            budget = campaign['daily_budget']
            pace = campaign['pace_percent']
            
            report += f"{status} {name}\n"
            report += f"   ${spend:.2f} / ${budget:.2f} ({pace:.0f}%)\n"
        
        return report
    
    def send_slack_alert(self, message: str):
        """Send alert to Slack"""
        webhook_url = self.config['slack'].get('webhook_url')
        if not webhook_url:
            logger.warning("Slack webhook URL not configured")
            return
        
        payload = {'text': message}
        
        try:
            requests.post(webhook_url, json=payload)
            logger.info("Slack alert sent")
        except Exception as e:
            logger.error(f"Error sending Slack alert: {e}")
    
    def check_budget_alerts(self) -> List[str]:
        """Check for budget violations and generate alerts"""
        data = self.get_today_spend()
        alerts = []
        
        if not data:
            return alerts
        
        overspend_threshold = self.config['budget_monitor']['alert_overspend_percent']
        
        # Check account-level overspend
        if data['account_pace'] > overspend_threshold:
            alerts.append(
                f"⚠️ ACCOUNT OVERSPEND ALERT\n"
                f"Pace: {data['account_pace']:.1f}% of daily budget\n"
                f"Spend: ${data['total_spend']:.2f} / ${data['total_budget']:.2f}"
            )
        
        # Check campaign-level issues
        for campaign in data['campaigns']:
            if campaign['pace_percent'] > overspend_threshold:
                alerts.append(
                    f"🔴 {campaign['campaign_name']} OVERSPENDING\n"
                    f"Pace: {campaign['pace_percent']:.0f}%\n"
                    f"Spend: ${campaign['spend']:.2f} / ${campaign['daily_budget']:.2f}"
                )
        
        return alerts
    
    def monitor(self):
        """Run budget monitoring"""
        logger.info("Running budget monitor")
        
        # Generate and log report
        report = self.generate_budget_report()
        logger.info(f"\n{report}")
        
        # Check for alerts
        alerts = self.check_budget_alerts()
        if alerts:
            for alert in alerts:
                logger.warning(alert)
                self.send_slack_alert(alert)


def main():
    """Main entry point"""
    import argparse
    import time
    
    parser = argparse.ArgumentParser(description='Budget Monitor')
    parser.add_argument('--config', default='config.yaml', help='Config file path')
    parser.add_argument('--interval', type=int, default=3600, help='Check interval in seconds')
    parser.add_argument('--once', action='store_true', help='Run once and exit')
    
    args = parser.parse_args()
    
    monitor = BudgetMonitor(args.config)
    
    if args.once:
        monitor.monitor()
    else:
        logger.info(f"Budget monitor running (check interval: {args.interval}s)")
        try:
            while True:
                monitor.monitor()
                time.sleep(args.interval)
        except KeyboardInterrupt:
            logger.info("Budget monitor stopped")


if __name__ == '__main__':
    main()
