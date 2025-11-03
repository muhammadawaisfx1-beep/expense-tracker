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

