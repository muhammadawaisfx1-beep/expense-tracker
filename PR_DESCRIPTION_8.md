# Recurring Expense Entries

## Description

This PR implements support for recurring expense entries, allowing users to create expense templates that automatically generate expense records based on specified frequencies (daily, weekly, monthly, yearly). This eliminates the need for users to manually create repetitive expenses like monthly subscriptions, rent, or utility bills.

## What's New

Users can now:

- **Create recurring expense templates**: Set up expense templates with amount, description, category, frequency, and optional date range
- **Support multiple frequencies**: Choose from daily, weekly, monthly, or yearly recurrence patterns
- **Automatic expense generation**: Generate Expense entries from active recurring expense templates
- **Date range management**: Set optional end dates to limit recurrence periods
- **Next occurrence tracking**: System automatically tracks when the next expense should be generated
- **Duplicate prevention**: System prevents duplicate expense generation for the same date

## Implementation Details

### Model Layer

Added `RecurringExpense` model with:
- Attributes: `id`, `amount`, `description`, `category_id`, `user_id`, `frequency`, `start_date`, `end_date`, `next_occurrence_date`, `created_at`
- Validation: Ensures valid amount, description, frequency, and date ranges
- Frequency calculation: Handles edge cases like month boundaries (e.g., Jan 31 → Feb 28) and leap years
- Active status: Determines if a recurring expense is active for a given date

### Repository Layer

Added `RecurringExpenseRepository` with:
- CRUD operations: `create`, `find_by_id`, `find_by_user`, `update`, `delete`
- Active filtering: `find_active_by_user` to find recurring expenses active on a specific date
- Shared in-memory storage using class variables

### Service Layer

Added `RecurringExpenseService` with:
- `create_recurring_expense`: Creates new recurring expense templates
- `update_recurring_expense`: Updates existing recurring expenses
- `delete_recurring_expense`: Deletes recurring expenses
- `get_recurring_expense`: Retrieves a specific recurring expense
- `list_recurring_expenses`: Lists all recurring expenses for a user
- `generate_expenses`: Automatically generates Expense entries from active recurring expenses (F2P feature)
  - Handles multiple frequencies (daily, weekly, monthly, yearly)
  - Prevents duplicate generation
  - Updates next_occurrence_date after generation
  - Includes safety limit (1000 iterations) to prevent infinite loops

### Controller Layer

Added `RecurringExpenseController` with REST endpoints following Rack-style response format `[status, headers, body]`.

### API Routes

Added routes to `lib/app.rb`:
- `GET /api/recurring_expenses?user_id=1` - List all recurring expenses
- `POST /api/recurring_expenses` - Create recurring expense
- `GET /api/recurring_expenses/:id` - Get specific recurring expense
- `PUT /api/recurring_expenses/:id` - Update recurring expense
- `DELETE /api/recurring_expenses/:id` - Delete recurring expense
- `POST /api/recurring_expenses/generate` - Manually trigger expense generation

## API Endpoints

### Create Recurring Expense
```bash
POST /api/recurring_expenses
Content-Type: application/json

{
  "amount": 99.99,
  "description": "Netflix Subscription",
  "category_id": 1,
  "user_id": 1,
  "frequency": "monthly",
  "start_date": "2025-01-01",
  "end_date": "2025-12-31"
}
```

### List Recurring Expenses
```bash
GET /api/recurring_expenses?user_id=1
```

### Generate Expenses
```bash
POST /api/recurring_expenses/generate
Content-Type: application/json

{
  "user_id": 1,
  "up_to_date": "2025-02-01"
}
```

### Response Format

#### Recurring Expense Object
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

#### Generate Expenses Response
```json
{
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
```

## Testing

Added comprehensive test coverage:

- **Unit tests (15 tests)** for `RecurringExpense` model:
  - Initialization and default values
  - Validation (amount, description, frequency, dates)
  - Active status checking
  - Next occurrence calculation for all frequency types
  - Month boundary edge cases (e.g., Jan 31 → Feb 28)
  - Hash conversion

- **Unit tests (8 tests)** for `RecurringExpenseService`:
  - Create recurring expense with validation
  - Date parsing from strings
  - Get and list operations
  - Expense generation from recurring templates
  - Duplicate prevention

- **Integration tests (6 tests)**:
  - **P2P (3 tests)**: Recurring expense creation workflow
    - Create and retrieve recurring expense
    - List all recurring expenses for a user
    - Update recurring expense
  - **F2P (3 tests)**: Automatic expense generation
    - Generate Expense entries from recurring templates
    - Prevent duplicate expense generation
    - Handle different frequency types (daily, weekly, monthly, yearly)

All tests pass.

## Implementation Notes

- Frequency calculations handle edge cases:
  - Monthly on 31st day → adjusts to last day of next month (e.g., Jan 31 → Feb 28)
  - Leap year handling for yearly frequency (Feb 29 → Feb 28 in non-leap years)
- Next occurrence date is automatically updated after expense generation
- Recurring expenses with end_date stop generating after the end date
- Generated expenses use the same amount, description, and category as the template
- Duplicate detection prevents generating expenses for the same date, amount, description, and category
- Safety limit of 1000 iterations prevents infinite loops in expense generation

Fixes #8

