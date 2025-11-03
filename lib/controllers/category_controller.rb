require 'json'
require 'sinatra'
require_relative '../services/category_service'

# Controller for category-related API endpoints
class CategoryController
  def initialize(service = CategoryService.new)
    @service = service
  end

  def create(params)
    result = @service.create_category(params)
    if result[:success]
      [201, { 'Content-Type' => 'application/json' }, result[:data].to_json]
    else
      [400, { 'Content-Type' => 'application/json' }, { errors: result[:errors] }.to_json]
    end
  end

  def show(id)
    result = @service.get_category(id.to_i)
    if result[:success]
      [200, { 'Content-Type' => 'application/json' }, result[:data].to_json]
    else
      [404, { 'Content-Type' => 'application/json' }, { errors: result[:errors] }.to_json]
    end
  end

  def update(id, params)
    result = @service.update_category(id.to_i, params)
    if result[:success]
      [200, { 'Content-Type' => 'application/json' }, result[:data].to_json]
    else
      [400, { 'Content-Type' => 'application/json' }, { errors: result[:errors] }.to_json]
    end
  end

  def delete(id)
    result = @service.delete_category(id.to_i)
    if result[:success]
      [204, {}, '']
    else
      [404, { 'Content-Type' => 'application/json' }, { errors: result[:errors] }.to_json]
    end
  end

  def list(user_id)
    result = @service.list_categories(user_id.to_i)
    [200, { 'Content-Type' => 'application/json' }, result[:data].to_json]
  end
end

