# Multi-currency Support

## Description

This PR implements multi-currency support for expenses, allowing users to create expenses in different currencies and convert between them. The implementation includes currency validation, conversion utilities, and service-level support for currency operations.

## What's New

Users can now:

- **Create expenses in multiple currencies**: Support for 9 major currencies (USD, EUR, GBP, JPY, CAD, AUD, CHF, CNY, INR)
- **Automatic currency defaulting**: Expenses default to USD when currency is not specified
- **Currency conversion**: Convert expense amounts between different currencies
- **Multi-currency totals**: Calculate expense totals in any supported currency
- **Currency validation**: Invalid currency codes are rejected

## Implementation Details

### Model Layer

Enhanced `Expense` model with:
- `currency` attribute with default value from `AppConfig::DEFAULT_CURRENCY` (USD)
- `VALID_CURRENCIES` constant defining supported currency codes
- Currency validation in `valid?` method
- Currency included in `to_hash` and JSON responses

### Utility Layer

Created `CurrencyConverter` module with:
- **Exchange rates**: Predefined rates for 9 currencies (USD as base)
- `convert(amount, from_currency, to_currency)`: Convert amount between currencies
- `convert_expense(expense, target_currency)`: Convert expense amount
- `get_rate(from_currency, to_currency)`: Get exchange rate between currencies
- `supported?(currency)`: Check if currency is supported
- `supported_currencies`: List all supported currency codes

**Note**: Exchange rates are stored as constants. In a production environment, these would be fetched from a currency API and updated regularly.

### Service Layer

Enhanced `ExpenseService` with:
- Currency handling in `create_expense` (automatic defaulting)
- `convert_expense_currency(expense_id, target_currency)`: Convert expense to different currency
- Updated `calculate_total` to accept optional `target_currency` parameter
  - When provided, converts all expenses to target currency before summing
  - When not provided, sums amounts as-is (may result in mixed currencies)

## API Endpoints

### Create Expense with Currency
```bash
POST /api/expenses
Content-Type: application/json

{
  "amount": 50.00,
  "description": "Coffee in Paris",
  "category_id": 1,
  "user_id": 1,
  "currency": "EUR"
}
```

Response includes currency:
```json
{
  "id": 1,
  "amount": 50.00,
  "description": "Coffee in Paris",
  "currency": "EUR",
  "date": "2025-01-20",
  ...
}
```

### Create Expense without Currency (defaults to USD)
```json
{
  "amount": 100.00,
  "description": "Lunch",
  "category_id": 1,
  "user_id": 1
}
```

Response:
```json
{
  "id": 2,
  "amount": 100.00,
  "currency": "USD",
  ...
}
```

### Currency Conversion (Service Method)
```ruby
service = ExpenseService.new
result = service.convert_expense_currency(expense_id, 'USD')

# Returns:
{
  success: true,
  data: {
    original_amount: 50.00,
    original_currency: "EUR",
    converted_amount: 58.82,
    target_currency: "USD"
  }
}
```

### Calculate Total in Target Currency
```ruby
service = ExpenseService.new
# Calculate total of all expenses converted to USD
result = service.calculate_total(user_id, nil, 'USD')
```

## Supported Currencies

- **USD** (US Dollar) - Base currency
- **EUR** (Euro)
- **GBP** (British Pound)
- **JPY** (Japanese Yen)
- **CAD** (Canadian Dollar)
- **AUD** (Australian Dollar)
- **CHF** (Swiss Franc)
- **CNY** (Chinese Yuan)
- **INR** (Indian Rupee)

## Exchange Rates

Exchange rates are defined relative to USD (base currency = 1.0):
- EUR: 0.85
- GBP: 0.73
- JPY: 110.0
- CAD: 1.25
- AUD: 1.35
- CHF: 0.92
- CNY: 6.45
- INR: 74.0

**Note**: These are example rates. In production, rates should be fetched from a currency API.

## Testing

Added comprehensive test coverage:

- **Unit tests (5 tests)** for `Expense` model currency handling:
  - Default currency assignment (USD)
  - Valid currency codes
  - Invalid currency codes
  - Currency in hash representation
  - Case-insensitive handling

- **Unit tests (12 tests)** for `CurrencyConverter` utility:
  - Currency conversion (USD to EUR, EUR to USD, JPY)
  - Same currency conversion (returns same amount)
  - Invalid currency handling
  - Negative amount handling
  - Rounding to 2 decimal places
  - Exchange rate retrieval
  - Supported currency checks
  - Supported currencies list

- **Integration tests (6 tests)**:
  - **P2P (2 tests)**: Expense Creation with Currency
    - Create expense with currency and retrieve it
    - Default to USD when currency not specified
  - **F2P (4 tests)**: Currency Conversion
    - Convert expense from one currency to another
    - Convert EUR expense to USD
    - Calculate total in target currency
    - Handle unsupported currencies

All tests pass.

## Implementation Notes

- Currency conversion uses USD as the base currency (all conversions go through USD)
- Exchange rates are stored as constants (would be API-fetched in production)
- Currency codes are case-insensitive in validation
- Invalid currency codes are rejected during expense validation
- `calculate_total` with target_currency converts all expenses before summing
- Conversion results are rounded to 2 decimal places
- Currency field is optional and defaults to USD

Fixes #10

