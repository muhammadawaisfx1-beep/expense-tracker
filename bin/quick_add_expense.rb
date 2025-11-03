#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'uri'

if ARGV.length < 3
  puts "Usage: ruby bin/quick_add_expense.rb <amount> <description> <date> [category_id]"
  puts "Example: ruby bin/quick_add_expense.rb 45.50 'Lunch' '2025-01-15' 1"
  exit 1
end

amount = ARGV[0].to_f
description = ARGV[1]
date = ARGV[2]
category_id = ARGV[3]&.to_i
user_id = 1

uri = URI('http://localhost:9292/api/expenses')
request = Net::HTTP::Post.new(uri)
request['Content-Type'] = 'application/json'
request.body = {
  amount: amount,
  date: date,
  description: description,
  category_id: category_id,
  user_id: user_id
}.to_json

begin
  response = Net::HTTP.start(uri.hostname, uri.port) do |http|
    http.request(request)
  end

  if response.code.to_i >= 200 && response.code.to_i < 300
    data = JSON.parse(response.body)
    puts "✅ Expense added successfully!"
    puts "   ID: #{data['id']}"
    puts "   Amount: $#{data['amount']}"
    puts "   Description: #{data['description']}"
    puts "   Date: #{data['date']}"
  else
    error = JSON.parse(response.body)
    puts "❌ Error: #{error['errors']&.join(', ')}"
    exit 1
  end
rescue => e
  puts "❌ Connection error: #{e.message}"
  puts "   Make sure the server is running: bundle exec rackup config.ru"
  exit 1
end

