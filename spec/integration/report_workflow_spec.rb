require 'spec_helper'
require 'rack/test'
require_relative '../../lib/app'
require_relative '../../lib/models/expense'
require_relative '../../lib/models/category'
require 'date'

RSpec.describe 'Report Workflow Integration', type: :integration do
  include Rack::Test::Methods

  def app
    ExpenseTrackerApp
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
end

