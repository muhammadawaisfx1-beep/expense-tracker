require 'sinatra'
require 'json'
require_relative 'controllers/expense_controller'
require_relative 'controllers/category_controller'
require_relative 'controllers/report_controller'
require_relative '../config/app'

# Main Sinatra application
class ExpenseTrackerApp < Sinatra::Base
  set :bind, '0.0.0.0'
  set :port, 9292

  before do
    content_type :json
  end

  # Expense endpoints
  get '/api/expenses' do
    user_id = params['user_id'] || 1
    controller = ExpenseController.new
    status, headers, body = controller.list(user_id, parse_filters)
    status status
    body
  end

  post '/api/expenses' do
    controller = ExpenseController.new
    data = JSON.parse(request.body.read)
    status, headers, body = controller.create(symbolize_keys(data))
    status status
    body
  end

  get '/api/expenses/:id' do
    controller = ExpenseController.new
    status, headers, body = controller.show(params['id'])
    status status
    body
  end

  put '/api/expenses/:id' do
    controller = ExpenseController.new
    data = JSON.parse(request.body.read)
    status, headers, body = controller.update(params['id'], symbolize_keys(data))
    status status
    body
  end

  delete '/api/expenses/:id' do
    controller = ExpenseController.new
    status, headers, body = controller.delete(params['id'])
    status status
    body
  end

  get '/api/expenses/:user_id/total' do
    controller = ExpenseController.new
    date_range = parse_date_range
    status, headers, body = controller.total(params['user_id'], date_range)
    status status
    body
  end

  # Category endpoints
  get '/api/categories' do
    user_id = params['user_id'] || 1
    controller = CategoryController.new
    status, headers, body = controller.list(user_id)
    status status
    body
  end

  post '/api/categories' do
    controller = CategoryController.new
    data = JSON.parse(request.body.read)
    status, headers, body = controller.create(symbolize_keys(data))
    status status
    body
  end

  get '/api/categories/:id' do
    controller = CategoryController.new
    status, headers, body = controller.show(params['id'])
    status status
    body
  end

  put '/api/categories/:id' do
    controller = CategoryController.new
    data = JSON.parse(request.body.read)
    status, headers, body = controller.update(params['id'], symbolize_keys(data))
    status status
    body
  end

  delete '/api/categories/:id' do
    controller = CategoryController.new
    status, headers, body = controller.delete(params['id'])
    status status
    body
  end

  # Report endpoints
  get '/api/reports/monthly' do
    user_id = params['user_id'] || 1
    year = params['year'] || Date.today.year
    month = params['month'] || Date.today.month
    filters = {
      category_id: params['category_id'],
      min_amount: params['min_amount'],
      max_amount: params['max_amount']
    }
    controller = ReportController.new
    status, headers, body = controller.monthly_report(user_id, year, month, filters)
    status status
    body
  end

  get '/api/reports/yearly' do
    user_id = params['user_id'] || 1
    year = params['year'] || Date.today.year
    controller = ReportController.new
    status, headers, body = controller.yearly_report(user_id, year)
    status status
    body
  end

  get '/api/reports/category/:category_id' do
    user_id = params['user_id'] || 1
    date_range = parse_date_range
    controller = ReportController.new
    status, headers, body = controller.category_report(user_id, params['category_id'], date_range)
    status status
    body
  end

  # Health check
  get '/health' do
    { status: 'ok', app: AppConfig::APP_NAME, version: AppConfig::VERSION }.to_json
  end

  private

  def symbolize_keys(hash)
    hash.each_with_object({}) { |(k, v), h| h[k.to_sym] = v }
  end

  def parse_filters
    filters = {}
    filters[:category_id] = params['category_id'].to_i if params['category_id'] && !params['category_id'].empty?
    
    begin
      filters[:start_date] = Date.parse(params['start_date']) if params['start_date'] && !params['start_date'].empty?
      filters[:end_date] = Date.parse(params['end_date']) if params['end_date'] && !params['end_date'].empty?
    rescue ArgumentError
      # Invalid date format, skip date filters
    end
    
    filters[:search] = params['search'] if params['search'] && !params['search'].empty?
    filters[:min_amount] = params['min_amount'] if params['min_amount'] && !params['min_amount'].empty?
    filters[:max_amount] = params['max_amount'] if params['max_amount'] && !params['max_amount'].empty?
    filters[:sort_by] = params['sort_by'] if params['sort_by'] && !params['sort_by'].empty?
    filters[:order] = params['order'] if params['order'] && !params['order'].empty?
    
    filters
  end

  def parse_date_range
    return nil unless params['start_date'] && params['end_date']
    {
      start: Date.parse(params['start_date']),
      end: Date.parse(params['end_date'])
    }
  end
end

