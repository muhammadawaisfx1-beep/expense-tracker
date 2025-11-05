# Budget Alerts/Notifications System

## Description

This PR implements a budget alert and notification system that notifies users when their spending approaches or exceeds budget limits. The system provides real-time alerts with detailed information about budget status, spending, remaining amounts, and percentage used.

## What's New

Users can now:

- **Get budget alerts**: Retrieve all active budget alerts for their accounts
- **Filter alerts**: Filter alerts by type (exceeded, near_limit, or all)
- **Custom thresholds**: Configure alert threshold percentage per request (default: 80%)
- **Detailed alert information**: Each alert includes budget details, spending amount, remaining budget, percentage used, and descriptive messages
- **Alert summaries**: Get counts of exceeded and near-limit alerts

## Implementation Details

### Service Layer

Enhanced `BudgetService` with alert generation methods:

- `generate_alert(budget, user_id, threshold_percent)`: Generates an alert for a single budget if it exceeds the limit or approaches the threshold
  - Returns `exceeded` alert when spending > budget amount
  - Returns `near_limit` alert when percentage used >= threshold_percent
  - Returns `nil` when budget is within limits

- `get_budget_alerts(user_id, alert_type, threshold_percent)`: Retrieves all active alerts for a user
  - Filters alerts by type (exceeded, near_limit, all)
  - Supports custom threshold percentage
  - Returns summary with total alerts, exceeded count, and near_limit count

### Controller Layer

Added `alerts` method to `BudgetController` to handle alert API requests with proper error handling and status codes.

### API Routes

Added two new routes to the main application:

- `GET /api/budgets/alerts` - Get all active budget alerts
- `GET /api/budgets/alerts/:type` - Get alerts filtered by type

Both endpoints support query parameters:
- `user_id` (required) - User ID to retrieve alerts for
- `threshold_percent` (optional, default: 80) - Percentage threshold for "near limit" alerts
- `type` (optional) - Filter by alert type: 'exceeded', 'near_limit', or 'all'

## API Endpoints

- `GET /api/budgets/alerts?user_id=1` - Get all active alerts for a user
- `GET /api/budgets/alerts/exceeded?user_id=1` - Get only exceeded budget alerts
- `GET /api/budgets/alerts/near_limit?user_id=1&threshold_percent=85` - Get near-limit alerts with custom threshold

## API Examples

```bash
# Get all active alerts
GET /api/budgets/alerts?user_id=1

# Get only exceeded alerts
GET /api/budgets/alerts/exceeded?user_id=1

# Get alerts with custom threshold (90%)
GET /api/budgets/alerts?user_id=1&threshold_percent=90
```

### Response Format

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
      "message": "Budget is 90.0% used. Only $50.0 remaining."
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

## Testing

Added comprehensive test coverage:

- **Unit tests** for `generate_alert` method:
  - Generates exceeded alert when spending exceeds budget
  - Generates near_limit alert when spending approaches threshold
  - Returns nil when budget is within limits
  - Respects custom threshold percentage

- **Unit tests** for `get_budget_alerts` method:
  - Returns all alerts for a user
  - Filters alerts by type correctly
  - Returns empty alerts when no budgets need alerts

- **Integration tests (P2P)**: Budget alert generation workflow
  - Generates and retrieves budget alerts for exceeded budgets
  - Allows filtering alerts by type
  - Supports custom threshold percentage

- **Integration tests (F2P)**: Budget alert when approaching limit
  - Generates near_limit alert when spending approaches budget limit
  - Provides accurate alert counts and summary information

All tests pass.

Fixes #8

