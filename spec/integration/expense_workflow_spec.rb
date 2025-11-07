require 'spec_helper'
require 'rack/test'
require_relative '../../lib/app'
require_relative '../../lib/models/expense'
require_relative '../../lib/models/category'
require 'date'

RSpec.describe 'Expense Workflow Integration', type: :integration do
  include Rack::Test::Methods

  def app
    ExpenseTrackerApp
  end

  describe 'P2P: Expense Creation Workflow' do
    it 'allows creating an expense and retrieving it' do
      # Create expense
      post '/api/expenses', {
        amount: 150.75,
        date: '2025-01-15',
        description: 'Grocery shopping',
        category_id: 1,
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)
      expense_data = JSON.parse(last_response.body)
      expense_id = expense_data['id']

      # Retrieve the expense
      get "/api/expenses/#{expense_id}"
      expect(last_response.status).to eq(200)

      retrieved = JSON.parse(last_response.body)
      expect(retrieved['amount']).to eq(150.75)
      expect(retrieved['description']).to eq('Grocery shopping')
    end
  end

  describe 'F2P: Expense Creation with Category Assignment' do
    it 'creates a category and then creates an expense assigned to that category' do
      # Create category first
      post '/api/categories', {
        name: 'Food & Dining',
        budget_limit: 500,
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)
      category_data = JSON.parse(last_response.body)
      category_id = category_data['id']

      # Create expense with category assignment
      post '/api/expenses', {
        amount: 45.50,
        date: '2025-01-15',
        description: 'Restaurant dinner',
        category_id: category_id,
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)
      expense_data = JSON.parse(last_response.body)
      expect(expense_data['category_id']).to eq(category_id)
    end
  end

  describe 'P2P: Expense Tags Support' do
    it 'allows adding tags to an expense and retrieving them' do
      # Create expense with tags
      post '/api/expenses', {
        amount: 75.00,
        date: '2025-01-20',
        description: 'Lunch at restaurant',
        category_id: 1,
        user_id: 1,
        tags: ['food', 'restaurant', 'lunch']
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)
      expense_data = JSON.parse(last_response.body)
      expense_id = expense_data['id']
      expect(expense_data['tags']).to eq(['food', 'restaurant', 'lunch'])

      # Retrieve the expense and verify tags
      get "/api/expenses/#{expense_id}"
      expect(last_response.status).to eq(200)
      retrieved = JSON.parse(last_response.body)
      expect(retrieved['tags']).to eq(['food', 'restaurant', 'lunch'])

      # Update expense with new tags
      put "/api/expenses/#{expense_id}", {
        tags: ['food', 'dinner']
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to eq(200)
      updated = JSON.parse(last_response.body)
      expect(updated['tags']).to eq(['food', 'dinner'])
    end

    it 'handles comma-separated string tags' do
      post '/api/expenses', {
        amount: 50.00,
        date: '2025-01-21',
        description: 'Coffee shop',
        category_id: 1,
        user_id: 1,
        tags: 'food, beverage, coffee'
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)
      expense_data = JSON.parse(last_response.body)
      expect(expense_data['tags']).to eq(['food', 'beverage', 'coffee'])
    end
  end

  describe 'F2P: Filter Expenses by Tags' do
    before do
      # Clear repositories
      ExpenseRepository.class_variable_set(:@@storage, {})
      ExpenseRepository.class_variable_set(:@@next_id, 1)

      # Create expenses with different tags
      post '/api/expenses', {
        amount: 50.00,
        date: '2025-01-15',
        description: 'Lunch',
        category_id: 1,
        user_id: 1,
        tags: ['food', 'restaurant']
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      post '/api/expenses', {
        amount: 25.00,
        date: '2025-01-16',
        description: 'Coffee',
        category_id: 1,
        user_id: 1,
        tags: ['food', 'beverage']
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      post '/api/expenses', {
        amount: 100.00,
        date: '2025-01-17',
        description: 'Grocery',
        category_id: 1,
        user_id: 1,
        tags: ['food', 'grocery']
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      post '/api/expenses', {
        amount: 200.00,
        date: '2025-01-18',
        description: 'Gas',
        category_id: 2,
        user_id: 1,
        tags: ['transport', 'fuel']
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }
    end

    it 'filters expenses by single tag' do
      get '/api/expenses?user_id=1&tags=food'
      expect(last_response.status).to eq(200)
      expenses = JSON.parse(last_response.body)
      expect(expenses.length).to eq(3)
      expect(expenses.map { |e| e['description'] }).to contain_exactly('Lunch', 'Coffee', 'Grocery')
    end

    it 'filters expenses by multiple tags (must have all)' do
      get '/api/expenses?user_id=1&tags=food,restaurant'
      expect(last_response.status).to eq(200)
      expenses = JSON.parse(last_response.body)
      expect(expenses.length).to eq(1)
      expect(expenses.first['description']).to eq('Lunch')
    end

    it 'returns empty array when no expenses match tags' do
      get '/api/expenses?user_id=1&tags=nonexistent'
      expect(last_response.status).to eq(200)
      expenses = JSON.parse(last_response.body)
      expect(expenses.length).to eq(0)
    end

    it 'combines tag filter with other filters' do
      get '/api/expenses?user_id=1&tags=food&min_amount=50'
      expect(last_response.status).to eq(200)
      expenses = JSON.parse(last_response.body)
      expect(expenses.length).to eq(2)
      expect(expenses.map { |e| e['description'] }).to contain_exactly('Lunch', 'Grocery')
    end
  end
end

