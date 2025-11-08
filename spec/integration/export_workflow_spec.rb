require 'spec_helper'
require 'rack/test'
require_relative '../../lib/app'
require_relative '../../lib/models/expense'
require_relative '../../lib/models/category'
require_relative '../../lib/repositories/expense_repository'
require_relative '../../lib/repositories/category_repository'
require 'date'

RSpec.describe 'Export Workflow Integration', type: :integration do
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

  describe 'P2P: CSV Export Workflow' do
    it 'allows creating expenses and exporting them to CSV format' do
      # Create a category first
      post '/api/categories', {
        name: 'Food & Dining',
        budget_limit: 500,
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)
      category_data = JSON.parse(last_response.body)
      category_id = category_data['id']

      # Create multiple expenses
      expense1 = post '/api/expenses', {
        amount: 75.50,
        date: '2025-01-15',
        description: 'Lunch at restaurant',
        category_id: category_id,
        user_id: 1,
        tags: ['food', 'dining'],
        currency: 'USD'
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)

      expense2 = post '/api/expenses', {
        amount: 120.00,
        date: '2025-01-20',
        description: 'Grocery shopping',
        category_id: category_id,
        user_id: 1,
        tags: ['groceries'],
        currency: 'USD'
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)

      expense3 = post '/api/expenses', {
        amount: 45.25,
        date: '2025-01-25',
        description: 'Coffee shop',
        category_id: category_id,
        user_id: 1,
        tags: [],
        currency: 'EUR'
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)

      # Export to CSV
      get '/api/export/csv?user_id=1'
      expect(last_response.status).to eq(200)
      expect(last_response.headers['Content-Type']).to include('text/csv')

      csv_data = last_response.body
      lines = csv_data.split("\n")

      # Verify CSV header
      expect(lines[0]).to eq('id,amount,date,description,category_id,user_id,tags,currency,created_at')

      # Verify CSV contains all expenses
      expect(lines.length).to eq(4) # header + 3 expenses

      # Verify first expense in CSV
      expect(lines[1]).to include('75.50')
      expect(lines[1]).to include('2025-01-15')
      expect(lines[1]).to include('Lunch at restaurant')
      expect(lines[1]).to include('"food,dining"')
      expect(lines[1]).to include('USD')

      # Verify second expense in CSV
      expect(lines[2]).to include('120.00')
      expect(lines[2]).to include('2025-01-20')
      expect(lines[2]).to include('Grocery shopping')
      expect(lines[2]).to include('"groceries"')

      # Verify third expense in CSV
      expect(lines[3]).to include('45.25')
      expect(lines[3]).to include('2025-01-25')
      expect(lines[3]).to include('Coffee shop')
      expect(lines[3]).to include('EUR')
    end
  end

  describe 'F2P: Export Filtered Expenses - CSV' do
    it 'creates expenses with different categories and dates, then exports filtered CSV' do
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

      # Create expenses in different categories and dates
      post '/api/expenses', {
        amount: 50.00,
        date: '2025-01-10',
        description: 'Jan food expense',
        category_id: cat1_id,
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)

      post '/api/expenses', {
        amount: 80.00,
        date: '2025-01-15',
        description: 'Jan transport expense',
        category_id: cat2_id,
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)

      post '/api/expenses', {
        amount: 35.50,
        date: '2025-01-20',
        description: 'Jan food expense 2',
        category_id: cat1_id,
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)

      post '/api/expenses', {
        amount: 120.00,
        date: '2025-02-05',
        description: 'Feb food expense',
        category_id: cat1_id,
        user_id: 1
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)

      # Export CSV filtered by category
      get "/api/export/csv?user_id=1&category_id=#{cat1_id}"
      expect(last_response.status).to eq(200)
      expect(last_response.headers['Content-Type']).to include('text/csv')

      csv_data = last_response.body
      lines = csv_data.split("\n")

      # Should have header + 3 expenses (2 from Jan, 1 from Feb, all category 1)
      expect(lines.length).to eq(4)
      expect(lines[1]).to include('50.00')
      expect(lines[1]).to include('Jan food expense')
      expect(lines[2]).to include('35.50')
      expect(lines[2]).to include('Jan food expense 2')
      expect(lines[3]).to include('120.00')
      expect(lines[3]).to include('Feb food expense')

      # Export CSV filtered by date range
      get '/api/export/csv?user_id=1&start_date=2025-01-01&end_date=2025-01-31'
      expect(last_response.status).to eq(200)

      csv_data = last_response.body
      lines = csv_data.split("\n")

      # Should have header + 3 expenses (all from January)
      expect(lines.length).to eq(4)
      expect(lines[1]).to include('2025-01-10')
      expect(lines[2]).to include('2025-01-15')
      expect(lines[3]).to include('2025-01-20')

      # Export CSV with combined filters (category + date range)
      get "/api/export/csv?user_id=1&category_id=#{cat1_id}&start_date=2025-01-01&end_date=2025-01-31"
      expect(last_response.status).to eq(200)

      csv_data = last_response.body
      lines = csv_data.split("\n")

      # Should have header + 2 expenses (category 1, January only)
      expect(lines.length).to eq(3)
      expect(lines[1]).to include('50.00')
      expect(lines[1]).to include('Jan food expense')
      expect(lines[2]).to include('35.50')
      expect(lines[2]).to include('Jan food expense 2')
    end
  end

  describe 'F2P: Export Filtered Expenses - JSON' do
    it 'creates expenses with different categories and dates, then exports filtered JSON' do
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

      # Create expenses
      post '/api/expenses', {
        amount: 50.00,
        date: '2025-01-10',
        description: 'Jan food expense',
        category_id: cat1_id,
        user_id: 1,
        tags: ['food'],
        currency: 'USD'
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)

      post '/api/expenses', {
        amount: 80.00,
        date: '2025-01-15',
        description: 'Jan transport expense',
        category_id: cat2_id,
        user_id: 1,
        tags: ['transport'],
        currency: 'USD'
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)

      post '/api/expenses', {
        amount: 35.50,
        date: '2025-01-20',
        description: 'Jan food expense 2',
        category_id: cat1_id,
        user_id: 1,
        tags: ['food', 'dining'],
        currency: 'EUR'
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to be_between(200, 201)

      # Export JSON filtered by category
      get "/api/export/json?user_id=1&category_id=#{cat1_id}"
      expect(last_response.status).to eq(200)
      expect(last_response.headers['Content-Type']).to include('application/json')

      json_data = JSON.parse(last_response.body)
      expect(json_data).to be_an(Array)
      expect(json_data.length).to eq(2)

      # Verify filtered expenses
      expect(json_data[0]['description']).to eq('Jan food expense')
      expect(json_data[0]['category_id']).to eq(cat1_id)
      expect(json_data[0]['tags']).to eq(['food'])
      expect(json_data[1]['description']).to eq('Jan food expense 2')
      expect(json_data[1]['category_id']).to eq(cat1_id)
      expect(json_data[1]['tags']).to eq(['food', 'dining'])

      # Export JSON filtered by date range
      get '/api/export/json?user_id=1&start_date=2025-01-01&end_date=2025-01-31'
      expect(last_response.status).to eq(200)

      json_data = JSON.parse(last_response.body)
      expect(json_data.length).to eq(3)

      # Verify all expenses are from January
      json_data.each do |expense|
        expect(expense['date']).to match(/^2025-01-/)
      end

      # Export JSON with combined filters
      get "/api/export/json?user_id=1&category_id=#{cat1_id}&start_date=2025-01-01&end_date=2025-01-31&min_amount=40"
      expect(last_response.status).to eq(200)

      json_data = JSON.parse(last_response.body)
      expect(json_data.length).to eq(1)
      expect(json_data[0]['description']).to eq('Jan food expense')
      expect(json_data[0]['amount']).to eq(50.00)
    end
  end
end

