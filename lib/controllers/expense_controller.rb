require 'json'
require 'sinatra'
require_relative '../services/expense_service'

# Controller for expense-related API endpoints
class ExpenseController
  def initialize(service = ExpenseService.new)
    @service = service
  end

  def create(params)
    result = @service.create_expense(params)
    if result[:success]
      [201, { 'Content-Type' => 'application/json' }, result[:data].to_json]
    else
      [400, { 'Content-Type' => 'application/json' }, { errors: result[:errors] }.to_json]
    end
  end

  def show(id)
    result = @service.get_expense(id.to_i)
    if result[:success]
      [200, { 'Content-Type' => 'application/json' }, result[:data].to_json]
    else
      [404, { 'Content-Type' => 'application/json' }, { errors: result[:errors] }.to_json]
    end
  end

  def update(id, params)
    result = @service.update_expense(id.to_i, params)
    if result[:success]
      [200, { 'Content-Type' => 'application/json' }, result[:data].to_json]
    else
      [400, { 'Content-Type' => 'application/json' }, { errors: result[:errors] }.to_json]
    end
  end

  def delete(id)
    result = @service.delete_expense(id.to_i)
    if result[:success]
      [204, {}, '']
    else
      [404, { 'Content-Type' => 'application/json' }, { errors: result[:errors] }.to_json]
    end
  end

  def list(user_id, filters = {})
    result = @service.list_expenses(user_id.to_i, filters)
    [200, { 'Content-Type' => 'application/json' }, result[:data].to_json]
  end

  def total(user_id, date_range = nil)
    result = @service.calculate_total(user_id.to_i, date_range)
    if result[:success]
      [200, { 'Content-Type' => 'application/json' }, { total: result[:data] }.to_json]
    else
      [400, { 'Content-Type' => 'application/json' }, { errors: result[:errors] }.to_json]
    end
  end
end

