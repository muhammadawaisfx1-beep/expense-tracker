require 'spec_helper'
require 'rack/test'
require_relative '../../lib/app'
require_relative '../../lib/models/expense'
require_relative '../../lib/models/category'
require 'date'

RSpec.describe 'Expense Search and Filtering Integration', type: :integration do
  include Rack::Test::Methods

  def app
    ExpenseTrackerApp
  end

  before do
    # Clear repositories
    ExpenseRepository.class_variable_set(:@@storage, {})
    ExpenseRepository.class_variable_set(:@@next_id, 1)
    CategoryRepository.class_variable_set(:@@storage, {})
    CategoryRepository.class_variable_set(:@@next_id, 1)

    # Create test data
    post '/api/categories', {
      name: 'Food & Dining',
      budget_limit: 500,
      user_id: 1
    }.to_json, { 'CONTENT_TYPE' => 'application/json' }
    @category_id = JSON.parse(last_response.body)['id']

    post '/api/expenses', {
      amount: 45.50,
      date: '2025-01-15',
      description: 'Lunch at restaurant',
      category_id: @category_id,
      user_id: 1
    }.to_json, { 'CONTENT_TYPE' => 'application/json' }

    post '/api/expenses', {
      amount: 25.0,
      date: '2025-01-20',
      description: 'Coffee shop visit',
      category_id: @category_id,
      user_id: 1
    }.to_json, { 'CONTENT_TYPE' => 'application/json' }

    post '/api/expenses', {
      amount: 100.0,
      date: '2025-02-01',
      description: 'Grocery shopping',
      category_id: @category_id,
      user_id: 1
    }.to_json, { 'CONTENT_TYPE' => 'application/json' }
  end

  describe 'P2P: Search Workflow' do
    it 'allows searching expenses by description keyword' do
      get '/api/expenses?user_id=1&search=lunch'
      expect(last_response.status).to eq(200)

      expenses = JSON.parse(last_response.body)
      expect(expenses.length).to eq(1)
      expect(expenses.first['description']).to include('Lunch')
    end

    it 'allows filtering by category' do
      get "/api/expenses?user_id=1&category_id=#{@category_id}"
      expect(last_response.status).to eq(200)

      expenses = JSON.parse(last_response.body)
      expect(expenses.length).to eq(3)
      expenses.each do |expense|
        expect(expense['category_id']).to eq(@category_id)
      end
    end

    it 'allows filtering by date range' do
      get '/api/expenses?user_id=1&start_date=2025-01-01&end_date=2025-01-31'
      expect(last_response.status).to eq(200)

      expenses = JSON.parse(last_response.body)
      expect(expenses.length).to eq(2)
    end

    it 'allows filtering by amount range' do
      get '/api/expenses?user_id=1&min_amount=30&max_amount=50'
      expect(last_response.status).to eq(200)

      expenses = JSON.parse(last_response.body)
      expect(expenses.length).to eq(1)
      expect(expenses.first['amount']).to eq(45.5)
    end

    it 'allows sorting expenses' do
      get '/api/expenses?user_id=1&sort_by=amount&order=desc'
      expect(last_response.status).to eq(200)

      expenses = JSON.parse(last_response.body)
      amounts = expenses.map { |e| e['amount'] }
      expect(amounts).to eq([100.0, 45.5, 25.0])
    end
  end

  describe 'F2P: Combined Filtering with Category' do
    it 'filters expenses by category and applies additional filters' do
      # Filter by category and amount range
      get "/api/expenses?user_id=1&category_id=#{@category_id}&min_amount=40&max_amount=50"
      expect(last_response.status).to eq(200)

      expenses = JSON.parse(last_response.body)
      expect(expenses.length).to eq(1)
      expect(expenses.first['category_id']).to eq(@category_id)
      expect(expenses.first['amount']).to be_between(40, 50)
    end

    it 'combines search, category filter, and sorting' do
      get "/api/expenses?user_id=1&category_id=#{@category_id}&search=coffee&sort_by=date&order=asc"
      expect(last_response.status).to eq(200)

      expenses = JSON.parse(last_response.body)
      expect(expenses.length).to eq(1)
      expect(expenses.first['description']).to include('Coffee')
    end
  end
end

