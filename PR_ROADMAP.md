# PR Roadmap - Expense Tracker

This document outlines the 20 planned PRs for the expense tracker repository.

## Completed PRs

### PR #1: Basic Expense Entry (Feature)
- **Issue**: Implement basic expense entry functionality
- **Changes**: Expense model, ExpenseService, ExpenseController, validators
- **Tests**: 3+ unit tests + 1 P2P + 1 F2P
- **Files Modified**: ~5 files, ~150 LOC

### PR #2: Category Management (Feature)
- **Issue**: Implement category management system
- **Changes**: Category model, CategoryService, CategoryController
- **Tests**: 3+ unit tests + 1 P2P + 1 F2P
- **Files Modified**: ~4 files, ~120 LOC

### PR #3: Expense Search and Filtering (Feature)
- **Issue**: Add search and filtering functionality for expenses
- **Changes**: Add search parameters to ExpenseRepository, ExpenseService, ExpenseController
- **Tests**: 3+ unit tests + 1 P2P test (search workflow) + 1 F2P test (filter by category)
- **Expected Files**: lib/repositories/expense_repository.rb, lib/services/expense_service.rb, lib/controllers/expense_controller.rb
- **Expected LOC**: ~80 lines

### PR #4: Monthly Expense Reports (Feature)
- **Issue**: Generate monthly expense reports
- **Changes**: Enhance ReportService with monthly report generation, add endpoint
- **Tests**: 3+ unit tests + 1 P2P test (generate monthly report) + 1 F2P test (report with filters)
- **Expected Files**: lib/services/report_service.rb, lib/controllers/report_controller.rb
- **Expected LOC**: ~100 lines

### PR #5: Yearly Expense Reports (Feature)
- **Issue**: Generate yearly expense reports with breakdown by month
- **Changes**: Add yearly report to ReportService, add endpoint
- **Tests**: 3+ unit tests + 1 P2P test (generate yearly report) + 1 F2P test (yearly report with category breakdown)
- **Expected Files**: lib/services/report_service.rb, lib/controllers/report_controller.rb
- **Expected LOC**: ~120 lines

### PR #6: Budget Creation and Tracking (Feature)
- **Issue**: Implement budget creation and tracking system
- **Changes**: Budget model enhancements, BudgetService implementation, BudgetController
- **Tests**: 3+ unit tests + 1 P2P test (create budget) + 1 F2P test (track budget status)
- **Expected Files**: lib/models/budget.rb, lib/services/budget_service.rb, lib/controllers/budget_controller.rb
- **Expected LOC**: ~150 lines

### PR #7: Budget Alerts/Notifications (Feature)
- **Issue**: Add budget alert system when spending approaches limit
- **Changes**: Add alert logic to BudgetService, notification endpoint
- **Tests**: 3+ unit tests + 1 P2P test (alert generation) + 1 F2P test (alert when approaching limit)
- **Expected Files**: lib/services/budget_service.rb, lib/controllers/budget_controller.rb
- **Expected LOC**: ~100 lines


## Planned PRs


### PR #8: Recurring Expenses (Feature)
- **Issue**: Support recurring expense entries
- **Changes**: Add RecurringExpense model, service, and controller
- **Tests**: 3+ unit tests + 1 P2P test (create recurring expense) + 1 F2P test (recurring expense auto-generation)
- **Expected Files**: lib/models/recurring_expense.rb, lib/services/recurring_expense_service.rb, lib/controllers/recurring_expense_controller.rb
- **Expected LOC**: ~180 lines

### PR #9: Expense Tags (Multi-tag Support) (Feature)
- **Issue**: Add multi-tag support for expenses
- **Changes**: Enhance Expense model with tag array handling, add tag filtering
- **Tests**: 3+ unit tests + 1 P2P test (add tags to expense) + 1 F2P test (filter by tags)
- **Expected Files**: lib/models/expense.rb, lib/services/expense_service.rb, lib/controllers/expense_controller.rb
- **Expected LOC**: ~90 lines

### PR #10: Multi-currency Support (Feature)
- **Issue**: Support expenses in multiple currencies
- **Changes**: Add currency field to Expense, currency conversion utilities
- **Tests**: 3+ unit tests + 1 P2P test (create expense with currency) + 1 F2P test (currency conversion)
- **Expected Files**: lib/models/expense.rb, lib/utils/currency_converter.rb, lib/services/expense_service.rb
- **Expected LOC**: ~140 lines

