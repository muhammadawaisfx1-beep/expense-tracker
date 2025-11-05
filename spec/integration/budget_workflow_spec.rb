require 'spec_helper'
require 'rack/test'
require_relative '../../lib/app'
require_relative '../../lib/models/budget'
require_relative '../../lib/models/category'
require_relative '../../lib/repositories/budget_repository'
require_relative '../../lib/repositories/category_repository'
require_relative '../../lib/repositories/expense_repository'
require 'date'

RSpec.describe 'Budget Creation and Tracking Integration', type: :integration do
  include Rack::Test::Methods

  def app
    ExpenseTrackerApp
  end

  before do
    # Clear repositories
    BudgetRepository.class_variable_set(:@@storage, {})
    BudgetRepository.class_variable_set(:@@next_id, 1)
    CategoryRepository.class_variable_set(:@@storage, {})
    CategoryRepository.class_variable_set(:@@next_id, 1)
    ExpenseRepository.class_variable_set(:@@storage, {})
    ExpenseRepository.class_variable_set(:@@next_id, 1)

    # Create test category
    post '/api/categories', {
      name: 'Food & Dining',
      budget_limit: 500,
      user_id: 1
    }.to_json, { 'CONTENT_TYPE' => 'application/json' }
    @category_id = JSON.parse(last_response.body)['id']

    # Create test expenses
    post '/api/expenses', {
      amount: 150.0,
      date: '2025-01-15',
      description: 'Grocery shopping',
      category_id: @category_id,
      user_id: 1
    }.to_json, { 'CONTENT_TYPE' => 'application/json' }

    post '/api/expenses', {
      amount: 100.0,
      date: '2025-01-20',
      description: 'Restaurant dinner',
      category_id: @category_id,
      user_id: 1
    }.to_json, { 'CONTENT_TYPE' => 'application/json' }
  end

  describe 'P2P: Budget Creation Workflow' do
    it 'allows creating a budget and retrieving it' do
      # Create budget
      post '/api/budgets', {
        category_id: @category_id,
        amount: 500,
        period_start: '2025-01-01',
        period_end: '2025-01-31',
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)
      budget_data = JSON.parse(last_response.body)
      budget_id = budget_data['id']

      # Retrieve the budget
      get "/api/budgets/#{budget_id}"
      expect(last_response.status).to eq(200)

      retrieved = JSON.parse(last_response.body)
      expect(retrieved['amount']).to eq(500)
      expect(retrieved['category_id']).to eq(@category_id)
    end

    it 'allows listing all budgets for a user' do
      # Create two budgets
      post '/api/budgets', {
        category_id: @category_id,
        amount: 500,
        period_start: '2025-01-01',
        period_end: '2025-01-31',
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      post '/api/budgets', {
        category_id: @category_id,
        amount: 300,
        period_start: '2025-02-01',
        period_end: '2025-02-28',
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      # List budgets
      get '/api/budgets?user_id=1'
      expect(last_response.status).to eq(200)

      budgets = JSON.parse(last_response.body)
      expect(budgets.length).to eq(2)
    end

    it 'allows updating a budget' do
      # Create budget
      post '/api/budgets', {
        category_id: @category_id,
        amount: 500,
        period_start: '2025-01-01',
        period_end: '2025-01-31',
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }
      budget_id = JSON.parse(last_response.body)['id']

      # Update budget
      put "/api/budgets/#{budget_id}", {
        amount: 600,
        period_end: '2025-02-28'
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to eq(200)
      updated = JSON.parse(last_response.body)
      expect(updated['amount']).to eq(600)
    end
  end

  describe 'F2P: Budget Status Tracking' do
    it 'tracks budget status with actual spending' do
      # Create budget
      post '/api/budgets', {
        category_id: @category_id,
        amount: 500,
        period_start: '2025-01-01',
        period_end: '2025-01-31',
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }
      budget_id = JSON.parse(last_response.body)['id']

      # Check budget status
      get "/api/budgets/#{budget_id}/status?user_id=1"
      expect(last_response.status).to eq(200)

      status = JSON.parse(last_response.body)
      expect(status['spending']).to eq(250.0) # 150 + 100 from expenses
      expect(status['remaining']).to eq(250.0) # 500 - 250
      expect(status['percentage_used']).to eq(50.0) # 250/500 * 100
      expect(status['exceeded']).to be false
    end

    it 'detects when budget is exceeded' do
      # Create a smaller budget
      post '/api/budgets', {
        category_id: @category_id,
        amount: 200,
        period_start: '2025-01-01',
        period_end: '2025-01-31',
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }
      budget_id = JSON.parse(last_response.body)['id']

      # Check budget status (spending is 250, budget is 200)
      get "/api/budgets/#{budget_id}/status?user_id=1"
      expect(last_response.status).to eq(200)

      status = JSON.parse(last_response.body)
      expect(status['exceeded']).to be true
      expect(status['remaining']).to be < 0
    end
  end

  describe 'P2P: Budget Alert Generation Workflow' do
    it 'generates and retrieves budget alerts for exceeded budgets' do
      # Create budget
      post '/api/budgets', {
        category_id: @category_id,
        amount: 200,
        period_start: '2025-01-01',
        period_end: '2025-01-31',
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      # Expenses already created in before block total 250 (150 + 100)
      # This exceeds the budget of 200

      # Get alerts
      get '/api/budgets/alerts?user_id=1'
      expect(last_response.status).to eq(200)

      alerts_data = JSON.parse(last_response.body)
      expect(alerts_data['alerts']).not_to be_empty
      expect(alerts_data['total_alerts']).to be >= 1
      expect(alerts_data['exceeded_count']).to be >= 1

      exceeded_alert = alerts_data['alerts'].find { |a| a['alert_type'] == 'exceeded' }
      expect(exceeded_alert).not_to be_nil
      expect(exceeded_alert['spending']).to eq(250.0)
      expect(exceeded_alert['remaining']).to be < 0
      expect(exceeded_alert['message']).to include('Budget exceeded')
    end

    it 'allows filtering alerts by type' do
      # Create two budgets - one exceeded, one near limit
      post '/api/budgets', {
        category_id: @category_id,
        amount: 200,
        period_start: '2025-01-01',
        period_end: '2025-01-31',
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      # Get only exceeded alerts
      get '/api/budgets/alerts/exceeded?user_id=1'
      expect(last_response.status).to eq(200)

      alerts_data = JSON.parse(last_response.body)
      exceeded_alerts = alerts_data['alerts'].select { |a| a['alert_type'] == 'exceeded' }
      expect(exceeded_alerts.length).to eq(alerts_data['total_alerts'])
      expect(alerts_data['exceeded_count']).to be >= 1
    end

    it 'supports custom threshold percentage for alerts' do
      # Create budget
      post '/api/budgets', {
        category_id: @category_id,
        amount: 500,
        period_start: '2025-01-01',
        period_end: '2025-01-31',
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      # With 80% threshold, spending of 250/500 = 50% should not trigger alert
      get '/api/budgets/alerts?user_id=1&threshold_percent=80'
      alerts_data_80 = JSON.parse(last_response.body)
      
      # With 40% threshold, spending of 250/500 = 50% should trigger alert
      get '/api/budgets/alerts?user_id=1&threshold_percent=40'
      alerts_data_40 = JSON.parse(last_response.body)

      expect(alerts_data_40['total_alerts']).to be >= alerts_data_80['total_alerts']
    end
  end

  describe 'F2P: Budget Alert When Approaching Limit' do
    it 'generates near_limit alert when spending approaches budget limit' do
      # Create budget with higher limit
      post '/api/budgets', {
        category_id: @category_id,
        amount: 500,
        period_start: '2025-01-01',
        period_end: '2025-01-31',
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      # Add more expenses to approach the limit
      post '/api/expenses', {
        amount: 200.0,
        date: '2025-01-25',
        description: 'Additional expense',
        category_id: @category_id,
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      # Total spending: 150 + 100 + 200 = 450 out of 500 (90%)
      # With 80% threshold, this should trigger a near_limit alert

      get '/api/budgets/alerts?user_id=1&threshold_percent=80'
      expect(last_response.status).to eq(200)

      alerts_data = JSON.parse(last_response.body)
      expect(alerts_data['alerts']).not_to be_empty

      near_limit_alert = alerts_data['alerts'].find { |a| a['alert_type'] == 'near_limit' }
      expect(near_limit_alert).not_to be_nil
      expect(near_limit_alert['spending']).to eq(450.0)
      expect(near_limit_alert['remaining']).to eq(50.0)
      expect(near_limit_alert['percentage_used']).to eq(90.0)
      expect(near_limit_alert['message']).to include('90.0% used')
      expect(near_limit_alert['message']).to include('Only $50.0 remaining')
    end

    it 'provides accurate alert counts and summary information' do
      # Create multiple budgets
      post '/api/budgets', {
        category_id: @category_id,
        amount: 200,
        period_start: '2025-01-01',
        period_end: '2025-01-31',
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      # Create another category and budget
      post '/api/categories', {
        name: 'Transportation',
        budget_limit: 300,
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }
      category_id_2 = JSON.parse(last_response.body)['id']

      post '/api/budgets', {
        category_id: category_id_2,
        amount: 300,
        period_start: '2025-01-01',
        period_end: '2025-01-31',
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      # Add expense for second category to trigger near_limit
      post '/api/expenses', {
        amount: 250.0,
        date: '2025-01-15',
        description: 'Transportation expense',
        category_id: category_id_2,
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      # Get all alerts
      get '/api/budgets/alerts?user_id=1&threshold_percent=80'
      expect(last_response.status).to eq(200)

      alerts_data = JSON.parse(last_response.body)
      expect(alerts_data['total_alerts']).to eq(alerts_data['exceeded_count'] + alerts_data['near_limit_count'])
      expect(alerts_data['total_alerts']).to be >= 2
    end
  end
end

