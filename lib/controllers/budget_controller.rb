require 'json'
require 'sinatra'
require_relative '../services/budget_service'

# Controller for budget-related API endpoints
class BudgetController
  def initialize(service = BudgetService.new)
    @service = service
  end

  def create(params)
    result = @service.create_budget(params)
    if result[:success]
      [201, { 'Content-Type' => 'application/json' }, result[:data].to_json]
    else
      [400, { 'Content-Type' => 'application/json' }, { errors: result[:errors] }.to_json]
    end
  end

  def show(id)
    result = @service.get_budget(id.to_i)
    if result[:success]
      [200, { 'Content-Type' => 'application/json' }, result[:data].to_json]
    else
      [404, { 'Content-Type' => 'application/json' }, { errors: result[:errors] }.to_json]
    end
  end

  def update(id, params)
    result = @service.update_budget(id.to_i, params)
    if result[:success]
      [200, { 'Content-Type' => 'application/json' }, result[:data].to_json]
    else
      [400, { 'Content-Type' => 'application/json' }, { errors: result[:errors] }.to_json]
    end
  end

  def delete(id)
    result = @service.delete_budget(id.to_i)
    if result[:success]
      [204, {}, '']
    else
      [404, { 'Content-Type' => 'application/json' }, { errors: result[:errors] }.to_json]
    end
  end

  def list(user_id)
    result = @service.list_budgets(user_id.to_i)
    [200, { 'Content-Type' => 'application/json' }, result[:data].to_json]
  end

  def status(id, user_id)
    budget = @service.get_budget(id.to_i)
    return [404, { 'Content-Type' => 'application/json' }, { errors: ['Budget not found'] }.to_json] unless budget[:success]

    status_result = @service.check_budget_status(budget[:data], user_id.to_i)
    if status_result[:success]
      [200, { 'Content-Type' => 'application/json' }, status_result[:data].to_json]
    else
      [400, { 'Content-Type' => 'application/json' }, { errors: status_result[:errors] }.to_json]
    end
  end
end

