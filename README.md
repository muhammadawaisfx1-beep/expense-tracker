# Expense Tracker

A Ruby-based expense tracking application for managing personal finances, budgeting, and financial reporting.

## Features

- **Expense Management**: Create, update, delete, and track expenses
- **Category Management**: Organize expenses by categories with budget limits
- **Budget Tracking**: Set budgets and monitor spending against limits
- **Reporting**: Generate monthly/yearly expense reports
- **Multi-currency Support**: Track expenses in different currencies
- **Recurring Expenses**: Set up automatic recurring expense entries

## Requirements

- Ruby 3.0 or higher
- SQLite3
- Bundler gem

## Setup

1. Install dependencies:
   ```bash
   bundle install
   ```

2. Initialize the database:
   ```bash
   ruby bin/setup_db
   ```

3. Run the application:
   ```bash
   bundle exec rackup config.ru
   ```

The application will be available at `http://localhost:9292`

4. Test the API (in a new terminal):
   ```bash
   ruby bin/test_api.rb
   ```

This will test all endpoints and show you which ones are working.

## Quick Usage Examples

### Add a Category
```bash
ruby bin/quick_add_category.rb "Food & Dining" 500
```

### Add an Expense
```bash
ruby bin/quick_add_expense.rb 45.50 "Lunch at restaurant" "2025-01-15" 1
```

### View in Browser
- Health: http://localhost:9292/health
- List Expenses: http://localhost:9292/api/expenses?user_id=1
- Monthly Report: http://localhost:9292/api/reports/monthly?user_id=1&year=2025&month=1

See `USAGE_GUIDE.md` for detailed examples with PowerShell and curl.

## Testing

Run the test suite:
```bash
bundle exec rspec
```

## Docker

Build and run with Docker:
```bash
docker-compose build
docker-compose up
```

## Project Structure

```
expense-tracker/
├── lib/              # Application code
│   ├── models/       # Data models
│   ├── services/     # Business logic
│   ├── controllers/  # API endpoints
│   ├── repositories/ # Data access layer
│   └── utils/        # Utility functions
├── spec/             # Test files
├── config/           # Configuration files
├── db/               # Database files
└── bin/              # Executable scripts
```

## License

Copyright (c) 2025 - Private Repository for SWE-Bench Training

