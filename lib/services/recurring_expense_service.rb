require_relative '../repositories/recurring_expense_repository'
require_relative '../repositories/expense_repository'
require_relative '../models/recurring_expense'
require_relative '../models/expense'
require_relative '../utils/validators'
require 'date'

# Service layer for recurring expense business logic
class RecurringExpenseService
  def initialize(recurring_repo = RecurringExpenseRepository.new, expense_repo = ExpenseRepository.new)
    @recurring_repository = recurring_repo
    @expense_repository = expense_repo
  end

  def create_recurring_expense(params)
    # Parse dates if they're strings
    params[:start_date] = Date.parse(params[:start_date]) if params[:start_date].is_a?(String)
    params[:end_date] = Date.parse(params[:end_date]) if params[:end_date].is_a?(String)
    params[:next_occurrence_date] = params[:start_date]

    recurring_expense = RecurringExpense.new(params)
    return { success: false, errors: ['Invalid recurring expense data'] } unless recurring_expense.valid?
    return { success: false, errors: ['Invalid amount'] } unless Validators.validate_amount(params[:amount])
    return { success: false, errors: ['Invalid frequency'] } unless RecurringExpense::VALID_FREQUENCIES.include?(params[:frequency].to_s.downcase)

    result = @recurring_repository.create(recurring_expense)
    { success: true, data: result }
  rescue StandardError => e
    { success: false, errors: [e.message] }
  end

  def update_recurring_expense(id, params)
    recurring_expense = @recurring_repository.find_by_id(id)
    return { success: false, errors: ['Recurring expense not found'] } if recurring_expense.nil?

    # Parse dates if they're strings
    params[:start_date] = Date.parse(params[:start_date]) if params[:start_date].is_a?(String)
    params[:end_date] = Date.parse(params[:end_date]) if params[:end_date].is_a?(String)

    params.each do |key, value|
      recurring_expense.send("#{key}=", value) if recurring_expense.respond_to?("#{key}=")
    end

    # Recalculate next occurrence if start_date changed
    if params[:start_date] || params[:frequency]
      recurring_expense.next_occurrence_date = recurring_expense.start_date
    end

    return { success: false, errors: ['Invalid recurring expense data'] } unless recurring_expense.valid?

    result = @recurring_repository.update(recurring_expense)
    { success: true, data: result }
  rescue StandardError => e
    { success: false, errors: [e.message] }
  end

  def delete_recurring_expense(id)
    recurring_expense = @recurring_repository.find_by_id(id)
    return { success: false, errors: ['Recurring expense not found'] } if recurring_expense.nil?

    @recurring_repository.delete(id)
    { success: true }
  rescue StandardError => e
    { success: false, errors: [e.message] }
  end

  def get_recurring_expense(id)
    recurring_expense = @recurring_repository.find_by_id(id)
    return { success: false, errors: ['Recurring expense not found'] } if recurring_expense.nil?
    { success: true, data: recurring_expense }
  end

  def list_recurring_expenses(user_id)
    recurring_expenses = @recurring_repository.find_by_user(user_id)
    { success: true, data: recurring_expenses }
  end

  def generate_expenses(user_id, up_to_date = nil)
    target_date = up_to_date || Date.today
    target_date = Date.parse(target_date.to_s) if target_date.is_a?(String)

    active_recurring = @recurring_repository.find_active_by_user(user_id, target_date)
    generated_expenses = []
    updated_recurring = []

    active_recurring.each do |recurring|
      next unless recurring.active?(target_date)

      # Generate expenses from start_date or next_occurrence_date up to target_date
      current_date = recurring.next_occurrence_date || recurring.start_date
      current_date = Date.parse(current_date.to_s) if current_date.is_a?(String)

      max_iterations = 1000 # Safety limit to prevent infinite loops
      iteration_count = 0
      
      while current_date <= target_date && recurring.active?(current_date) && iteration_count < max_iterations
        iteration_count += 1
        
        # Check if expense already exists for this date (prevent duplicates)
        existing_expenses = @expense_repository.find_by_user(user_id)
        duplicate = existing_expenses.any? do |exp|
          exp.date.to_s == current_date.to_s &&
            exp.description == recurring.description &&
            exp.amount == recurring.amount &&
            exp.category_id == recurring.category_id
        end

        unless duplicate
          expense = Expense.new(
            amount: recurring.amount,
            date: current_date,
            description: recurring.description,
            category_id: recurring.category_id,
            user_id: recurring.user_id
          )

          if expense.valid?
            created_expense = @expense_repository.create(expense)
            generated_expenses << created_expense
          end
        end

        # Calculate next occurrence
        next_date = recurring.calculate_next_occurrence(current_date)
        break unless next_date && recurring.active?(next_date) && next_date > current_date

        current_date = next_date
      end

      # Update next_occurrence_date
      recurring.next_occurrence_date = current_date
      updated_recurring << @recurring_repository.update(recurring)
    end

    {
      success: true,
      data: {
        generated_count: generated_expenses.length,
        expenses: generated_expenses
      }
    }
  rescue StandardError => e
    { success: false, errors: [e.message] }
  end

  def get_expenses_due(user_id, date = Date.today)
    date = Date.parse(date.to_s) if date.is_a?(String)
    active_recurring = @recurring_repository.find_active_by_user(user_id, date)
    
    due_expenses = active_recurring.select do |recurring|
      next_date = recurring.next_occurrence_date || recurring.start_date
      next_date = Date.parse(next_date.to_s) if next_date.is_a?(String)
      next_date <= date
    end

    { success: true, data: due_expenses }
  end
end

