# Issue #8: Support Recurring Expense Entries

## Description

Currently, users must manually create each expense entry, even for recurring expenses like monthly subscriptions, rent, or utility bills. This feature will add support for recurring expense entries that can automatically generate expense records based on a specified frequency (daily, weekly, monthly, yearly).

## Requirements

1. **Recurring Expense Creation**: Create recurring expense templates with amount, description, category, frequency, and date range
2. **Frequency Support**: Support for daily, weekly, monthly, and yearly recurrence patterns
3. **Date Range Management**: Optional end date to limit recurrence period
4. **Next Occurrence Tracking**: Track the next date when an expense should be generated
5. **Expense Generation**: Automatically generate Expense entries from active recurring expense templates
6. **Recurring Expense Management**: CRUD operations for recurring expenses

## Acceptance Criteria

- [ ] Users can create recurring expense entries via API
- [ ] Users can specify frequency (daily, weekly, monthly, yearly)
- [ ] Users can set optional end date for recurring expenses
- [ ] System tracks next occurrence date for each recurring expense
- [ ] System can generate Expense entries from recurring expense templates
- [ ] Users can update and delete recurring expenses
- [ ] Users can list all their recurring expenses
- [ ] Generated expenses are properly linked to categories and users
- [ ] At least 3 unit tests for recurring expense operations
- [ ] 1 P2P test demonstrating recurring expense creation workflow
- [ ] 1 F2P test demonstrating automatic expense generation from recurring templates

## API Endpoints

- `GET /api/recurring_expenses?user_id=1` - List all recurring expenses for a user
- `POST /api/recurring_expenses` - Create a new recurring expense
- `GET /api/recurring_expenses/:id` - Get a specific recurring expense
- `PUT /api/recurring_expenses/:id` - Update a recurring expense
- `DELETE /api/recurring_expenses/:id` - Delete a recurring expense
- `POST /api/recurring_expenses/generate` - Manually trigger expense generation from active recurring expenses

## API Parameters

### Create/Update Recurring Expense
- `amount` (required) - Expense amount
- `description` (required) - Expense description
- `category_id` (optional) - Category ID
- `user_id` (required) - User ID
- `frequency` (required) - Recurrence frequency: 'daily', 'weekly', 'monthly', 'yearly'
- `start_date` (required) - Start date for recurring expense (YYYY-MM-DD)
- `end_date` (optional) - End date for recurring expense (YYYY-MM-DD)

### Generate Expenses
- `user_id` (required) - User ID to generate expenses for
- `up_to_date` (optional) - Generate expenses up to this date (default: today)

## Example Usage

```bash
# Create a monthly recurring expense
POST /api/recurring_expenses
{
  "amount": 99.99,
  "description": "Netflix Subscription",
  "category_id": 1,
  "user_id": 1,
  "frequency": "monthly",
  "start_date": "2025-01-01",
  "end_date": "2025-12-31"
}

# List all recurring expenses
GET /api/recurring_expenses?user_id=1

# Generate expenses from active recurring expenses
POST /api/recurring_expenses/generate
{
  "user_id": 1,
  "up_to_date": "2025-02-01"
}

# Get a specific recurring expense
GET /api/recurring_expenses/1
```

## Expected Response Format

### Recurring Expense Object
```json
{
  "id": 1,
  "amount": 99.99,
  "description": "Netflix Subscription",
  "category_id": 1,
  "user_id": 1,
  "frequency": "monthly",
  "start_date": "2025-01-01",
  "end_date": "2025-12-31",
  "next_occurrence_date": "2025-02-01",
  "created_at": "2025-01-15T10:00:00Z"
}
```

### Generate Expenses Response
```json
{
  "success": true,
  "data": {
    "generated_count": 2,
    "expenses": [
      {
        "id": 101,
        "amount": 99.99,
        "description": "Netflix Subscription",
        "category_id": 1,
        "user_id": 1,
        "date": "2025-01-01"
      },
      {
        "id": 102,
        "amount": 99.99,
        "description": "Netflix Subscription",
        "category_id": 1,
        "user_id": 1,
        "date": "2025-02-01"
      }
    ]
  }
}
```

## Implementation Notes

- Frequency calculation should handle edge cases (e.g., monthly on 31st day, leap years)
- Next occurrence date should be updated after each expense generation
- Recurring expenses with end_date should stop generating after the end date
- Generated expenses should use the same amount, description, and category as the recurring expense template
- The system should prevent duplicate expense generation for the same date
- Date calculations should account for month boundaries (e.g., monthly on Jan 31 should generate Feb 28/29)

