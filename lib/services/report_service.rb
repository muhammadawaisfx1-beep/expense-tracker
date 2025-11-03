require_relative '../repositories/expense_repository'
require_relative '../repositories/category_repository'
require 'date'

# Service layer for report generation
class ReportService
  def initialize(expense_repo = ExpenseRepository.new, category_repo = CategoryRepository.new)
    @expense_repository = expense_repo
    @category_repository = category_repo
  end

  def generate_monthly_report(user_id, year, month)
    start_date = Date.new(year, month, 1)
    end_date = start_date.next_month.prev_day

    expenses = @expense_repository.find_by_user(user_id)
    monthly_expenses = expenses.select { |e| e.date >= start_date && e.date <= end_date }

    total = monthly_expenses.sum(&:amount)
    by_category = monthly_expenses.group_by(&:category_id).transform_values { |exps| exps.sum(&:amount) }

    {
      success: true,
      data: {
        period: "#{year}-#{month.to_s.rjust(2, '0')}",
        total: total,
        expense_count: monthly_expenses.count,
        by_category: by_category
      }
    }
  end

  def generate_yearly_report(user_id, year)
    start_date = Date.new(year, 1, 1)
    end_date = Date.new(year, 12, 31)

    expenses = @expense_repository.find_by_user(user_id)
    yearly_expenses = expenses.select { |e| e.date >= start_date && e.date <= end_date }

    total = yearly_expenses.sum(&:amount)
    by_month = (1..12).to_a.map do |month|
      month_expenses = yearly_expenses.select { |e| e.date.month == month }
      { month: month, total: month_expenses.sum(&:amount), count: month_expenses.count }
    end

    by_category = yearly_expenses.group_by(&:category_id).transform_values { |exps| exps.sum(&:amount) }

    {
      success: true,
      data: {
        year: year,
        total: total,
        expense_count: yearly_expenses.count,
        by_month: by_month,
        by_category: by_category
      }
    }
  end

  def generate_category_report(user_id, category_id, date_range = nil)
    category = @category_repository.find_by_id(category_id)
    return { success: false, errors: ['Category not found'] } if category.nil?

    expenses = @expense_repository.find_by_user(user_id)
    category_expenses = expenses.select { |e| e.category_id == category_id }

    if date_range
      category_expenses = category_expenses.select do |e|
        e.date >= date_range[:start] && e.date <= date_range[:end]
      end
    end

    total = category_expenses.sum(&:amount)
    budget_usage = category.budget_limit ? (total / category.budget_limit * 100) : nil

    {
      success: true,
      data: {
        category: category.name,
        total: total,
        expense_count: category_expenses.count,
        budget_limit: category.budget_limit,
        budget_usage_percent: budget_usage,
        expenses: category_expenses.map(&:to_hash)
      }
    }
  end
end

