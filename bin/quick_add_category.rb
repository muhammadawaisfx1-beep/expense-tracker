#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'uri'

if ARGV.length < 2
  puts "Usage: ruby bin/quick_add_category.rb <name> <budget_limit>"
  puts "Example: ruby bin/quick_add_category.rb 'Food & Dining' 500"
  exit 1
end

name = ARGV[0]
budget_limit = ARGV[1].to_f
user_id = 1

uri = URI('http://localhost:9292/api/categories')
request = Net::HTTP::Post.new(uri)
request['Content-Type'] = 'application/json'
request.body = {
  name: name,
  budget_limit: budget_limit,
  user_id: user_id
}.to_json

begin
  response = Net::HTTP.start(uri.hostname, uri.port) do |http|
    http.request(request)
  end

  if response.code.to_i >= 200 && response.code.to_i < 300
    data = JSON.parse(response.body)
    puts "✅ Category created successfully!"
    puts "   ID: #{data['id']}"
    puts "   Name: #{data['name']}"
    puts "   Budget Limit: $#{data['budget_limit']}"
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

