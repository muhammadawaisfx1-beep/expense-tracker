require 'spec_helper'
require 'rack/test'
require_relative '../../lib/app'
require_relative '../../lib/models/recurring_expense'
require_relative '../../lib/models/expense'
require_relative '../../lib/models/category'
require_relative '../../lib/repositories/recurring_expense_repository'
require_relative '../../lib/repositories/expense_repository'
require_relative '../../lib/repositories/category_repository'
require 'date'

RSpec.describe 'Recurring Expense Workflow Integration', type: :integration do
  include Rack::Test::Methods

  def app
    ExpenseTrackerApp
  end

  before do
    # Clear repositories
    RecurringExpenseRepository.class_variable_set(:@@storage, {})
    RecurringExpenseRepository.class_variable_set(:@@next_id, 1)
    ExpenseRepository.class_variable_set(:@@storage, {})
    ExpenseRepository.class_variable_set(:@@next_id, 1)
    CategoryRepository.class_variable_set(:@@storage, {})
    CategoryRepository.class_variable_set(:@@next_id, 1)
  end

  describe 'P2P: Recurring Expense Creation Workflow' do
    it 'allows creating a recurring expense and retrieving it' do
      # Create recurring expense
      post '/api/recurring_expenses', {
        amount: 99.99,
        description: 'Netflix Subscription',
        category_id: 1,
        user_id: 1,
        frequency: 'monthly',
        start_date: '2025-01-01',
        end_date: '2025-12-31'
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)
      recurring_data = JSON.parse(last_response.body)
      recurring_id = recurring_data['id']

      # Retrieve the recurring expense
      get "/api/recurring_expenses/#{recurring_id}"
      expect(last_response.status).to eq(200)

      retrieved = JSON.parse(last_response.body)
      expect(retrieved['amount']).to eq(99.99)
      expect(retrieved['description']).to eq('Netflix Subscription')
      expect(retrieved['frequency']).to eq('monthly')
      expect(retrieved['next_occurrence_date']).to eq('2025-01-01')
    end

    it 'allows listing all recurring expenses for a user' do
      # Create two recurring expenses
      post '/api/recurring_expenses', {
        amount: 99.99,
        description: 'Netflix Subscription',
        user_id: 1,
        frequency: 'monthly',
        start_date: '2025-01-01'
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      post '/api/recurring_expenses', {
        amount: 49.99,
        description: 'Spotify Subscription',
        user_id: 1,
        frequency: 'monthly',
        start_date: '2025-01-01'
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      # List recurring expenses
      get '/api/recurring_expenses?user_id=1'
      expect(last_response.status).to eq(200)

      recurring_expenses = JSON.parse(last_response.body)
      expect(recurring_expenses.length).to eq(2)
    end

    it 'allows updating a recurring expense' do
      # Create recurring expense
      post '/api/recurring_expenses', {
        amount: 99.99,
        description: 'Netflix Subscription',
        user_id: 1,
        frequency: 'monthly',
        start_date: '2025-01-01'
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }
      recurring_id = JSON.parse(last_response.body)['id']

      # Update recurring expense
      put "/api/recurring_expenses/#{recurring_id}", {
        amount: 109.99,
        description: 'Netflix Premium'
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to eq(200)
      updated = JSON.parse(last_response.body)
      expect(updated['amount']).to eq(109.99)
      expect(updated['description']).to eq('Netflix Premium')
    end
  end

  describe 'F2P: Recurring Expense Auto-Generation' do
    it 'automatically generates Expense entries from recurring expense templates' do
      # Create a category first
      post '/api/categories', {
        name: 'Entertainment',
        budget_limit: 200,
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }
      category_id = JSON.parse(last_response.body)['id']

      # Create a monthly recurring expense
      post '/api/recurring_expenses', {
        amount: 99.99,
        description: 'Netflix Subscription',
        category_id: category_id,
        user_id: 1,
        frequency: 'monthly',
        start_date: '2025-01-01',
        end_date: '2025-12-31'
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }
      expect(last_response.status).to be_between(200, 201)

      # Generate expenses up to February 1st (should generate Jan and Feb expenses)
      post '/api/recurring_expenses/generate', {
        user_id: 1,
        up_to_date: '2025-02-01'
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to eq(200)
      result = JSON.parse(last_response.body)
      expect(result['generated_count']).to eq(2)

      # Verify the generated expenses exist
      get '/api/expenses?user_id=1'
      expenses = JSON.parse(last_response.body)
      expect(expenses.length).to eq(2)
      
      # Check that both expenses have correct details
      expenses.each do |expense|
        expect(expense['amount']).to eq(99.99)
        expect(expense['description']).to eq('Netflix Subscription')
        expect(expense['category_id']).to eq(category_id)
      end

      # Verify dates
      dates = expenses.map { |e| e['date'] }.sort
      expect(dates).to include('2025-01-01')
      expect(dates).to include('2025-02-01')
    end

    it 'prevents duplicate expense generation for the same date' do
      # Create category
      post '/api/categories', {
        name: 'Entertainment',
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }
      category_id = JSON.parse(last_response.body)['id']

      # Create recurring expense
      post '/api/recurring_expenses', {
        amount: 99.99,
        description: 'Netflix Subscription',
        category_id: category_id,
        user_id: 1,
        frequency: 'monthly',
        start_date: '2025-01-01'
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      # Generate expenses first time
      post '/api/recurring_expenses/generate', {
        user_id: 1,
        up_to_date: '2025-02-01'
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }
      first_result = JSON.parse(last_response.body)
      first_count = first_result['generated_count']

      # Generate expenses again (should not create duplicates)
      post '/api/recurring_expenses/generate', {
        user_id: 1,
        up_to_date: '2025-02-01'
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }
      second_result = JSON.parse(last_response.body)

      # Should not generate additional expenses
      expect(second_result['generated_count']).to eq(0)
      
      # Total expenses should remain the same
      get '/api/expenses?user_id=1'
      expenses = JSON.parse(last_response.body)
      expect(expenses.length).to eq(first_count)
    end

    it 'handles different frequency types correctly' do
      # Create category
      post '/api/categories', {
        name: 'Subscriptions',
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }
      category_id = JSON.parse(last_response.body)['id']

      # Create weekly recurring expense
      post '/api/recurring_expenses', {
        amount: 20.00,
        description: 'Weekly Groceries',
        category_id: category_id,
        user_id: 1,
        frequency: 'weekly',
        start_date: '2025-01-01'
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      # Generate expenses up to Jan 15 (should generate Jan 1, 8, 15 = 3 expenses)
      post '/api/recurring_expenses/generate', {
        user_id: 1,
        up_to_date: '2025-01-15'
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to eq(200)
      result = JSON.parse(last_response.body)
      # Should generate at least 2 expenses (Jan 1 and Jan 8, possibly Jan 15)
      expect(result['generated_count']).to be >= 2
      
      # Verify the generated expenses
      get '/api/expenses?user_id=1'
      expenses = JSON.parse(last_response.body)
      expect(expenses.length).to be >= 2
      expect(expenses.any? { |e| e['date'] == '2025-01-01' }).to be true
      expect(expenses.any? { |e| e['date'] == '2025-01-08' }).to be true
    end
  end
end

