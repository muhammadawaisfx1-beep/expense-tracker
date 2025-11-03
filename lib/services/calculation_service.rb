require 'date'

# Service for financial calculations
class CalculationService
  def self.calculate_total(expenses)
    return 0.0 if expenses.nil? || expenses.empty?
    expenses.sum(&:amount)
  end

  def self.calculate_average(expenses)
    return 0.0 if expenses.nil? || expenses.empty?
    calculate_total(expenses) / expenses.count.to_f
  end

  def self.calculate_by_period(expenses, start_date, end_date)
    filtered = expenses.select { |e| e.date >= start_date && e.date <= end_date }
    {
      total: calculate_total(filtered),
      average: calculate_average(filtered),
      count: filtered.count
    }
  end

  def self.calculate_by_category(expenses)
    return {} if expenses.nil? || expenses.empty?
    expenses.group_by(&:category_id).transform_values { |exps| calculate_total(exps) }
  end

  def self.calculate_percentage(part, whole)
    return 0.0 if whole.nil? || whole.zero?
    (part / whole * 100).round(2)
  end

  def self.calculate_budget_remaining(budget_amount, spent)
    [budget_amount - spent, 0].max
  end

  def self.calculate_budget_usage_percentage(budget_amount, spent)
    return 0.0 if budget_amount.nil? || budget_amount.zero?
    calculate_percentage(spent, budget_amount)
  end

  def self.calculate_trend(current_period, previous_period)
    return 0.0 if previous_period.nil? || previous_period.zero?
    ((current_period - previous_period) / previous_period * 100).round(2)
  end
end

