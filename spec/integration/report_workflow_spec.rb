require 'spec_helper'
require 'rack/test'
require_relative '../../lib/app'
require_relative '../../lib/models/expense'
require_relative '../../lib/models/category'
require_relative '../../lib/repositories/expense_repository'
require_relative '../../lib/repositories/category_repository'
require 'date'

RSpec.describe 'Report Workflow Integration', type: :integration do
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

  describe 'P2P: Monthly Report Generation Workflow' do
    it 'allows creating expenses and generating a monthly report' do
      # Create multiple expenses in the same month
      expense1 = post '/api/expenses', {
        amount: 75.50,
        date: '2025-01-15',
        description: 'Lunch at restaurant',
        category_id: 1,
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)

      expense2 = post '/api/expenses', {
        amount: 120.00,
        date: '2025-01-20',
        description: 'Grocery shopping',
        category_id: 2,
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)

      expense3 = post '/api/expenses', {
        amount: 45.25,
        date: '2025-01-25',
        description: 'Coffee shop',
        category_id: 1,
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)

      # Generate monthly report for January 2025
      get '/api/reports/monthly?user_id=1&year=2025&month=1'
      expect(last_response.status).to eq(200)

      report_data = JSON.parse(last_response.body)
      expect(report_data['period']).to eq('2025-01')
      expect(report_data['total']).to eq(240.75)
      expect(report_data['expense_count']).to eq(3)
      expect(report_data['by_category']).to be_a(Hash)
    end
  end

  describe 'F2P: Monthly Report with Category Filter' do
    it 'creates categories and expenses, then generates a filtered monthly report' do
      # Create first category
      post '/api/categories', {
        name: 'Food & Dining',
        budget_limit: 500,
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)
      category1_data = JSON.parse(last_response.body)
      category1_id = category1_data['id']

      # Create second category
      post '/api/categories', {
        name: 'Transportation',
        budget_limit: 300,
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)
      category2_data = JSON.parse(last_response.body)
      category2_id = category2_data['id']

      # Create expenses in different categories within the same month
      post '/api/expenses', {
        amount: 50.00,
        date: '2025-01-10',
        description: 'Restaurant lunch',
        category_id: category1_id,
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)

      post '/api/expenses', {
        amount: 80.00,
        date: '2025-01-15',
        description: 'Uber ride',
        category_id: category2_id,
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)

      post '/api/expenses', {
        amount: 35.50,
        date: '2025-01-20',
        description: 'Coffee break',
        category_id: category1_id,
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)

      # Generate monthly report filtered by category1_id
      get "/api/reports/monthly?user_id=1&year=2025&month=1&category_id=#{category1_id}"
      expect(last_response.status).to eq(200)

      report_data = JSON.parse(last_response.body)
      expect(report_data['period']).to eq('2025-01')
      expect(report_data['total']).to eq(85.50)
      expect(report_data['expense_count']).to eq(2)
      expect(report_data['by_category']).to be_a(Hash)
      expect(report_data['by_category'].keys).to include(category1_id.to_s)
    end
  end

  describe 'P2P: Yearly Report Generation Workflow' do
    it 'creates expenses across months and generates yearly report' do
      post '/api/expenses', {
        amount: 100.00,
        date: '2025-01-15',
        description: 'Jan expense',
        category_id: 1,
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)

      post '/api/expenses', {
        amount: 150.00,
        date: '2025-02-20',
        description: 'Feb expense',
        category_id: 1,
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)

      post '/api/expenses', {
        amount: 200.00,
        date: '2025-06-10',
        description: 'June expense',
        category_id: 2,
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)

      post '/api/expenses', {
        amount: 75.50,
        date: '2025-12-25',
        description: 'Dec expense',
        category_id: 1,
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)

      get '/api/reports/yearly?user_id=1&year=2025'
      expect(last_response.status).to eq(200)

      report = JSON.parse(last_response.body)
      expect(report['year']).to eq(2025)
      expect(report['total']).to eq(525.50)
      expect(report['expense_count']).to eq(4)
      expect(report['by_month']).to be_an(Array)
      expect(report['by_month'].length).to eq(12)
      expect(report['by_month'].find { |m| m['month'] == 1 }['total']).to eq(100.00)
      expect(report['by_month'].find { |m| m['month'] == 2 }['total']).to eq(150.00)
      expect(report['by_month'].find { |m| m['month'] == 6 }['total']).to eq(200.00)
      expect(report['by_month'].find { |m| m['month'] == 12 }['total']).to eq(75.50)
      expect(report['by_category']).to be_a(Hash)
    end
  end

  describe 'F2P: Yearly Report with Category Breakdown' do
    it 'generates yearly report with category totals across months' do
      post '/api/categories', {
        name: 'Food & Dining',
        budget_limit: 1000,
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)
      cat1_data = JSON.parse(last_response.body)
      cat1_id = cat1_data['id']

      post '/api/categories', {
        name: 'Transportation',
        budget_limit: 500,
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)
      cat2_data = JSON.parse(last_response.body)
      cat2_id = cat2_data['id']

      post '/api/categories', {
        name: 'Entertainment',
        budget_limit: 300,
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)
      cat3_data = JSON.parse(last_response.body)
      cat3_id = cat3_data['id']

      post '/api/expenses', {
        amount: 50.00,
        date: '2025-01-10',
        description: 'Jan food',
        category_id: cat1_id,
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)

      post '/api/expenses', {
        amount: 80.00,
        date: '2025-03-15',
        description: 'Mar transport',
        category_id: cat2_id,
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)

      post '/api/expenses', {
        amount: 120.00,
        date: '2025-05-20',
        description: 'May food',
        category_id: cat1_id,
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)

      post '/api/expenses', {
        amount: 60.00,
        date: '2025-07-25',
        description: 'July entertainment',
        category_id: cat3_id,
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)

      post '/api/expenses', {
        amount: 100.00,
        date: '2025-09-30',
        description: 'Sep transport',
        category_id: cat2_id,
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)

      post '/api/expenses', {
        amount: 90.00,
        date: '2025-11-15',
        description: 'Nov food',
        category_id: cat1_id,
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)

      get '/api/reports/yearly?user_id=1&year=2025'
      expect(last_response.status).to eq(200)

      report = JSON.parse(last_response.body)
      expect(report['year']).to eq(2025)
      expect(report['total']).to eq(500.00)
      expect(report['expense_count']).to eq(6)
      expect(report['by_category']).to be_a(Hash)
      expect(report['by_category'][cat1_id.to_s]).to eq(260.00)
      expect(report['by_category'][cat2_id.to_s]).to eq(180.00)
      expect(report['by_category'][cat3_id.to_s]).to eq(60.00)
      expect(report['by_month']).to be_an(Array)
      expect(report['by_month'].length).to eq(12)
    end
  end
end

