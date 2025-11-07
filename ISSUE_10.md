# Issue #10: Support Expenses in Multiple Currencies

## Description

Currently, the expense tracker only supports a single currency (USD by default). This issue adds multi-currency support, allowing users to create expenses in different currencies and convert between them.

## Requirements

1. **Currency Field**: 
   - Add `currency` field to Expense model
   - Default to USD when not specified
   - Validate currency codes against supported list

2. **Currency Conversion**:
   - Create CurrencyConverter utility module
   - Support conversion between multiple currencies
   - Use USD as base currency for conversions
   - Support common currencies: USD, EUR, GBP, JPY, CAD, AUD, CHF, CNY, INR

3. **Service Layer Support**:
   - Update ExpenseService to handle currency in expense creation
   - Add method to convert expense amounts between currencies
   - Update calculate_total to support currency conversion

4. **API Support**:
   - Accept `currency` parameter when creating/updating expenses
   - Include `currency` in expense JSON responses
   - Support currency conversion operations

## Implementation Details

### Model Layer
- Add `currency` attribute to `Expense` model
- Add `VALID_CURRENCIES` constant
- Default currency to `AppConfig::DEFAULT_CURRENCY` (USD)
- Validate currency codes in `valid?` method
- Include currency in `to_hash` method

### Utility Layer
- Create `CurrencyConverter` module with:
  - `convert(amount, from_currency, to_currency)` - Convert amount between currencies
  - `convert_expense(expense, target_currency)` - Convert expense amount
  - `get_rate(from_currency, to_currency)` - Get exchange rate
  - `supported?(currency)` - Check if currency is supported
  - `supported_currencies` - List all supported currencies
- Use USD as base currency for all conversions
- Store exchange rates in a constant (in production, would fetch from API)

### Service Layer
- Update `ExpenseService#create_expense` to handle currency
- Add `convert_expense_currency(expense_id, target_currency)` method
- Update `calculate_total` to accept optional `target_currency` parameter
- Convert all expenses to target currency before summing when specified

## Expected Behavior

### Creating Expense with Currency
```json
POST /api/expenses
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
  ...
}
```

### Currency Conversion
```ruby
service = ExpenseService.new
result = service.convert_expense_currency(expense_id, 'USD')
# Returns:
# {
#   success: true,
#   data: {
#     original_amount: 50.00,
#     original_currency: "EUR",
#     converted_amount: 58.82,
#     target_currency: "USD"
#   }
# }
```

### Calculate Total in Target Currency
```ruby
service = ExpenseService.new
result = service.calculate_total(user_id, nil, 'USD')
# Converts all expenses to USD before summing
```

## Test Requirements

- **Unit Tests (3+)**: Test currency handling in Expense model
  - Default currency assignment
  - Valid currency codes
  - Invalid currency codes
  - Currency in hash representation

- **Unit Tests (3+)**: Test CurrencyConverter utility
  - Currency conversion calculations
  - Exchange rate retrieval
  - Supported currency checks
  - Edge cases (same currency, invalid currencies)

- **P2P Test (1)**: Create expense with currency and retrieve it
  - Create expense with specific currency
  - Verify currency is stored and returned
  - Default to USD when not specified

- **F2P Test (1)**: Currency conversion
  - Convert expense from one currency to another
  - Calculate total in target currency
  - Handle unsupported currencies

## Acceptance Criteria

- [x] Expenses can be created with currency field
- [x] Currency defaults to USD when not specified
- [x] Invalid currency codes are rejected
- [x] CurrencyConverter supports conversion between currencies
- [x] ExpenseService can convert expense amounts
- [x] calculate_total supports currency conversion
- [x] Currency is included in expense JSON responses
- [x] All tests pass

## Supported Currencies

- USD (US Dollar) - Base currency
- EUR (Euro)
- GBP (British Pound)
- JPY (Japanese Yen)
- CAD (Canadian Dollar)
- AUD (Australian Dollar)
- CHF (Swiss Franc)
- CNY (Chinese Yuan)
- INR (Indian Rupee)

## Related Files

- `lib/models/expense.rb` - Add currency field
- `lib/utils/currency_converter.rb` - Currency conversion utility (new file)
- `lib/services/expense_service.rb` - Currency handling in service layer
- `config/app.rb` - DEFAULT_CURRENCY constant (already exists)

