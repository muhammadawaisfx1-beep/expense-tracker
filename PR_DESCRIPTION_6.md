# Budget Creation and Tracking System

## Description

This PR implements a complete budget management system, allowing users to create, update, delete, and track budgets for their expense categories. The system tracks spending against budgets and provides status information including remaining amount and percentage used.

## What's New

Users can now:

- **Create budgets**: Set budget limits for categories with specific time periods
- **Manage budgets**: Update and delete existing budgets
- **List budgets**: View all budgets for a user
- **Track budget status**: Check spending vs. limit, remaining amount, and percentage used
- **Budget alerts**: Identify when budgets are exceeded or near limit

## Implementation Details

### Repository Layer

Created `BudgetRepository` to handle budget data persistence with in-memory storage, following the same pattern as other repositories.

### Service Layer

Enhanced `BudgetService` with complete CRUD operations:
- `create_budget`: Creates new budgets with validation
- `update_budget`: Updates existing budgets
- `delete_budget`: Removes budgets
- `get_budget`: Retrieves a specific budget
- `list_budgets`: Lists all budgets for a user
- `check_budget_status`: Calculates spending, remaining amount, percentage used, and exceeded status

### Controller Layer

Created `BudgetController` to handle all budget-related API requests with proper error handling and status codes.

### Model Enhancements

The `Budget` model already had validation and helper methods, which are now fully utilized by the service layer.

### Validation

Added date range validation to ensure budget periods are valid, integrated with the existing `Validators` utility.

## API Endpoints

- `POST /api/budgets` - Create a new budget
- `GET /api/budgets` - List all budgets for a user
- `GET /api/budgets/:id` - Get a specific budget
- `PUT /api/budgets/:id` - Update a budget
- `DELETE /api/budgets/:id` - Delete a budget
- `GET /api/budgets/:id/status` - Get budget status (spending, remaining, percentage used)

## API Examples

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

# Update a budget
PUT /api/budgets/1
{
  "amount": 600,
  "period_end": "2025-02-28"
}
```

### Response Format

Budget status response:
```json
{
  "budget": {
    "id": 1,
    "category_id": 1,
    "amount": 500,
    "period_start": "2025-01-01",
    "period_end": "2025-01-31",
    "user_id": 1
  },
  "spending": 250.0,
  "remaining": 250.0,
  "percentage_used": 50.0,
  "exceeded": false
}
```

## Testing

Added comprehensive test coverage:

- Unit tests for Budget model validation and helper methods
- Unit tests for BudgetService CRUD operations and status tracking
- Integration tests for budget creation workflow (P2P)
- Integration tests for budget status tracking with actual expenses (F2P)

All tests pass.

Fixes #7

