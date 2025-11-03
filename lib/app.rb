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
    controller.list(user_id, parse_filters).first
  end

  post '/api/expenses' do
    controller = ExpenseController.new
    data = JSON.parse(request.body.read)
    controller.create(symbolize_keys(data)).first
  end

  get '/api/expenses/:id' do
    controller = ExpenseController.new
    controller.show(params['id']).first
  end

  put '/api/expenses/:id' do
    controller = ExpenseController.new
    data = JSON.parse(request.body.read)
    controller.update(params['id'], symbolize_keys(data)).first
  end

  delete '/api/expenses/:id' do
    controller = ExpenseController.new
    controller.delete(params['id']).first
  end

  get '/api/expenses/:user_id/total' do
    controller = ExpenseController.new
    date_range = parse_date_range
    controller.total(params['user_id'], date_range).first
  end

  # Category endpoints
  get '/api/categories' do
    user_id = params['user_id'] || 1
    controller = CategoryController.new
    controller.list(user_id).first
  end

  post '/api/categories' do
    controller = CategoryController.new
    data = JSON.parse(request.body.read)
    controller.create(symbolize_keys(data)).first
  end

  get '/api/categories/:id' do
    controller = CategoryController.new
    controller.show(params['id']).first
  end

  put '/api/categories/:id' do
    controller = CategoryController.new
    data = JSON.parse(request.body.read)
    controller.update(params['id'], symbolize_keys(data)).first
  end

  delete '/api/categories/:id' do
    controller = CategoryController.new
    controller.delete(params['id']).first
  end

  # Report endpoints
  get '/api/reports/monthly' do
    user_id = params['user_id'] || 1
    year = params['year'] || Date.today.year
    month = params['month'] || Date.today.month
    controller = ReportController.new
    controller.monthly_report(user_id, year, month).first
  end

  get '/api/reports/yearly' do
    user_id = params['user_id'] || 1
    year = params['year'] || Date.today.year
    controller = ReportController.new
    controller.yearly_report(user_id, year).first
  end

  get '/api/reports/category/:category_id' do
    user_id = params['user_id'] || 1
    date_range = parse_date_range
    controller = ReportController.new
    controller.category_report(user_id, params['category_id'], date_range).first
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
    {
      category_id: params['category_id']&.to_i,
      start_date: params['start_date'] ? Date.parse(params['start_date']) : nil,
      end_date: params['end_date'] ? Date.parse(params['end_date']) : nil,
      search: params['search']
    }.compact
  end

  def parse_date_range
    return nil unless params['start_date'] && params['end_date']
    {
      start: Date.parse(params['start_date']),
      end: Date.parse(params['end_date'])
    }
  end
end

