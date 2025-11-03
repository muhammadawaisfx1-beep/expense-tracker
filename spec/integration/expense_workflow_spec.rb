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
end

