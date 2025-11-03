# Expense Tracker - Usage Guide

## Quick Start

### 1. Start the Server

Open a terminal and run:

```powershell
cd "C:\Users\hp probook 450 g8\source\repos\.F25 CV\BSAI23015_Abdulrahman_03\expense-tracker"
bundle exec rackup config.ru
```

The server will start on `http://localhost:9292`

**Keep this terminal window open** - the server runs until you press `Ctrl+C`

### 2. Use the API

Open **another terminal window** to make requests. You can use:

- **PowerShell** (Invoke-WebRequest)
- **curl** (if installed)
- **Web browser** (for GET requests)
- **The provided test script** (bin/test_api.rb)

---

## Examples: Using PowerShell

### Create a Category

```powershell
$body = @{
    name = "Food & Dining"
    budget_limit = 500
    user_id = 1
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:9292/api/categories" `
    -Method POST `
    -ContentType "application/json" `
    -Body $body
```

### Create an Expense

```powershell
$body = @{
    amount = 45.50
    date = "2025-01-15"
    description = "Lunch at restaurant"
    category_id = 1
    user_id = 1
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:9292/api/expenses" `
    -Method POST `
    -ContentType "application/json" `
    -Body $body
```

### List All Expenses

```powershell
Invoke-WebRequest -Uri "http://localhost:9292/api/expenses?user_id=1" | 
    Select-Object -ExpandProperty Content | 
    ConvertFrom-Json | 
    ConvertTo-Json -Depth 10
```

### Get Monthly Report

```powershell
Invoke-WebRequest -Uri "http://localhost:9292/api/reports/monthly?user_id=1&year=2025&month=1" | 
    Select-Object -ExpandProperty Content | 
    ConvertFrom-Json | 
    ConvertTo-Json -Depth 10
```

### Calculate Total Expenses

```powershell
Invoke-WebRequest -Uri "http://localhost:9292/api/expenses/1/total" | 
    Select-Object -ExpandProperty Content
```

---

## Examples: Using curl

If you have curl installed:

### Create Category
```bash
curl -X POST http://localhost:9292/api/categories \
  -H "Content-Type: application/json" \
  -d '{"name":"Food & Dining","budget_limit":500,"user_id":1}'
```

### Create Expense
```bash
curl -X POST http://localhost:9292/api/expenses \
  -H "Content-Type: application/json" \
  -d '{"amount":45.50,"date":"2025-01-15","description":"Lunch","category_id":1,"user_id":1}'
```

### List Expenses
```bash
curl http://localhost:9292/api/expenses?user_id=1
```

---

## Using in Browser

You can view GET endpoints directly in your browser:

- Health: http://localhost:9292/health
- List Categories: http://localhost:9292/api/categories?user_id=1
- List Expenses: http://localhost:9292/api/expenses?user_id=1
- Monthly Report: http://localhost:9292/api/reports/monthly?user_id=1&year=2025&month=1

---

## All Available Endpoints

### Categories
- `GET /api/categories?user_id=1` - List all categories
- `POST /api/categories` - Create a category
- `GET /api/categories/:id` - Get a specific category
- `PUT /api/categories/:id` - Update a category
- `DELETE /api/categories/:id` - Delete a category

### Expenses
- `GET /api/expenses?user_id=1` - List all expenses (with optional filters)
- `POST /api/expenses` - Create an expense
- `GET /api/expenses/:id` - Get a specific expense
- `PUT /api/expenses/:id` - Update an expense
- `DELETE /api/expenses/:id` - Delete an expense
- `GET /api/expenses/:user_id/total` - Calculate total expenses

### Reports
- `GET /api/reports/monthly?user_id=1&year=2025&month=1` - Monthly report
- `GET /api/reports/yearly?user_id=1&year=2025` - Yearly report
- `GET /api/reports/category/:category_id?user_id=1` - Category report

### Health
- `GET /health` - Check if server is running

---

## Tips

1. **User ID**: Most endpoints require `user_id`. For now, use `user_id=1` for testing.

2. **Date Format**: Use `YYYY-MM-DD` format (e.g., `2025-01-15`)

3. **JSON Format**: Make sure to send valid JSON with proper Content-Type header

4. **View Responses**: PowerShell responses are easier to read if you pipe to `ConvertFrom-Json | ConvertTo-Json -Depth 10`

5. **Test Script**: Run `ruby bin/test_api.rb` to test all endpoints at once

---

## Sample Workflow

1. **Create a category**:
   ```powershell
   $cat = @{name="Groceries";budget_limit=300;user_id=1} | ConvertTo-Json
   Invoke-WebRequest -Uri "http://localhost:9292/api/categories" -Method POST -ContentType "application/json" -Body $cat
   ```
   Note the `id` from the response.

2. **Add expenses**:
   ```powershell
   $exp = @{amount=25.99;date="2025-01-15";description="Weekly groceries";category_id=1;user_id=1} | ConvertTo-Json
   Invoke-WebRequest -Uri "http://localhost:9292/api/expenses" -Method POST -ContentType "application/json" -Body $exp
   ```

3. **View your expenses**:
   ```powershell
   Invoke-WebRequest -Uri "http://localhost:9292/api/expenses?user_id=1"
   ```

4. **Get a report**:
   ```powershell
   Invoke-WebRequest -Uri "http://localhost:9292/api/reports/monthly?user_id=1&year=2025&month=1"
   ```

