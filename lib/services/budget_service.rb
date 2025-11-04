require_relative '../repositories/expense_repository'
require_relative '../repositories/budget_repository'
require_relative '../models/budget'
require_relative '../utils/validators'
require 'date'

# Service layer for budget tracking and management
class BudgetService
  def initialize(expense_repo = ExpenseRepository.new, budget_repo = BudgetRepository.new)
    @expense_repository = expense_repo
    @budget_repository = budget_repo
  end

  def create_budget(params)
    budget = Budget.new(params)
    return { success: false, errors: ['Invalid budget data'] } unless budget.valid?
    
    # Validate dates
    return { success: false, errors: ['Invalid date range'] } unless Validators.validate_date_range(params[:period_start], params[:period_end])
    
    result = @budget_repository.create(budget)
    { success: true, data: result }
  rescue StandardError => e
    { success: false, errors: [e.message] }
  end

  def update_budget(id, params)
    budget = @budget_repository.find_by_id(id)
    return { success: false, errors: ['Budget not found'] } if budget.nil?

    params.each do |key, value|
      budget.send("#{key}=", value) if budget.respond_to?("#{key}=")
    end

    return { success: false, errors: ['Invalid budget data'] } unless budget.valid?

    result = @budget_repository.update(budget)
    { success: true, data: result }
  rescue StandardError => e
    { success: false, errors: [e.message] }
  end

  def delete_budget(id)
    budget = @budget_repository.find_by_id(id)
    return { success: false, errors: ['Budget not found'] } if budget.nil?

    @budget_repository.delete(id)
    { success: true }
  rescue StandardError => e
    { success: false, errors: [e.message] }
  end

  def get_budget(id)
    budget = @budget_repository.find_by_id(id)
    return { success: false, errors: ['Budget not found'] } if budget.nil?
    { success: true, data: budget }
  end

  def list_budgets(user_id)
    budgets = @budget_repository.find_by_user(user_id)
    { success: true, data: budgets }
  end

  def calculate_spending_for_category(user_id, category_id, start_date, end_date)
    expenses = @expense_repository.find_by_user(user_id)
    category_expenses = expenses.select do |e|
      expense_date = e.date.is_a?(Date) ? e.date : Date.parse(e.date.to_s)
      start = start_date.is_a?(Date) ? start_date : Date.parse(start_date.to_s)
      end_dt = end_date.is_a?(Date) ? end_date : Date.parse(end_date.to_s)
      e.category_id == category_id && expense_date >= start && expense_date <= end_dt
    end
    category_expenses.sum(&:amount)
  end

  def check_budget_status(budget, user_id)
    return { success: false, errors: ['Invalid budget'] } unless budget.valid?

    spending = calculate_spending_for_category(user_id, budget.category_id, budget.period_start, budget.period_end)
    remaining = budget.amount - spending
    percentage_used = (spending.to_f / budget.amount.to_f * 100).round(2)
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

