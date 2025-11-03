# Enhanced Monthly Expense Reports with Filtering

## Description

This PR enhances the monthly expense report functionality by adding filtering capabilities, allowing users to generate more targeted reports based on category and amount criteria.

## What's New

Users can now filter monthly expense reports using multiple criteria:

- **Filter by category**: Filter monthly report results by category ID
- **Filter by amount range**: Filter monthly report results by minimum and/or maximum amount
- **Combined filters**: Category and amount filters can be used together for precise reports
- **Backward compatible**: Existing monthly report functionality without filters continues to work unchanged

## Implementation Details

### Service Layer Changes

Enhanced the `ReportService#generate_monthly_report` method to accept optional filter parameters:

- `category_id` - Filter expenses by category
- `min_amount` - Filter expenses above minimum amount
- `max_amount` - Filter expenses below maximum amount

### Controller Changes

Updated `ReportController#monthly_report` to parse filter parameters from request and pass them to the service layer.

### API Changes

Updated the monthly report endpoint to accept optional query parameters:

- `category_id` - Filter by category ID
- `min_amount` - Minimum expense amount
- `max_amount` - Maximum expense amount

## API Examples

```bash
# Basic monthly report (no filters - backward compatible)
GET /api/reports/monthly?user_id=1&year=2025&month=1

# Monthly report filtered by category
GET /api/reports/monthly?user_id=1&year=2025&month=1&category_id=1

# Monthly report filtered by amount range
GET /api/reports/monthly?user_id=1&year=2025&month=1&min_amount=20&max_amount=100

# Monthly report with combined filters
GET /api/reports/monthly?user_id=1&year=2025&month=1&category_id=1&min_amount=30&max_amount=200
```

## Testing

Added comprehensive test coverage:

- **5 unit tests** for ReportService filtering logic:
  - Basic monthly report without filters
  - Monthly report with category filter
  - Monthly report with amount range filters
  - Monthly report with combined filters
  - Report with no matching expenses
- **1 P2P test**: Monthly report generation workflow (create expenses, generate report, verify data)
- **1 F2P test**: Monthly report with category filter (create categories, create expenses, filter by category)

All tests pass and follow existing test patterns.

Fixes #3
