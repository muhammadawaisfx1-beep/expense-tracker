# Issue #4: Enhanced Monthly Expense Reports with Filtering

## Description

Currently, the monthly expense report provides a basic summary of expenses for a given month, but lacks the ability to filter results. This enhancement will add filtering capabilities to monthly reports, allowing users to generate more targeted reports based on category and amount criteria.

## Requirements

1. **Category filtering**: Filter monthly report results by category ID
2. **Amount range filtering**: Filter monthly report results by minimum and/or maximum amount
3. **Combined filters**: Support combining category and amount filters together
4. **Backward compatibility**: Existing monthly report functionality without filters must continue to work

## Acceptance Criteria

- [ ] Monthly report can be generated without filters (backward compatible)
- [ ] Monthly report can be filtered by category_id
- [ ] Monthly report can be filtered by min_amount
- [ ] Monthly report can be filtered by max_amount
- [ ] Monthly report can be filtered by both min_amount and max_amount
- [ ] Category and amount filters can be combined
- [ ] API endpoint accepts optional filter query parameters
- [ ] Filtered results correctly exclude expenses not matching criteria
- [ ] Report totals and counts reflect only filtered expenses
- [ ] At least 3 unit tests for report service filtering logic
- [ ] 1 P2P test demonstrating monthly report generation workflow
- [ ] 1 F2P test demonstrating monthly report with category filter

## API Endpoint

`GET /api/reports/monthly?user_id=1&year=2025&month=1&category_id=1&min_amount=10&max_amount=100`

### Parameters

- `user_id` (required): User ID for the report
- `year` (required): Year for the report
- `month` (required): Month for the report (1-12)
- `category_id` (optional): Filter by category ID
- `min_amount` (optional): Minimum expense amount
- `max_amount` (optional): Maximum expense amount

## Example Usage

```bash
# Basic monthly report (no filters)
GET /api/reports/monthly?user_id=1&year=2025&month=1

# Monthly report filtered by category
GET /api/reports/monthly?user_id=1&year=2025&month=1&category_id=1

# Monthly report filtered by amount range
GET /api/reports/monthly?user_id=1&year=2025&month=1&min_amount=20&max_amount=100

# Monthly report with combined filters
GET /api/reports/monthly?user_id=1&year=2025&month=1&category_id=1&min_amount=30&max_amount=200
```

## Expected Behavior

When filters are applied:
- Only expenses matching all filter criteria are included in the report
- Total amount reflects only filtered expenses
- Expense count reflects only filtered expenses
- Category breakdown (by_category) reflects only filtered expenses
- If no expenses match the filters, the report should return zero totals and empty data

