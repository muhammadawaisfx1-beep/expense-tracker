require 'json'
require 'sinatra'
require 'date'
require_relative '../services/statistics_service'

# Controller for statistics dashboard API endpoints
class StatisticsController
  def initialize(service = StatisticsService.new)
    @service = service
  end

  def dashboard(user_id, date_range = nil)
    result = @service.get_statistics(user_id.to_i, date_range)
    [200, { 'Content-Type' => 'application/json' }, result.to_json]
  rescue StandardError => e
    [500, { 'Content-Type' => 'application/json' }, { errors: [e.message] }.to_json]
  end
end

