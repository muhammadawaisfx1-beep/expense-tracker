# Issue #9: Add Multi-tag Support for Expenses

## Description

Currently, expenses support a basic `tags` attribute, but there's no comprehensive support for multi-tag functionality including tag normalization, validation, and filtering. This issue adds full multi-tag support to the expense tracking system.

## Requirements

1. **Tag Normalization**: 
   - Support tags as arrays or comma-separated strings
   - Automatically normalize tags (trim whitespace, remove duplicates)
   - Handle edge cases (nil, empty strings, empty arrays)

2. **Tag Filtering**:
   - Filter expenses by single tag
   - Filter expenses by multiple tags (expense must have all specified tags)
   - Case-insensitive tag matching
   - Combine tag filtering with existing filters (category, date range, amount, etc.)

3. **Tag Management**:
   - Add tags when creating expenses
   - Update tags when updating expenses
   - Tags should be included in expense JSON responses

## Implementation Details

### Model Layer
- Enhance `Expense` model with `normalize_tags` method
- Handle tag input as array, comma-separated string, or single value
- Automatically trim whitespace and remove duplicates

### Repository Layer
- Add tag filtering to `ExpenseRepository#find_by_user`
- Support filtering by single or multiple tags
- Case-insensitive tag matching

### Service Layer
- Ensure tags are normalized when creating/updating expenses
- Pass tag filters to repository

### Controller Layer
- Parse tag filters from query parameters
- Support comma-separated tag strings in URL parameters

### API Changes
- `POST /api/expenses` - Accept `tags` as array or comma-separated string
- `PUT /api/expenses/:id` - Accept `tags` for updates
- `GET /api/expenses?tags=food,restaurant` - Filter by tags

## Expected Behavior

### Creating Expense with Tags
```json
POST /api/expenses
{
  "amount": 50.00,
  "description": "Lunch",
  "category_id": 1,
  "user_id": 1,
  "tags": ["food", "restaurant", "lunch"]
}
```

Response includes normalized tags:
```json
{
  "id": 1,
  "amount": 50.00,
  "description": "Lunch",
  "tags": ["food", "restaurant", "lunch"],
  ...
}
```

### Filtering by Tags
```bash
# Single tag
GET /api/expenses?user_id=1&tags=food

# Multiple tags (expense must have all)
GET /api/expenses?user_id=1&tags=food,restaurant

# Combine with other filters
GET /api/expenses?user_id=1&tags=food&min_amount=50
```

## Test Requirements

- **Unit Tests (3+)**: Test tag normalization in Expense model
  - Array input
  - Comma-separated string input
  - Edge cases (nil, empty, duplicates, whitespace)

- **P2P Test (1)**: Add tags to expense and retrieve them
  - Create expense with tags
  - Retrieve expense and verify tags
  - Update expense tags

- **F2P Test (1)**: Filter expenses by tags
  - Filter by single tag
  - Filter by multiple tags
  - Combine tag filter with other filters

## Acceptance Criteria

- [x] Expenses can be created with tags (array or comma-separated string)
- [x] Tags are automatically normalized (trimmed, deduplicated)
- [x] Expenses can be filtered by single tag
- [x] Expenses can be filtered by multiple tags (AND logic)
- [x] Tag filtering is case-insensitive
- [x] Tag filtering can be combined with other filters
- [x] Tags are included in expense JSON responses
- [x] All tests pass

## Related Files

- `lib/models/expense.rb` - Add tag normalization
- `lib/repositories/expense_repository.rb` - Add tag filtering
- `lib/services/expense_service.rb` - Ensure tag normalization
- `lib/controllers/expense_controller.rb` - Parse tag filters
- `lib/app.rb` - Handle tag query parameters

