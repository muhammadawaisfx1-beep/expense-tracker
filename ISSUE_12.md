# Issue #12: Create Expense Statistics and Analytics Dashboard

## Description

Currently, users can view individual expenses and generate reports, but there is no comprehensive statistics dashboard that provides an overview of their spending patterns, trends, and key metrics. This issue adds a statistics service and dashboard endpoint that calculates and returns various expense statistics and analytics.

## Requirements

1. **Statistics Calculation Service**:
   - Create StatisticsService to calculate various expense statistics
   - Support statistics calculation with optional date range filtering
   - Calculate key metrics: total spending, average expense, largest expense, smallest expense, expense count
   - Calculate spending trends: daily average, weekly average, monthly average
   - Calculate category breakdown: spending by category with percentages
   - Calculate currency breakdown: spending by currency
   - Support filtering by user_id (required) and optional date range

2. **Statistics Metrics**:
   - **Total Spending**: Sum of all expenses in the period
   - **Average Expense**: Average amount per expense
   - **Largest Expense**: Highest single expense amount
   - **Smallest Expense**: Lowest single expense amount
   - **Expense Count**: Total number of expenses
   - **Daily Average**: Average spending per day
   - **Weekly Average**: Average spending per week
   - **Monthly Average**: Average spending per month
   - **Category Breakdown**: Spending by category with amounts and percentages
   - **Currency Breakdown**: Spending by currency with amounts and percentages
   - **Date Range**: Start and end dates of the statistics period

3. **Service Layer**:
   - Create StatisticsService with:
     - `get_statistics(user_id, date_range = nil)` - Get comprehensive statistics
     - Reuse ExpenseRepository for data retrieval
     - Handle empty result sets gracefully
     - Calculate all metrics efficiently

4. **API Endpoint**:
   - `GET /api/statistics?user_id=X&[start_date=YYYY-MM-DD]&[end_date=YYYY-MM-DD]` - Get statistics dashboard
   - Return JSON with all calculated statistics
   - Support optional date range filtering
   - Return appropriate HTTP status codes

## Implementation Details

### Service Layer

Create `StatisticsService` with:
- `get_statistics(user_id, date_range = nil)` - Calculate and return all statistics
- Accept optional date_range hash with `:start` and `:end` Date objects
- Filter expenses by user_id and optional date range
- Calculate all metrics from filtered expenses
- Return structured hash with all statistics

### Controller Layer

Create `StatisticsController` with:
- `dashboard(user_id, date_range = nil)` - Handle statistics request
- Parse date range from query parameters
- Call StatisticsService to get statistics
- Return JSON response with statistics data
- Handle errors gracefully

### Statistics Response Format

```json
{
  "user_id": 1,
  "date_range": {
    "start": "2025-01-01",
    "end": "2025-01-31"
  },
  "summary": {
    "total_spending": 1250.50,
    "average_expense": 62.53,
    "largest_expense": 250.00,
    "smallest_expense": 15.25,
    "expense_count": 20
  },
  "trends": {
    "daily_average": 40.34,
    "weekly_average": 282.38,
    "monthly_average": 1250.50
  },
  "category_breakdown": [
    {
      "category_id": 1,
      "category_name": "Food & Dining",
      "amount": 750.50,
      "percentage": 60.0
    },
    {
      "category_id": 2,
      "category_name": "Transportation",
      "amount": 500.00,
      "percentage": 40.0
    }
  ],
  "currency_breakdown": [
    {
      "currency": "USD",
      "amount": 1000.00,
      "percentage": 80.0
    },
    {
      "currency": "EUR",
      "amount": 250.50,
      "percentage": 20.0
    }
  ]
}
```

## Expected Behavior

### Get Statistics (All Time)
```bash
GET /api/statistics?user_id=1
```

Returns statistics for all expenses of the user.

### Get Statistics (Date Range)
```bash
GET /api/statistics?user_id=1&start_date=2025-01-01&end_date=2025-01-31
```

Returns statistics for expenses within the specified date range.

### Empty Result Set
When no expenses match the filters:
- All amounts should be 0.0
- Expense count should be 0
- Category and currency breakdowns should be empty arrays
- Averages should be 0.0

## Test Requirements

- **Unit Tests (3+)**: Test StatisticsService methods
  - Statistics calculation with various expense data
  - Date range filtering
  - Empty result handling
  - Category breakdown calculation
  - Currency breakdown calculation
  - Trend calculations (daily, weekly, monthly averages)
  - Edge cases (single expense, no expenses)

- **P2P Test (1)**: Get statistics workflow
  - Create multiple expenses with different categories and currencies
  - Request statistics endpoint
  - Verify all statistics are calculated correctly
  - Verify response format matches expected structure

- **F2P Test (1)**: Statistics with date range
  - Create expenses across different date ranges
  - Request statistics with date range filter
  - Verify only expenses within date range are included
  - Verify statistics are calculated correctly for filtered data
  - Test with different date ranges

## Acceptance Criteria

- [x] StatisticsService can calculate comprehensive expense statistics
- [x] Statistics include summary metrics (total, average, largest, smallest, count)
- [x] Statistics include trend calculations (daily, weekly, monthly averages)
- [x] Statistics include category breakdown with percentages
- [x] Statistics include currency breakdown with percentages
- [x] Statistics support date range filtering
- [x] Empty result sets are handled gracefully
- [x] API endpoint returns statistics in correct JSON format
- [x] All tests pass

## Related Files

- `lib/services/statistics_service.rb` - Statistics service (new file)
- `lib/controllers/statistics_controller.rb` - Statistics controller (new file)
- `lib/app.rb` - Add statistics route
- `spec/services/statistics_service_spec.rb` - Unit tests (new file)
- `spec/integration/statistics_workflow_spec.rb` - Integration tests (new file)

