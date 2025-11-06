# Issue #6: Implement budget creation and tracking system

## Description

Currently, the application has budget models and some budget tracking logic, but there's no complete API for creating, managing, and tracking budgets. This feature will implement a full budget management system with CRUD operations and budget status tracking.

## Requirements

1. **Budget Creation**: Create budgets for categories with amount and period (start/end dates)
2. **Budget Management**: Update and delete budgets
3. **Budget Listing**: List all budgets for a user
4. **Budget Status Tracking**: Check budget status (spending vs. limit, remaining amount, percentage used)
5. **Budget Alerts**: Identify budgets that are exceeded or near limit

## Acceptance Criteria

- [ ] Users can create budgets via API
- [ ] Users can update existing budgets
- [ ] Users can delete budgets
- [ ] Users can list all their budgets
- [ ] Users can check budget status (spending, remaining, percentage used)
- [ ] API endpoints accept budget parameters (category_id, amount, period_start, period_end)
- [ ] Budget validation ensures valid dates and amounts
- [ ] At least 3 unit tests for budget operations
- [ ] 1 P2P test demonstrating budget creation workflow
- [ ] 1 F2P test demonstrating budget status tracking

## API Endpoints

- `POST /api/budgets` - Create a new budget
- `GET /api/budgets` - List all budgets for a user
- `GET /api/budgets/:id` - Get a specific budget
- `PUT /api/budgets/:id` - Update a budget
- `DELETE /api/budgets/:id` - Delete a budget
- `GET /api/budgets/:id/status` - Get budget status (spending, remaining, etc.)

## Example Usage

```bash
# Create a budget
POST /api/budgets
{
  "category_id": 1,
  "amount": 500,
  "period_start": "2025-01-01",
  "period_end": "2025-01-31",
  "user_id": 1
}

# Get budget status
GET /api/budgets/1/status?user_id=1

# List all budgets
GET /api/budgets?user_id=1
```

