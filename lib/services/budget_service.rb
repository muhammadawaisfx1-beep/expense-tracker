require_relative '../repositories/expense_repository'
require_relative '../models/budget'
require 'date'

# Service layer for budget tracking and management
class BudgetService
  def initialize(expense_repo = ExpenseRepository.new)
    @expense_repository = expense_repo
  end

  def calculate_spending_for_category(user_id, category_id, start_date, end_date)
    expenses = @expense_repository.find_by_user(user_id)
    category_expenses = expenses.select do |e|
      e.category_id == category_id && e.date >= start_date && e.date <= end_date
    end
    category_expenses.sum(&:amount)
  end

  def check_budget_status(budget, user_id)
    return { success: false, errors: ['Invalid budget'] } unless budget.valid?

    spending = calculate_spending_for_category(user_id, budget.category_id, budget.period_start, budget.period_end)
    remaining = budget.amount - spending
    percentage_used = (spending / budget.amount * 100).round(2)
    exceeded = spending > budget.amount

    {
      success: true,
      data: {
        budget: budget.to_hash,
        spending: spending,
        remaining: remaining,
        percentage_used: percentage_used,
        exceeded: exceeded
      }
    }
  end

  def get_budgets_exceeding_limit(user_id, budgets)
    exceeded_budgets = []
    budgets.each do |budget|
      next unless budget.user_id == user_id

      spending = calculate_spending_for_category(user_id, budget.category_id, budget.period_start, budget.period_end)
      exceeded_budgets << budget if spending > budget.amount
    end
    exceeded_budgets
  end

  def get_budgets_near_limit(user_id, budgets, threshold_percent = 80)
    near_limit_budgets = []
    budgets.each do |budget|
      next unless budget.user_id == user_id

      spending = calculate_spending_for_category(user_id, budget.category_id, budget.period_start, budget.period_end)
      percentage = (spending / budget.amount * 100)
      near_limit_budgets << budget if percentage >= threshold_percent && spending <= budget.amount
    end
    near_limit_budgets
  end
end

