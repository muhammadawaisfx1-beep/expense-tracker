require 'json'
require_relative '../services/export_service'

# Controller for expense export API endpoints
class ExportController
  def initialize(service = ExportService.new)
    @service = service
  end

  # Export expenses to CSV format
  # @param user_id [String, Integer] User ID
  # @param filters [Hash] Optional filters
  # @return [Array] [status_code, headers, body]
  def csv_export(user_id, filters = {})
    begin
      user_id_int = user_id.to_i
      return [400, { 'Content-Type' => 'application/json' }, { error: 'Invalid user_id' }.to_json] if user_id_int <= 0

      csv_data = @service.export_to_csv(user_id_int, filters)
      [200, { 'Content-Type' => 'text/csv; charset=utf-8' }, csv_data]
    rescue => e
      [500, { 'Content-Type' => 'application/json' }, { error: e.message }.to_json]
    end
  end

  # Export expenses to JSON format
  # @param user_id [String, Integer] User ID
  # @param filters [Hash] Optional filters
  # @return [Array] [status_code, headers, body]
  def json_export(user_id, filters = {})
    begin
      user_id_int = user_id.to_i
      return [400, { 'Content-Type' => 'application/json' }, { error: 'Invalid user_id' }.to_json] if user_id_int <= 0

      json_data = @service.export_to_json(user_id_int, filters)
      [200, { 'Content-Type' => 'application/json; charset=utf-8' }, json_data]
    rescue => e
      [500, { 'Content-Type' => 'application/json' }, { error: e.message }.to_json]
    end
  end
end

