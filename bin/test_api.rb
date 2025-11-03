#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'uri'

BASE_URL = 'http://localhost:9292'

def make_request(method, path, data = nil)
  uri = URI("#{BASE_URL}#{path}")
  
  case method.upcase
  when 'GET'
    request = Net::HTTP::Get.new(uri)
  when 'POST'
    request = Net::HTTP::Post.new(uri)
  when 'PUT'
    request = Net::HTTP::Put.new(uri)
  when 'DELETE'
    request = Net::HTTP::Delete.new(uri)
  end
  
  request['Content-Type'] = 'application/json'
  request.body = data.to_json if data
  
  response = Net::HTTP.start(uri.hostname, uri.port) do |http|
    http.request(request)
  end
  
  {
    status: response.code.to_i,
    body: response.body.empty? ? nil : JSON.parse(response.body)
  }
rescue => e
  { status: 0, error: e.message }
end

def print_result(test_name, result)
  if result[:error]
    puts "❌ #{test_name}: ERROR - #{result[:error]}"
    return false
  elsif result[:status] >= 200 && result[:status] < 300
    puts "✅ #{test_name}: SUCCESS (#{result[:status]})"
    puts "   Response: #{result[:body].to_json}" if result[:body]
    return true
  else
    puts "❌ #{test_name}: FAILED (#{result[:status]})"
    puts "   Response: #{result[:body]}" if result[:body]
    return false
  end
end

puts "=" * 60
puts "Expense Tracker API Test Script"
puts "=" * 60
puts ""

# Test 1: Health Check
puts "1. Testing Health Endpoint..."
result = make_request('GET', '/health')
health_ok = print_result('Health Check', result)
puts ""

unless health_ok
  puts "❌ Server is not running or not accessible!"
  puts "   Please start the server with: bundle exec rackup config.ru"
  exit 1
end

# Test 2: Create Category
puts "2. Testing Category Creation..."
category_data = {
  name: 'Food & Dining',
  budget_limit: 500,
  user_id: 1
}
result = make_request('POST', '/api/categories', category_data)
category_ok = print_result('Create Category', result)
category_id = result[:body]['id'] if category_ok && result[:body]
puts ""

# Test 3: List Categories
puts "3. Testing Category Listing..."
result = make_request('GET', '/api/categories?user_id=1')
list_categories_ok = print_result('List Categories', result)
puts ""

# Test 4: Create Expense
puts "4. Testing Expense Creation..."
expense_data = {
  amount: 45.50,
  date: '2025-01-15',
  description: 'Restaurant dinner',
  category_id: category_id,
  user_id: 1
}
result = make_request('POST', '/api/expenses', expense_data)
expense_ok = print_result('Create Expense', result)
expense_id = result[:body]['id'] if expense_ok && result[:body]
puts ""

# Test 5: Get Expense
puts "5. Testing Get Expense..."
if expense_id
  result = make_request('GET', "/api/expenses/#{expense_id}")
  get_expense_ok = print_result('Get Expense', result)
else
  puts "⏭️  Get Expense: SKIPPED (no expense ID)"
  get_expense_ok = false
end
puts ""

# Test 6: List Expenses
puts "6. Testing Expense Listing..."
result = make_request('GET', '/api/expenses?user_id=1')
list_expenses_ok = print_result('List Expenses', result)
puts ""

# Test 7: Calculate Total
puts "7. Testing Total Calculation..."
result = make_request('GET', '/api/expenses/1/total')
total_ok = print_result('Calculate Total', result)
puts ""

# Test 8: Monthly Report
puts "8. Testing Monthly Report..."
result = make_request('GET', '/api/reports/monthly?user_id=1&year=2025&month=1')
report_ok = print_result('Monthly Report', result)
puts ""

# Summary
puts "=" * 60
puts "Test Summary"
puts "=" * 60
total_tests = 8
passed = [health_ok, category_ok, list_categories_ok, expense_ok, get_expense_ok, list_expenses_ok, total_ok, report_ok].count(true)
failed = total_tests - passed

puts "Total Tests: #{total_tests}"
puts "✅ Passed: #{passed}"
puts "❌ Failed: #{failed}"
puts ""

if failed == 0
  puts "🎉 All tests passed!"
  exit 0
else
  puts "⚠️  Some tests failed. Check the output above."
  exit 1
end

