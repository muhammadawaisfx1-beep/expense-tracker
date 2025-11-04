# Issue #5: Yearly Expense Reports with Monthly Breakdown

## Description

Right now we have monthly reports working, but users need to see their spending patterns for the whole year. This would help them understand their annual spending trends better. We should add a yearly report that shows expenses broken down by month and by category.

## Requirements

1. Generate expense reports for a full year (January through December)
2. Show monthly breakdown - total and count for each month
3. Show category breakdown - total expenses per category for the year
4. Calculate total expenses and expense count for the entire year
5. Add REST API endpoint to access yearly reports

## Acceptance Criteria

- [ ] Yearly report can be generated for any valid year
- [ ] Yearly report includes total expenses for the year
- [ ] Yearly report includes total expense count for the year
- [ ] Yearly report includes monthly breakdown with totals and counts for each month
- [ ] Yearly report includes category breakdown with totals per category
- [ ] API endpoint accepts user_id and year parameters
- [ ] Reports correctly handle years with no expenses (zero totals)
- [ ] Monthly breakdown includes all 12 months, even if some have zero expenses
- [ ] At least 3 unit tests for report service yearly report logic
- [ ] 1 P2P test demonstrating yearly report generation workflow
- [ ] 1 F2P test demonstrating yearly report with category breakdown

## API Endpoint

`GET /api/reports/yearly?user_id=1&year=2025`

### Parameters

- `user_id` (required): User ID for the report
- `year` (required): Year for the report (e.g., 2025)

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

## Example Usage

```bash
# Generate yearly report for 2025
GET /api/reports/yearly?user_id=1&year=2025

# Generate yearly report for 2024
GET /api/reports/yearly?user_id=1&year=2024
```

## Expected Behavior

- Aggregate all expenses for the user from Jan 1 to Dec 31 of the specified year
- Monthly breakdown includes all 12 months, even if some have zero expenses
- Category breakdown shows totals per category for the entire year
- Total amount is the sum of all expenses in that year
- Expense count is the total number of expenses in that year

