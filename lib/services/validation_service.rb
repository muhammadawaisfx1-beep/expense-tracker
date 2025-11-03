require_relative '../utils/validators'

# Centralized validation service
class ValidationService
  def self.validate_expense_data(params)
    errors = []

    errors << 'Amount is required and must be positive' unless Validators.validate_amount(params[:amount])
    errors << 'Date is required and must be valid' unless Validators.validate_date(params[:date])
    errors << 'Description cannot be empty' if params[:description].to_s.strip.empty?
    errors << 'User ID is required' if params[:user_id].nil?

    errors
  end

  def self.validate_category_data(params)
    errors = []

    errors << 'Name is required' if params[:name].to_s.strip.empty?
    errors << 'Budget limit must be positive if provided' if params[:budget_limit] && params[:budget_limit] < 0
    errors << 'User ID is required' if params[:user_id].nil?

    errors
  end

  def self.validate_user_data(params)
    errors = []

    errors << 'Name is required' if params[:name].to_s.strip.empty?
    errors << 'Email is required and must be valid' unless Validators.validate_email(params[:email])
    errors << 'Password must be at least 6 characters' if params[:password] && params[:password].length < 6

    errors
  end

  def self.validate_budget_data(params)
    errors = []

    errors << 'Category ID is required' if params[:category_id].nil?
    errors << 'Amount must be positive' unless params[:amount] && params[:amount] > 0
    errors << 'Period start is required' if params[:period_start].nil?
    errors << 'Period end is required' if params[:period_end].nil?
    errors << 'Period start must be before period end' if params[:period_start] && params[:period_end] && params[:period_start] >= params[:period_end]
    errors << 'User ID is required' if params[:user_id].nil?

    errors
  end
end

