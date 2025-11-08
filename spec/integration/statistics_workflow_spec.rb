require 'spec_helper'
require 'rack/test'
require_relative '../../lib/app'
require_relative '../../lib/models/expense'
require_relative '../../lib/models/category'
require_relative '../../lib/repositories/expense_repository'
require_relative '../../lib/repositories/category_repository'
require 'date'

RSpec.describe 'Statistics Workflow Integration', type: :integration do
  include Rack::Test::Methods

  def app
    ExpenseTrackerApp
  end

  before do
    # Clear repositories before each test
    ExpenseRepository.class_variable_set(:@@storage, {})
    ExpenseRepository.class_variable_set(:@@next_id, 1)
    CategoryRepository.class_variable_set(:@@storage, {})
    CategoryRepository.class_variable_set(:@@next_id, 1)
  end

  describe 'P2P: Get Statistics Workflow' do
    it 'allows creating expenses and retrieving comprehensive statistics' do
      # Create categories
      post '/api/categories', {
        name: 'Food & Dining',
        budget_limit: 500,
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)
      cat1_data = JSON.parse(last_response.body)
      cat1_id = cat1_data['id']

      post '/api/categories', {
        name: 'Transportation',
        budget_limit: 300,
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)
      cat2_data = JSON.parse(last_response.body)
      cat2_id = cat2_data['id']

      # Create multiple expenses with different categories and currencies
      post '/api/expenses', {
        amount: 75.50,
        date: '2025-01-15',
        description: 'Lunch at restaurant',
        category_id: cat1_id,
        user_id: 1,
        tags: ['food', 'dining'],
        currency: 'USD'
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)

      post '/api/expenses', {
        amount: 120.00,
        date: '2025-01-20',
        description: 'Grocery shopping',
        category_id: cat1_id,
        user_id: 1,
        tags: ['groceries'],
        currency: 'USD'
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)

      post '/api/expenses', {
        amount: 45.25,
        date: '2025-01-25',
        description: 'Bus ticket',
        category_id: cat2_id,
        user_id: 1,
        tags: [],
        currency: 'EUR'
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)

      # Get statistics
      get '/api/statistics?user_id=1'
      expect(last_response.status).to eq(200)
      expect(last_response.headers['Content-Type']).to include('application/json')

      stats_data = JSON.parse(last_response.body)

      # Verify response structure
      expect(stats_data).to have_key('user_id')
      expect(stats_data).to have_key('date_range')
      expect(stats_data).to have_key('summary')
      expect(stats_data).to have_key('trends')
      expect(stats_data).to have_key('category_breakdown')
      expect(stats_data).to have_key('currency_breakdown')

      # Verify summary statistics
      expect(stats_data['summary']['total_spending']).to eq(240.75)
      expect(stats_data['summary']['expense_count']).to eq(3)
      expect(stats_data['summary']['largest_expense']).to eq(120.00)
      expect(stats_data['summary']['smallest_expense']).to eq(45.25)
      expect(stats_data['summary']['average_expense']).to eq(80.25)

      # Verify date range
      expect(stats_data['date_range']['start']).to eq('2025-01-15')
      expect(stats_data['date_range']['end']).to eq('2025-01-25')

      # Verify trends
      expect(stats_data['trends']).to have_key('daily_average')
      expect(stats_data['trends']).to have_key('weekly_average')
      expect(stats_data['trends']).to have_key('monthly_average')
      expect(stats_data['trends']['daily_average']).to be > 0
      expect(stats_data['trends']['weekly_average']).to be > 0
      expect(stats_data['trends']['monthly_average']).to be > 0

      # Verify category breakdown
      expect(stats_data['category_breakdown']).to be_an(Array)
      expect(stats_data['category_breakdown'].length).to eq(2)
      
      food_category = stats_data['category_breakdown'].find { |c| c['category_id'] == cat1_id }
      expect(food_category).not_to be_nil
      expect(food_category['category_name']).to eq('Food & Dining')
      expect(food_category['amount']).to eq(195.50)
      expect(food_category['percentage']).to be > 0

      transport_category = stats_data['category_breakdown'].find { |c| c['category_id'] == cat2_id }
      expect(transport_category).not_to be_nil
      expect(transport_category['category_name']).to eq('Transportation')
      expect(transport_category['amount']).to eq(45.25)

      # Verify currency breakdown
      expect(stats_data['currency_breakdown']).to be_an(Array)
      expect(stats_data['currency_breakdown'].length).to eq(2)
      
      usd_currency = stats_data['currency_breakdown'].find { |c| c['currency'] == 'USD' }
      expect(usd_currency).not_to be_nil
      expect(usd_currency['amount']).to eq(195.50)
      expect(usd_currency['percentage']).to be > 0

      eur_currency = stats_data['currency_breakdown'].find { |c| c['currency'] == 'EUR' }
      expect(eur_currency).not_to be_nil
      expect(eur_currency['amount']).to eq(45.25)
    end
  end

  describe 'F2P: Statistics with Date Range' do
    it 'creates expenses across different date ranges and filters statistics correctly' do
      # Create category
      post '/api/categories', {
        name: 'Food & Dining',
        budget_limit: 500,
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)
      cat_data = JSON.parse(last_response.body)
      cat_id = cat_data['id']

      # Create expenses in January
      post '/api/expenses', {
        amount: 50.00,
        date: '2025-01-10',
        description: 'Jan expense 1',
        category_id: cat_id,
        user_id: 1,
        currency: 'USD'
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)

      post '/api/expenses', {
        amount: 80.00,
        date: '2025-01-15',
        description: 'Jan expense 2',
        category_id: cat_id,
        user_id: 1,
        currency: 'USD'
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)

      # Create expenses in February
      post '/api/expenses', {
        amount: 120.00,
        date: '2025-02-05',
        description: 'Feb expense 1',
        category_id: cat_id,
        user_id: 1,
        currency: 'USD'
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)

      post '/api/expenses', {
        amount: 35.50,
        date: '2025-02-10',
        description: 'Feb expense 2',
        category_id: cat_id,
        user_id: 1,
        currency: 'EUR'
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)

      # Get statistics for January only
      get '/api/statistics?user_id=1&start_date=2025-01-01&end_date=2025-01-31'
      expect(last_response.status).to eq(200)

      jan_stats = JSON.parse(last_response.body)

      # Verify only January expenses are included
      expect(jan_stats['summary']['expense_count']).to eq(2)
      expect(jan_stats['summary']['total_spending']).to eq(130.00)
      expect(jan_stats['date_range']['start']).to eq('2025-01-10')
      expect(jan_stats['date_range']['end']).to eq('2025-01-15')
      expect(jan_stats['currency_breakdown'].length).to eq(1)
      expect(jan_stats['currency_breakdown'][0]['currency']).to eq('USD')

      # Get statistics for February only
      get '/api/statistics?user_id=1&start_date=2025-02-01&end_date=2025-02-28'
      expect(last_response.status).to eq(200)

      feb_stats = JSON.parse(last_response.body)

      # Verify only February expenses are included
      expect(feb_stats['summary']['expense_count']).to eq(2)
      expect(feb_stats['summary']['total_spending']).to eq(155.50)
      expect(feb_stats['date_range']['start']).to eq('2025-02-05')
      expect(feb_stats['date_range']['end']).to eq('2025-02-10')
      expect(feb_stats['currency_breakdown'].length).to eq(2)

      # Get statistics for all expenses (no date filter)
      get '/api/statistics?user_id=1'
      expect(last_response.status).to eq(200)

      all_stats = JSON.parse(last_response.body)

      # Verify all expenses are included
      expect(all_stats['summary']['expense_count']).to eq(4)
      expect(all_stats['summary']['total_spending']).to eq(285.50)
      expect(all_stats['date_range']['start']).to eq('2025-01-10')
      expect(all_stats['date_range']['end']).to eq('2025-02-10')

      # Get statistics for a date range with no expenses
      get '/api/statistics?user_id=1&start_date=2025-03-01&end_date=2025-03-31'
      expect(last_response.status).to eq(200)

      empty_stats = JSON.parse(last_response.body)

      # Verify empty statistics
      expect(empty_stats['summary']['expense_count']).to eq(0)
      expect(empty_stats['summary']['total_spending']).to eq(0.0)
      expect(empty_stats['category_breakdown']).to eq([])
      expect(empty_stats['currency_breakdown']).to eq([])
    end
  end
end

