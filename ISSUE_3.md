# Issue #3: Add search and filtering functionality for expenses

## Description

Currently, users can list expenses but have limited ability to search and filter them. This feature will add comprehensive search and filtering capabilities to help users find specific expenses more easily.

## Requirements

1. **Search by description**: Search expenses by keywords in the description field
2. **Filter by category**: Filter expenses by category ID
3. **Filter by date range**: Filter expenses within a specific date range (start_date and end_date)
4. **Filter by amount range**: Filter expenses by minimum and maximum amount
5. **Sorting**: Allow sorting by date, amount, or description (ascending/descending)

## Acceptance Criteria

- [ ] Users can search expenses by description keywords
- [ ] Users can filter expenses by category
- [ ] Users can filter expenses by date range
- [ ] Users can filter expenses by amount range (min_amount, max_amount)
- [ ] Users can sort expenses by date, amount, or description
- [ ] All filters can be combined
- [ ] API endpoints accept query parameters for filtering
- [ ] At least 3 unit tests for search/filter functionality
- [ ] 1 P2P test demonstrating search workflow
- [ ] 1 F2P test demonstrating filtering by category

## API Endpoint

`GET /api/expenses?user_id=1&search=keyword&category_id=1&start_date=2025-01-01&end_date=2025-01-31&min_amount=10&max_amount=100&sort_by=date&order=desc`

## Example Usage

```bash
# Search for expenses containing "lunch"
GET /api/expenses?user_id=1&search=lunch

# Filter by category and date range
GET /api/expenses?user_id=1&category_id=1&start_date=2025-01-01&end_date=2025-01-31

# Filter by amount range and sort by amount
GET /api/expenses?user_id=1&min_amount=20&max_amount=100&sort_by=amount&order=asc
```

