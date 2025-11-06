require 'json'
require 'sinatra'
require_relative '../services/recurring_expense_service'

# Controller for recurring expense-related API endpoints
class RecurringExpenseController
  def initialize(service = RecurringExpenseService.new)
    @service = service
  end

  def create(params)
    result = @service.create_recurring_expense(params)
    if result[:success]
      [201, { 'Content-Type' => 'application/json' }, result[:data].to_json]
    else
      [400, { 'Content-Type' => 'application/json' }, { errors: result[:errors] }.to_json]
    end
  end

  def show(id)
    result = @service.get_recurring_expense(id.to_i)
    if result[:success]
      [200, { 'Content-Type' => 'application/json' }, result[:data].to_json]
    else
      [404, { 'Content-Type' => 'application/json' }, { errors: result[:errors] }.to_json]
    end
  end

  def update(id, params)
    result = @service.update_recurring_expense(id.to_i, params)
    if result[:success]
      [200, { 'Content-Type' => 'application/json' }, result[:data].to_json]
    else
      [400, { 'Content-Type' => 'application/json' }, { errors: result[:errors] }.to_json]
    end
  end

  def delete(id)
    result = @service.delete_recurring_expense(id.to_i)
    if result[:success]
      [204, {}, '']
    else
      [404, { 'Content-Type' => 'application/json' }, { errors: result[:errors] }.to_json]
    end
  end

  def list(user_id)
    result = @service.list_recurring_expenses(user_id.to_i)
    [200, { 'Content-Type' => 'application/json' }, result[:data].to_json]
  end

  def generate(user_id, up_to_date = nil)
    result = @service.generate_expenses(user_id.to_i, up_to_date)
    if result[:success]
      [200, { 'Content-Type' => 'application/json' }, result[:data].to_json]
    else
      [400, { 'Content-Type' => 'application/json' }, { errors: result[:errors] }.to_json]
    end
  end
end

