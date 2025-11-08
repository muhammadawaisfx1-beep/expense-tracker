# Issue #11: Export Expenses to CSV and JSON Formats

## Description

Currently, users can view expenses through the API, but there is no way to export expense data for external use, analysis, or backup purposes. This issue adds export functionality that allows users to export their expenses in both CSV and JSON formats with optional filtering.

## Requirements

1. **CSV Export**:
   - Export expenses to CSV format
   - Include all expense fields: id, amount, date, description, category_id, user_id, tags, currency, created_at
   - Support proper CSV formatting with headers
   - Handle special characters and commas in data

2. **JSON Export**:
   - Export expenses to JSON format
   - Include all expense fields in structured format
   - Support pretty-printing for readability

3. **Filtering Support**:
   - Support filtering by user_id (required)
   - Optional filters: category_id, start_date, end_date, min_amount, max_amount
   - Apply same filtering logic as expense listing endpoint

4. **Service Layer**:
   - Create ExportService to handle export logic
   - Separate methods for CSV and JSON export
   - Reuse ExpenseRepository for data retrieval
   - Handle empty result sets gracefully

5. **API Endpoints**:
   - `GET /api/export/csv?user_id=X&[filters]` - Export to CSV
   - `GET /api/export/json?user_id=X&[filters]` - Export to JSON
   - Return appropriate content-type headers
   - Support download via browser or API client

## Implementation Details

### Service Layer

Create `ExportService` with:
- `export_to_csv(user_id, filters = {})` - Generate CSV string from expenses
- `export_to_json(user_id, filters = {})` - Generate JSON string from expenses
- `get_expenses_for_export(user_id, filters)` - Retrieve and filter expenses
- Handle date formatting consistently
- Handle tags array serialization (CSV: comma-separated, JSON: array)
- Handle currency field inclusion

### Controller Layer

Create `ExportController` with:
- `csv_export(user_id, filters)` - Handle CSV export request
- `json_export(user_id, filters)` - Handle JSON export request
- Set appropriate content-type headers:
  - CSV: `text/csv; charset=utf-8`
  - JSON: `application/json; charset=utf-8`
- Return proper HTTP status codes

### CSV Format

CSV should include header row:
```
id,amount,date,description,category_id,user_id,tags,currency,created_at
1,50.00,2025-01-15,Lunch at restaurant,1,1,"food,dining",USD,2025-01-15 10:30:00
```

- Tags should be comma-separated within quotes if multiple
- Dates formatted as YYYY-MM-DD
- Amounts formatted with 2 decimal places
- Special characters properly escaped

### JSON Format

JSON should be an array of expense objects:
```json
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
  }
]
```

## Expected Behavior

### CSV Export
```bash
GET /api/export/csv?user_id=1
Content-Type: text/csv; charset=utf-8

id,amount,date,description,category_id,user_id,tags,currency,created_at
1,50.00,2025-01-15,Lunch,1,1,"food",USD,2025-01-15 10:30:00
2,100.00,2025-01-20,Dinner,2,1,"dining",USD,2025-01-20 18:00:00
```

### JSON Export
```bash
GET /api/export/json?user_id=1
Content-Type: application/json; charset=utf-8

[
  {
    "id": 1,
    "amount": 50.00,
    "date": "2025-01-15",
    "description": "Lunch",
    "category_id": 1,
    "user_id": 1,
    "tags": ["food"],
    "currency": "USD",
    "created_at": "2025-01-15 10:30:00"
  }
]
```

### Filtered Export
```bash
GET /api/export/csv?user_id=1&category_id=1&start_date=2025-01-01&end_date=2025-01-31
```

Returns only expenses matching the filters.

### Empty Result Set
When no expenses match the filters:
- CSV: Returns header row only
- JSON: Returns empty array `[]`

## Test Requirements

- **Unit Tests (3+)**: Test ExportService methods
  - CSV export with various expense data
  - JSON export with various expense data
  - Filtering logic
  - Empty result handling
  - Special character handling in CSV
  - Tags array serialization

- **P2P Test (1)**: Export to CSV workflow
  - Create expenses
  - Export to CSV
  - Verify CSV format and content
  - Verify all expense fields are included

- **F2P Test (1)**: Export filtered expenses
  - Create expenses with different categories and dates
  - Export with filters (category, date range)
  - Verify only matching expenses are exported
  - Test both CSV and JSON formats

## Acceptance Criteria

- [x] ExportService can export expenses to CSV format
- [x] ExportService can export expenses to JSON format
- [x] Export supports filtering by user_id and optional filters
- [x] CSV includes proper headers and formatting
- [x] JSON includes all expense fields in structured format
- [x] Empty result sets are handled gracefully
- [x] Special characters are properly escaped in CSV
- [x] Tags are properly serialized (CSV: comma-separated, JSON: array)
- [x] API endpoints return correct content-type headers
- [x] All tests pass

## Related Files

- `lib/services/export_service.rb` - Export service (new file)
- `lib/controllers/export_controller.rb` - Export controller (new file)
- `lib/app.rb` - Add export routes
- `spec/services/export_service_spec.rb` - Unit tests (new file)
- `spec/integration/export_workflow_spec.rb` - Integration tests (new file)

