require 'json'
require 'sinatra'
require 'date'
require_relative '../services/report_service'

# Controller for report generation API endpoints
class ReportController
  def initialize(service = ReportService.new)
    @service = service
  end

  def monthly_report(user_id, year, month)
    result = @service.generate_monthly_report(user_id.to_i, year.to_i, month.to_i)
    if result[:success]
      [200, { 'Content-Type' => 'application/json' }, result[:data].to_json]
    else
      [400, { 'Content-Type' => 'application/json' }, { errors: result[:errors] }.to_json]
    end
  end

  def yearly_report(user_id, year)
    result = @service.generate_yearly_report(user_id.to_i, year.to_i)
    if result[:success]
      [200, { 'Content-Type' => 'application/json' }, result[:data].to_json]
    else
      [400, { 'Content-Type' => 'application/json' }, { errors: result[:errors] }.to_json]
    end
  end

  def category_report(user_id, category_id, date_range = nil)
    result = @service.generate_category_report(user_id.to_i, category_id.to_i, date_range)
    if result[:success]
      [200, { 'Content-Type' => 'application/json' }, result[:data].to_json]
    else
      [400, { 'Content-Type' => 'application/json' }, { errors: result[:errors] }.to_json]
    end
  end
end

