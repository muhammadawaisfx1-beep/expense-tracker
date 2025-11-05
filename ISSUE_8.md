# Issue #8: Budget Alerts/Notifications System

## Description

Currently, the application can track budget status and identify when budgets are exceeded or near limit, but there's no API endpoint or notification system to alert users about budget status. This feature will implement a budget alert system that notifies users when their spending approaches or exceeds budget limits.

## Requirements

1. **Alert Generation**: Generate alerts for budgets that are exceeded or approaching limits
2. **Alert Threshold Configuration**: Support configurable threshold percentage (default 80%) for "near limit" alerts
3. **Alert Retrieval**: API endpoint to retrieve all active alerts for a user
4. **Alert Details**: Include budget information, spending amount, percentage used, and alert type (exceeded/near_limit) in alert responses
5. **Alert Filtering**: Filter alerts by alert type (exceeded, near_limit, or all)

## Acceptance Criteria

- [ ] Users can retrieve all active budget alerts via API
- [ ] Alerts are generated for budgets that exceed their limits
- [ ] Alerts are generated for budgets approaching their limits (configurable threshold)
- [ ] Alert responses include budget details, spending, remaining amount, and alert type
- [ ] Users can filter alerts by type (exceeded, near_limit, all)
- [ ] API endpoint accepts threshold_percent parameter for custom alert thresholds
- [ ] At least 3 unit tests for alert operations
- [ ] 1 P2P test demonstrating alert generation workflow
- [ ] 1 F2P test demonstrating alert when approaching limit

## API Endpoints

- `GET /api/budgets/alerts` - Get all active budget alerts for a user
- `GET /api/budgets/alerts/:type` - Get alerts filtered by type (exceeded, near_limit)

## API Parameters

- `user_id` (required) - User ID to retrieve alerts for
- `threshold_percent` (optional, default: 80) - Percentage threshold for "near limit" alerts
- `type` (optional) - Filter alerts by type: 'exceeded', 'near_limit', or 'all' (default: 'all')

## Example Usage

```bash
# Get all active alerts for a user
GET /api/budgets/alerts?user_id=1

# Get only exceeded budget alerts
GET /api/budgets/alerts/exceeded?user_id=1

# Get alerts with custom threshold (90%)
GET /api/budgets/alerts?user_id=1&threshold_percent=90

# Get near-limit alerts
GET /api/budgets/alerts/near_limit?user_id=1&threshold_percent=85
```

## Expected Response Format

```json
{
  "alerts": [
    {
      "budget": {
        "id": 1,
        "category_id": 1,
        "amount": 500,
        "period_start": "2025-01-01",
        "period_end": "2025-01-31",
        "user_id": 1
      },
      "spending": 450.0,
      "remaining": 50.0,
      "percentage_used": 90.0,
      "alert_type": "near_limit",
      "message": "Budget is 90% used. Only $50.0 remaining."
    },
    {
      "budget": {
        "id": 2,
        "category_id": 2,
        "amount": 300,
        "period_start": "2025-01-01",
        "period_end": "2025-01-31",
        "user_id": 1
      },
      "spending": 350.0,
      "remaining": -50.0,
      "percentage_used": 116.67,
      "alert_type": "exceeded",
      "message": "Budget exceeded by $50.0 (116.67% used)."
    }
  ],
  "total_alerts": 2,
  "exceeded_count": 1,
  "near_limit_count": 1
}
```

## Implementation Notes

- Alerts should be calculated in real-time based on current spending
- Alert threshold should be configurable per request
- Alert messages should be descriptive and include key metrics
- The system should handle cases where a budget might be both exceeded and near limit (prioritize exceeded)

