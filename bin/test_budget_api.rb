#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'uri'

BASE_URL = 'http://localhost:9292'

def make_request(method, path, body = nil)
  uri = URI("#{BASE_URL}#{path}")
  http = Net::HTTP.new(uri.host, uri.port)
  
  case method
  when 'GET'
    request = Net::HTTP::Get.new(uri)
  when 'POST'
    request = Net::HTTP::Post.new(uri)
    request.body = body.to_json if body
    request['Content-Type'] = 'application/json'
  when 'PUT'
    request = Net::HTTP::Put.new(uri)
    request.body = body.to_json if body
    request['Content-Type'] = 'application/json'
  when 'DELETE'
    request = Net::HTTP::Delete.new(uri)
  end
  
  response = http.request(request)
  puts "Status: #{response.code}"
  puts "Response: #{JSON.pretty_generate(JSON.parse(response.body))}" rescue puts "Response: #{response.body}"
  puts "\n" + "="*60 + "\n"
  response
end

puts "Testing Budget API Endpoints\n"
puts "="*60 + "\n"

# Create a category first
puts "1. Creating category..."
category_response = make_request('POST', '/api/categories', {
  name: 'Food & Dining',
  budget_limit: 500,
  user_id: 1
})
category_id = JSON.parse(category_response.body)['id'] rescue 1
puts "Category ID: #{category_id}\n"

# Create a budget
puts "2. Creating budget..."
budget_response = make_request('POST', '/api/budgets', {
  category_id: category_id,
  amount: 500,
  period_start: '2025-01-01',
  period_end: '2025-01-31',
  user_id: 1
})
budget_id = JSON.parse(budget_response.body)['id'] rescue 1
puts "Budget ID: #{budget_id}\n"

# List budgets
puts "3. Listing all budgets..."
make_request('GET', "/api/budgets?user_id=1")

# Get specific budget
puts "4. Getting budget by ID..."
make_request('GET', "/api/budgets/#{budget_id}")

# Create an expense
puts "5. Creating expense..."
expense_response = make_request('POST', '/api/expenses', {
  amount: 150.0,
  date: '2025-01-15',
  description: 'Grocery shopping',
  category_id: category_id,
  user_id: 1
})

# Create another expense
puts "6. Creating another expense..."
make_request('POST', '/api/expenses', {
  amount: 100.0,
  date: '2025-01-20',
  description: 'Restaurant dinner',
  category_id: category_id,
  user_id: 1
})

# Get budget status
puts "7. Getting budget status..."
make_request('GET', "/api/budgets/#{budget_id}/status?user_id=1")

# Update budget
puts "8. Updating budget..."
make_request('PUT', "/api/budgets/#{budget_id}", {
  amount: 600,
  period_end: '2025-02-28'
})

# Get updated budget status
puts "9. Getting updated budget status..."
make_request('GET', "/api/budgets/#{budget_id}/status?user_id=1")

puts "\nAll tests completed!"

