# Expense Tags (Multi-tag Support)

## Description

This PR implements comprehensive multi-tag support for expenses, allowing users to add multiple tags to expenses and filter expenses by tags. The implementation includes tag normalization, validation, and filtering capabilities.

## What's New

Users can now:

- **Add multiple tags to expenses**: Support tags as arrays or comma-separated strings
- **Automatic tag normalization**: Tags are automatically trimmed, deduplicated, and normalized
- **Filter expenses by tags**: Filter expenses by single or multiple tags
- **Case-insensitive matching**: Tag filtering works regardless of case
- **Combine filters**: Tag filtering can be combined with existing filters (category, date range, amount, etc.)

## Implementation Details

### Model Layer

Enhanced `Expense` model with:
- `normalize_tags` method that handles:
  - Array input: `['food', 'restaurant']`
  - Comma-separated string: `'food, restaurant, lunch'`
  - Single value: `'food'`
  - Edge cases: nil, empty strings, empty arrays
  - Automatic trimming of whitespace
  - Removal of duplicate tags

### Repository Layer

Enhanced `ExpenseRepository#find_by_user` with tag filtering:
- Filter by single tag: returns expenses that have the specified tag
- Filter by multiple tags: returns expenses that have ALL specified tags (AND logic)
- Case-insensitive tag matching
- Works seamlessly with existing filters

### Service Layer

Updated `ExpenseService`:
- Tags are automatically normalized when creating expenses
- Tags are normalized when updating expenses
- Tag filters are passed to repository

### Controller Layer

Updated `ExpenseController`:
- Parses tag filters from query parameters
- Handles comma-separated tag strings
- Normalizes tag filters before passing to service

### API Routes

Updated `lib/app.rb`:
- `parse_filters` method now handles `tags` query parameter
- Supports tags as array or comma-separated string

## API Endpoints

### Create Expense with Tags
```bash
POST /api/expenses
Content-Type: application/json

{
  "amount": 50.00,
  "description": "Lunch at restaurant",
  "category_id": 1,
  "user_id": 1,
  "tags": ["food", "restaurant", "lunch"]
}
```

Or with comma-separated string:
```json
{
  "amount": 50.00,
  "description": "Lunch at restaurant",
  "category_id": 1,
  "user_id": 1,
  "tags": "food, restaurant, lunch"
}
```

### Filter Expenses by Tags
```bash
# Filter by single tag
GET /api/expenses?user_id=1&tags=food

# Filter by multiple tags (expense must have all)
GET /api/expenses?user_id=1&tags=food,restaurant

# Combine with other filters
GET /api/expenses?user_id=1&tags=food&min_amount=50&category_id=1
```

### Update Expense Tags
```bash
PUT /api/expenses/:id
Content-Type: application/json

{
  "tags": ["food", "dinner"]
}
```

### Response Format

Expense objects now include tags:
```json
{
  "id": 1,
  "amount": 50.00,
  "date": "2025-01-15",
  "description": "Lunch at restaurant",
  "category_id": 1,
  "user_id": 1,
  "tags": ["food", "restaurant", "lunch"],
  "created_at": "2025-01-15T10:00:00Z"
}
```

## Testing

Added comprehensive test coverage:

- **Unit tests (8 tests)** for `Expense` model tag normalization:
  - Handles array of tags
  - Handles comma-separated string tags
  - Removes duplicate tags
  - Trims whitespace from tags
  - Handles empty tags
  - Handles nil tags
  - Handles empty string tags
  - Includes tags in hash representation

- **Repository test (1 test)** for tag filtering:
  - Filter by single tag
  - Filter by multiple tags (AND logic)
  - Filter by non-existent tag

- **Integration tests (6 tests)**:
  - **P2P (2 tests)**: Expense Tags Support
    - Add tags to expense and retrieve them
    - Handle comma-separated string tags
  - **F2P (4 tests)**: Filter Expenses by Tags
    - Filter expenses by single tag
    - Filter expenses by multiple tags (must have all)
    - Return empty array when no expenses match tags
    - Combine tag filter with other filters

All tests pass.

## Implementation Notes

- Tag normalization happens automatically in the `Expense` model constructor
- Tag filtering uses case-insensitive matching for better user experience
- Multiple tags in filter use AND logic (expense must have all specified tags)
- Tags are always stored as arrays internally, but accept various input formats
- Tag filtering integrates seamlessly with existing filters (category, date range, amount, search, sorting)
- Empty or nil tags are normalized to empty arrays

Fixes #9

