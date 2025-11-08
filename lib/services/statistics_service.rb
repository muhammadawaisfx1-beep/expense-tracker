require_relative '../repositories/expense_repository'
require_relative '../repositories/category_repository'
require 'date'

# Service layer for expense statistics and analytics
class StatisticsService
  def initialize(expense_repo = ExpenseRepository.new, category_repo = CategoryRepository.new)
    @expense_repository = expense_repo
    @category_repository = category_repo
  end

  def get_statistics(user_id, date_range = nil)
    # Get expenses for user
    expenses = @expense_repository.find_by_user(user_id)

    # Apply date range filter if provided
    if date_range && date_range[:start] && date_range[:end]
      expenses = expenses.select do |e|
        expense_date = e.date.is_a?(Date) ? e.date : Date.parse(e.date.to_s)
        expense_date >= date_range[:start] && expense_date <= date_range[:end]
      end
    end

    # Calculate statistics
    summary = calculate_summary(expenses)
    trends = calculate_trends(expenses, date_range)
    category_breakdown = calculate_category_breakdown(expenses)
    currency_breakdown = calculate_currency_breakdown(expenses)

    # Determine actual date range
    actual_date_range = determine_date_range(expenses, date_range)

    {
      user_id: user_id,
      date_range: actual_date_range,
      summary: summary,
      trends: trends,
      category_breakdown: category_breakdown,
      currency_breakdown: currency_breakdown
    }
  end

  private

  def calculate_summary(expenses)
    return {
      total_spending: 0.0,
      average_expense: 0.0,
      largest_expense: 0.0,
      smallest_expense: 0.0,
      expense_count: 0
    } if expenses.empty?

    amounts = expenses.map(&:amount)
    total = amounts.sum
    count = expenses.count

    {
      total_spending: total.round(2),
      average_expense: (total / count).round(2),
      largest_expense: amounts.max.round(2),
      smallest_expense: amounts.min.round(2),
      expense_count: count
    }
  end

  def calculate_trends(expenses, date_range)
    return {
      daily_average: 0.0,
      weekly_average: 0.0,
      monthly_average: 0.0
    } if expenses.empty?

    total = expenses.sum(&:amount)

    # Determine date range
    if date_range && date_range[:start] && date_range[:end]
      start_date = date_range[:start]
      end_date = date_range[:end]
    else
      dates = expenses.map { |e| e.date.is_a?(Date) ? e.date : Date.parse(e.date.to_s) }
      start_date = dates.min
      end_date = dates.max
    end

    days = (end_date - start_date).to_i + 1
    weeks = (days.to_f / 7.0).ceil
    # Calculate months more accurately
    year_diff = end_date.year - start_date.year
    month_diff = end_date.month - start_date.month
    months = year_diff * 12 + month_diff + 1
    months = 1 if months < 1

    {
      daily_average: days > 0 ? (total / days).round(2) : 0.0,
      weekly_average: weeks > 0 ? (total / weeks).round(2) : 0.0,
      monthly_average: months > 0 ? (total / months).round(2) : 0.0
    }
  end

  def calculate_category_breakdown(expenses)
    return [] if expenses.empty?

    total = expenses.sum(&:amount)
    return [] if total.zero?

    # Group by category
    by_category = expenses.group_by(&:category_id)

    breakdown = by_category.map do |category_id, category_expenses|
      category_amount = category_expenses.sum(&:amount)
      category = @category_repository.find_by_id(category_id)
      category_name = category ? category.name : "Unknown Category"

      {
        category_id: category_id,
        category_name: category_name,
        amount: category_amount.round(2),
        percentage: ((category_amount / total) * 100).round(2)
      }
    end

    # Sort by amount descending
    breakdown.sort_by { |item| -item[:amount] }
  end

  def calculate_currency_breakdown(expenses)
    return [] if expenses.empty?

    total = expenses.sum(&:amount)
    return [] if total.zero?

    # Group by currency
    by_currency = expenses.group_by { |e| e.currency || 'USD' }

    breakdown = by_currency.map do |currency, currency_expenses|
      currency_amount = currency_expenses.sum(&:amount)

      {
        currency: currency,
        amount: currency_amount.round(2),
        percentage: ((currency_amount / total) * 100).round(2)
      }
    end

    # Sort by amount descending
    breakdown.sort_by { |item| -item[:amount] }
  end

  def determine_date_range(expenses, date_range)
    if date_range && date_range[:start] && date_range[:end]
      {
        start: date_range[:start].strftime('%Y-%m-%d'),
        end: date_range[:end].strftime('%Y-%m-%d')
      }
    elsif expenses.empty?
      {
        start: nil,
        end: nil
      }
    else
      dates = expenses.map { |e| e.date.is_a?(Date) ? e.date : Date.parse(e.date.to_s) }
      {
        start: dates.min.strftime('%Y-%m-%d'),
        end: dates.max.strftime('%Y-%m-%d')
      }
    end
  end
end