### PR #11: Expense Export (CSV/JSON) (Feature)
- **Issue**: Export expenses to CSV and JSON formats
- **Changes**: Add export service and endpoints
- **Tests**: 3+ unit tests + 1 P2P test (export to CSV) + 1 F2P test (export filtered expenses)
- **Expected Files**: lib/services/export_service.rb, lib/controllers/export_controller.rb
- **Expected LOC**: ~110 lines

### PR #12: Expense Statistics Dashboard (Feature)
- **Issue**: Create expense statistics and analytics dashboard
- **Changes**: Add statistics calculation service and dashboard endpoint
- **Tests**: 3+ unit tests + 1 P2P test (get statistics) + 1 F2P test (statistics with date range)
- **Expected Files**: lib/services/statistics_service.rb, lib/controllers/statistics_controller.rb
- **Expected LOC**: ~130 lines

### PR #13: Expense Approval Workflow (Feature)
- **Issue**: Add expense approval workflow for shared budgets
- **Changes**: Add approval status to Expense, approval service
- **Tests**: 3+ unit tests + 1 P2P test (approve expense) + 1 F2P test (workflow: submit -> approve)
- **Expected Files**: lib/models/expense.rb, lib/services/approval_service.rb
- **Expected LOC**: ~100 lines

### PR #14: Receipt Attachment System (Feature)
- **Issue**: Add receipt upload and attachment to expenses
- **Changes**: Add receipt storage, file handling utilities
- **Tests**: 3+ unit tests + 1 P2P test (upload receipt) + 1 F2P test (attach receipt to expense)
- **Expected Files**: lib/services/receipt_service.rb, lib/controllers/receipt_controller.rb
- **Expected LOC**: ~120 lines

---

## Bug Fixes

### PR #15: Fix Currency Conversion Rounding Errors (Bug)
- **Issue**: Currency conversion calculations have rounding errors
- **Changes**: Fix rounding logic in currency converter
- **Tests**: 3+ unit tests + 1 P2P test (accurate conversion) + 1 F2P test (multiple currency conversions)
- **Expected Files**: lib/utils/currency_converter.rb
- **Expected LOC**: ~40 lines

### PR #16: Fix Date Range Validation Edge Cases (Bug)
- **Issue**: Date range validation fails for edge cases (leap years, month boundaries)
- **Changes**: Improve date validation in validators and services
- **Tests**: 3+ unit tests + 1 P2P test (leap year dates) + 1 F2P test (month boundary dates)
- **Expected Files**: lib/utils/validators.rb, lib/utils/date_helper.rb
- **Expected LOC**: ~50 lines

### PR #17: Fix Negative Amount Handling (Bug)
- **Issue**: Application incorrectly handles negative amounts for refunds
- **Changes**: Update validation and calculation logic to support negative amounts for refunds
- **Tests**: 3+ unit tests + 1 P2P test (negative amount expense) + 1 F2P test (refund workflow)
- **Expected Files**: lib/utils/validators.rb, lib/models/expense.rb, lib/services/expense_service.rb
- **Expected LOC**: ~60 lines

### PR #18: Fix Duplicate Expense Detection (Bug)
- **Issue**: Duplicate expenses are not properly detected
- **Changes**: Add duplicate detection logic based on amount, date, and description
- **Tests**: 3+ unit tests + 1 P2P test (detect duplicate) + 1 F2P test (duplicate prevention workflow)
- **Expected Files**: lib/services/expense_service.rb
- **Expected LOC**: ~70 lines

### PR #19: Fix Budget Calculation Race Conditions (Bug)
- **Issue**: Concurrent budget calculations can produce incorrect totals
- **Changes**: Add synchronization for budget calculations
- **Tests**: 3+ unit tests + 1 P2P test (concurrent calculations) + 1 F2P test (accurate budget tracking)
- **Expected Files**: lib/services/budget_service.rb
- **Expected LOC**: ~50 lines

### PR #20: Fix Timezone Handling in Reports (Bug)
- **Issue**: Reports show incorrect dates due to timezone issues
- **Changes**: Fix timezone handling in date operations and reports
- **Tests**: 3+ unit tests + 1 P2P test (timezone conversion) + 1 F2P test (report with timezone)
- **Expected Files**: lib/services/report_service.rb, lib/utils/date_helper.rb
- **Expected LOC**: ~55 lines

---

## Compliance Notes

Each PR must:
- Link to GitHub Issue using format: `Fixes #X` or `Issue is #X`
- Include minimum 20 lines of code changes
- Have at least 3 unit tests
- Include at least 1 P2P (Peer-to-Peer) test
- Include at least 1 F2P (Feature-to-Feature) test
- Ensure all tests pass before merging
- Follow Ruby coding conventions
- Avoid all 11 early rejection reasons

