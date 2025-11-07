require_relative '../repositories/expense_repository'
require_relative '../utils/validators'
require_relative '../utils/currency_converter'

# Service layer for expense business logic
class ExpenseService
  def initialize(repository = ExpenseRepository.new)
    @repository = repository
  end

  def create_expense(params)
    expense = Expense.new(params)
    return { success: false, errors: ['Invalid expense data'] } unless expense.valid?
    return { success: false, errors: ['Invalid amount'] } unless Validators.validate_amount(params[:amount])

    result = @repository.create(expense)
    { success: true, data: result }
  rescue StandardError => e
    { success: false, errors: [e.message] }
  end

  def update_expense(id, params)
    expense = @repository.find_by_id(id)
    return { success: false, errors: ['Expense not found'] } if expense.nil?

    params.each do |key, value|
      if key == :tags && value
        # Normalize tags using the expense's normalize_tags method
        expense.tags = expense.normalize_tags(value)
      elsif expense.respond_to?("#{key}=")
        expense.send("#{key}=", value)
      end
    end

    return { success: false, errors: ['Invalid expense data'] } unless expense.valid?

    result = @repository.update(expense)
    { success: true, data: result }
  rescue StandardError => e
    { success: false, errors: [e.message] }
  end

  def delete_expense(id)
    expense = @repository.find_by_id(id)
    return { success: false, errors: ['Expense not found'] } if expense.nil?

    @repository.delete(id)
    { success: true }
  rescue StandardError => e
    { success: false, errors: [e.message] }
  end

  def get_expense(id)
    expense = @repository.find_by_id(id)
    return { success: false, errors: ['Expense not found'] } if expense.nil?
    { success: true, data: expense }
  end

  def list_expenses(user_id, filters = {})
    expenses = @repository.find_by_user(user_id, filters)
    { success: true, data: expenses }
  end

  def calculate_total(user_id, date_range = nil, target_currency = nil)
    expenses = @repository.find_by_user(user_id)
    expenses = expenses.select { |e| date_range.nil? || (e.date >= date_range[:start] && e.date <= date_range[:end]) } if date_range
    
    if target_currency
      # Convert all expenses to target currency before summing
      converted_amounts = expenses.map do |expense|
        CurrencyConverter.convert_expense(expense, target_currency) || 0
      end
      total = converted_amounts.sum
    else
      total = expenses.sum(&:amount)
    end
    
    { success: true, data: total }
  end

  # Convert expense amount to a different currency
  # @param expense_id [Integer] ID of the expense
  # @param target_currency [String] Target currency code
  # @return [Hash] Result with converted amount or error
  def convert_expense_currency(expense_id, target_currency)
    expense = @repository.find_by_id(expense_id)
    return { success: false, errors: ['Expense not found'] } if expense.nil?

    unless CurrencyConverter.supported?(target_currency)
      return { success: false, errors: ["Unsupported currency: #{target_currency}"] }
    end

    converted_amount = CurrencyConverter.convert_expense(expense, target_currency)
    return { success: false, errors: ['Currency conversion failed'] } if converted_amount.nil?

    {
      success: true,
      data: {
        original_amount: expense.amount,
        original_currency: expense.currency,
        converted_amount: converted_amount,
        target_currency: target_currency
      }
    }
  end
end

