# Expense Statistics Dashboard

## Description

This PR implements a comprehensive expense statistics and analytics dashboard, providing users with detailed insights into their spending patterns, trends, and key metrics. The implementation includes a statistics calculation service and a dashboard API endpoint.

## What's New

Users can now:

- **View comprehensive statistics**: Get detailed statistics about their expenses including totals, averages, and counts
- **Analyze spending trends**: See daily, weekly, and monthly spending averages
- **Category breakdown**: View spending by category with amounts and percentages
- **Currency breakdown**: View spending by currency with amounts and percentages
- **Date range filtering**: Get statistics for specific time periods

## Implementation Details

### Service Layer

Created `StatisticsService` with:
- **Statistics Calculation**: `get_statistics(user_id, date_range = nil)`
  - Calculates summary metrics: total spending, average expense, largest expense, smallest expense, expense count
  - Calculates trend metrics: daily average, weekly average, monthly average
  - Calculates category breakdown: spending by category with amounts and percentages
  - Calculates currency breakdown: spending by currency with amounts and percentages
  - Supports optional date range filtering
  - Handles empty result sets gracefully

### Controller Layer

Created `StatisticsController` with:
- **Dashboard Endpoint**: `dashboard(user_id, date_range = nil)`
  - Parses date range from query parameters
  - Calls StatisticsService to calculate statistics
  - Returns JSON response with all statistics
  - Handles errors gracefully

### API Endpoint

#### Get Statistics Dashboard
```bash
GET /api/statistics?user_id=1
GET /api/statistics?user_id=1&start_date=2025-01-01&end_date=2025-01-31
```

Response:
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

## Statistics Metrics

### Summary Metrics
- **Total Spending**: Sum of all expenses in the period
- **Average Expense**: Average amount per expense
- **Largest Expense**: Highest single expense amount
- **Smallest Expense**: Lowest single expense amount
- **Expense Count**: Total number of expenses

### Trend Metrics
- **Daily Average**: Average spending per day (total / number of days)
- **Weekly Average**: Average spending per week (total / number of weeks)
- **Monthly Average**: Average spending per month (total / number of months)

### Breakdowns
- **Category Breakdown**: Spending by category with amounts and percentages
- **Currency Breakdown**: Spending by currency with amounts and percentages

## Testing

Added comprehensive test coverage:

- **Unit tests (8 tests)** for `StatisticsService`:
  - Statistics calculation with various expense data
  - Summary metrics calculation (total, average, largest, smallest, count)
  - Trend calculations (daily, weekly, monthly averages)
  - Category breakdown calculation with percentages
  - Currency breakdown calculation with percentages
  - Date range filtering
  - Empty result handling
  - Edge cases (single expense, no expenses)

- **Integration tests (2 tests)**:
  - **P2P (1 test)**: Get Statistics Workflow
    - Create multiple expenses with different categories and currencies
    - Request statistics endpoint
    - Verify all statistics are calculated correctly
    - Verify response format matches expected structure
  
  - **F2P (1 test)**: Statistics with Date Range
    - Create expenses across different date ranges
    - Request statistics with date range filter
    - Verify only expenses within date range are included
    - Verify statistics are calculated correctly for filtered data
    - Test with different date ranges

All tests pass.

## Implementation Notes

- StatisticsService reuses ExpenseRepository for data consistency
- Date range filtering is optional - if not provided, statistics include all expenses
- Percentages are calculated based on total spending
- Trend calculations use the date range to determine number of days/weeks/months
- Empty result sets return zero values and empty arrays
- Category names are retrieved from CategoryRepository for display
- Currency breakdown handles multiple currencies correctly
- All calculations handle edge cases (division by zero, empty arrays, etc.)

Fixes #12

