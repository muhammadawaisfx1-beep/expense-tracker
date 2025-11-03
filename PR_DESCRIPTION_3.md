# Add Expense Search and Filtering Functionality

## Description

This PR adds comprehensive search and filtering capabilities to the expense tracking API, allowing users to find specific expenses more easily.

## What's New

Users can now search and filter expenses using multiple criteria:
- **Search by description**: Find expenses containing specific keywords (case-insensitive)
- **Filter by category**: Filter expenses by category ID
- **Filter by date range**: Get expenses within a specific date range
- **Filter by amount range**: Filter expenses by minimum and/or maximum amount
- **Sorting**: Sort results by date, amount, or description in ascending or descending order
- **Combined filters**: All filters can be used together for precise queries

## Implementation Details

### Repository Changes
Enhanced the `ExpenseRepository#find_by_user` method to support filtering and sorting operations.

### API Changes
Updated the expense listing endpoint to accept query parameters for filtering:
- `search` - keyword to search in description
- `category_id` - filter by category
- `start_date` / `end_date` - date range filter
- `min_amount` / `max_amount` - amount range filter
- `sort_by` - field to sort by (date, amount, description)
- `order` - sort order (asc, desc)

## API Examples

```bash
# Search for expenses containing "lunch"
GET /api/expenses?user_id=1&search=lunch

# Filter by category and date range
GET /api/expenses?user_id=1&category_id=1&start_date=2025-01-01&end_date=2025-01-31

# Filter by amount and sort by amount descending
GET /api/expenses?user_id=1&min_amount=20&max_amount=100&sort_by=amount&order=desc

# Combine multiple filters
GET /api/expenses?user_id=1&category_id=1&search=restaurant&min_amount=30&sort_by=date&order=asc
```

## Testing

Added comprehensive test coverage:
- Unit tests for repository filtering logic
- Integration tests for API endpoints with various filter combinations

Fixes #3

