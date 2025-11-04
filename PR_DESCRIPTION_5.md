# Yearly Expense Reports with Monthly Breakdown

## Description

This adds yearly expense report functionality so users can see their spending for the entire year. The report includes monthly and category breakdowns to help understand spending patterns.

## What's New

Users can now generate yearly expense reports with:

- Yearly totals (total expenses and count)
- Monthly breakdown for all 12 months
- Category breakdown showing totals per category
- Full year view to analyze spending trends

## Implementation Details

### Service Layer Changes

Added `generate_yearly_report` method to `ReportService` that:
- Aggregates all expenses for the user from Jan 1 to Dec 31 of the given year
- Creates monthly breakdown for all 12 months (zero totals for months with no expenses)
- Groups expenses by category and calculates totals
- Returns total amount and expense count

### Controller Changes

Added `yearly_report` method to `ReportController` that accepts `user_id` and `year` parameters and returns the yearly report.

### API Changes

Added yearly report endpoint:

- `GET /api/reports/yearly?user_id=1&year=2025`

## API Examples

```bash
# Generate yearly report for 2025
GET /api/reports/yearly?user_id=1&year=2025

# Generate yearly report for 2024
GET /api/reports/yearly?user_id=1&year=2024
```

### Response Format

```json
{
  "year": 2025,
  "total": 12500.50,
  "expense_count": 156,
  "by_month": [
    { "month": 1, "total": 1200.00, "count": 15 },
    { "month": 2, "total": 1350.50, "count": 18 },
    ...
    { "month": 12, "total": 1100.00, "count": 12 }
  ],
  "by_category": {
    "1": 5000.00,
    "2": 3000.50,
    "3": 4500.00
  }
}
```

## Testing

Added test coverage:

- 4 unit tests for ReportService:
  - Expenses across multiple months
  - Category breakdown verification
  - Empty year handling
  - Full year coverage (all 12 months)
- 1 P2P test: End-to-end yearly report generation
- 1 F2P test: Yearly report with category breakdown across multiple months

All tests pass.

Fixes #5

