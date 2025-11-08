# Expense Export (CSV/JSON)

## Description

This PR implements expense export functionality, allowing users to export their expense data in both CSV and JSON formats. The implementation includes filtering support, proper formatting, and comprehensive test coverage.

## What's New

Users can now:

- **Export expenses to CSV**: Download expense data as CSV files for spreadsheet applications
- **Export expenses to JSON**: Download expense data as JSON for programmatic use
- **Filter exports**: Apply the same filters as the expense listing endpoint (category, date range, amount range)
- **Proper formatting**: CSV includes headers and proper escaping; JSON is well-structured
- **Empty result handling**: Gracefully handles cases with no matching expenses

## Implementation Details

### Service Layer

Created `ExportService` with:
- **CSV Export**: `export_to_csv(user_id, filters = {})`
  - Generates CSV with header row
  - Includes all expense fields: id, amount, date, description, category_id, user_id, tags, currency, created_at
  - Properly escapes special characters and commas
  - Handles tags as comma-separated values within quotes
  - Formats dates as YYYY-MM-DD
  - Formats amounts with 2 decimal places

- **JSON Export**: `export_to_json(user_id, filters = {})`
  - Generates JSON array of expense objects
  - Includes all expense fields
  - Tags as JSON array
  - Pretty-printed for readability

- **Data Retrieval**: `get_expenses_for_export(user_id, filters)`
  - Reuses ExpenseRepository for consistency
  - Applies same filtering logic as expense listing
  - Returns array of Expense objects

### Controller Layer

Created `ExportController` with:
- **CSV Endpoint**: `csv_export(user_id, filters)`
  - Sets content-type: `text/csv; charset=utf-8`
  - Returns CSV string
  - Handles errors gracefully

- **JSON Endpoint**: `json_export(user_id, filters)`
  - Sets content-type: `application/json; charset=utf-8`
  - Returns JSON string
  - Handles errors gracefully

### API Endpoints

#### CSV Export
```bash
GET /api/export/csv?user_id=1
GET /api/export/csv?user_id=1&category_id=1&start_date=2025-01-01&end_date=2025-01-31
```

Response:
```
Content-Type: text/csv; charset=utf-8

id,amount,date,description,category_id,user_id,tags,currency,created_at
1,50.00,2025-01-15,Lunch at restaurant,1,1,"food,dining",USD,2025-01-15 10:30:00
2,100.00,2025-01-20,Dinner,2,1,"dining",USD,2025-01-20 18:00:00
```

#### JSON Export
```bash
GET /api/export/json?user_id=1
GET /api/export/json?user_id=1&category_id=1&start_date=2025-01-01&end_date=2025-01-31
```

Response:
```json
Content-Type: application/json; charset=utf-8

[
  {
    "id": 1,
    "amount": 50.00,
    "date": "2025-01-15",
    "description": "Lunch at restaurant",
    "category_id": 1,
    "user_id": 1,
    "tags": ["food", "dining"],
    "currency": "USD",
    "created_at": "2025-01-15 10:30:00"
  },
  {
    "id": 2,
    "amount": 100.00,
    "date": "2025-01-20",
    "description": "Dinner",
    "category_id": 2,
    "user_id": 1,
    "tags": ["dining"],
    "currency": "USD",
    "created_at": "2025-01-20 18:00:00"
  }
]
```

### Supported Filters

- `user_id` (required): Filter by user ID
- `category_id` (optional): Filter by category
- `start_date` (optional): Filter expenses from this date (YYYY-MM-DD)
- `end_date` (optional): Filter expenses to this date (YYYY-MM-DD)
- `min_amount` (optional): Minimum expense amount
- `max_amount` (optional): Maximum expense amount

## Testing

Added comprehensive test coverage:

- **Unit tests (8 tests)** for `ExportService`:
  - CSV export with various expense data
  - JSON export with various expense data
  - CSV header generation
  - CSV special character escaping
  - Tags serialization (CSV and JSON)
  - Filtering logic
  - Empty result handling
  - Date and amount formatting

- **Integration tests (3 tests)**:
  - **P2P (1 test)**: CSV Export Workflow
    - Create expenses
    - Export to CSV
    - Verify CSV format, headers, and content
    - Verify all expense fields are included
  
  - **F2P (2 tests)**: Filtered Export
    - Create expenses with different categories and dates
    - Export CSV with filters (category, date range)
    - Export JSON with filters
    - Verify only matching expenses are exported
    - Verify both formats work correctly

All tests pass.

## Implementation Notes

- CSV export uses proper escaping for fields containing commas or quotes
- Tags are serialized as comma-separated values in CSV (within quotes) and as JSON arrays in JSON
- Dates are consistently formatted as YYYY-MM-DD
- Amounts are formatted with 2 decimal places
- Empty result sets return header-only CSV or empty JSON array
- Filtering logic matches the expense listing endpoint for consistency
- Content-type headers are set correctly for browser download support
- ExportService reuses ExpenseRepository to maintain data consistency

Fixes #11

