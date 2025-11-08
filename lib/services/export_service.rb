require_relative '../repositories/expense_repository'
require 'json'
require 'date'

# Service layer for expense export functionality
class ExportService
  def initialize(expense_repo = ExpenseRepository.new)
    @expense_repository = expense_repo
  end

  # Export expenses to CSV format
  # @param user_id [Integer] User ID to filter expenses
  # @param filters [Hash] Optional filters (category_id, start_date, end_date, min_amount, max_amount)
  # @return [String] CSV formatted string
  def export_to_csv(user_id, filters = {})
    expenses = get_expenses_for_export(user_id, filters)
    
    # Build CSV header
    headers = %w[id amount date description category_id user_id tags currency created_at]
    csv_lines = [headers.join(',')]
    
    # Add expense rows
    expenses.each do |expense|
      row = [
        expense.id,
        format_amount(expense.amount),
        format_date(expense.date),
        escape_csv_field(expense.description),
        expense.category_id,
        expense.user_id,
        format_tags_for_csv(expense.tags),
        expense.currency || 'USD',
        format_datetime(expense.created_at)
      ]
      csv_lines << row.join(',')
    end
    
    csv_lines.join("\n")
  end

  # Export expenses to JSON format
  # @param user_id [Integer] User ID to filter expenses
  # @param filters [Hash] Optional filters (category_id, start_date, end_date, min_amount, max_amount)
  # @return [String] JSON formatted string
  def export_to_json(user_id, filters = {})
    expenses = get_expenses_for_export(user_id, filters)
    
    expense_data = expenses.map do |expense|
      {
        id: expense.id,
        amount: expense.amount,
        date: format_date(expense.date),
        description: expense.description,
        category_id: expense.category_id,
        user_id: expense.user_id,
        tags: expense.tags || [],
        currency: expense.currency || 'USD',
        created_at: format_datetime(expense.created_at)
      }
    end
    
    JSON.pretty_generate(expense_data)
  end

  # Get expenses for export with filtering
  # @param user_id [Integer] User ID
  # @param filters [Hash] Filter options
  # @return [Array<Expense>] Array of expense objects
  def get_expenses_for_export(user_id, filters = {})
    @expense_repository.find_by_user(user_id, filters)
  end

  private

  # Format amount to 2 decimal places
  def format_amount(amount)
    format('%.2f', amount.to_f)
  end

  # Format date to YYYY-MM-DD
  def format_date(date)
    if date.is_a?(Date)
      date.strftime('%Y-%m-%d')
    elsif date.is_a?(String)
      Date.parse(date).strftime('%Y-%m-%d')
    else
      date.to_s
    end
  rescue ArgumentError
    date.to_s
  end

  # Format datetime to string
  def format_datetime(datetime)
    if datetime.is_a?(Time)
      datetime.strftime('%Y-%m-%d %H:%M:%S')
    elsif datetime.is_a?(Date)
      datetime.strftime('%Y-%m-%d %H:%M:%S')
    else
      datetime.to_s
    end
  end

  # Format tags for CSV - comma-separated within quotes
  def format_tags_for_csv(tags)
    return '""' if tags.nil? || tags.empty?
    
    tag_string = if tags.is_a?(Array)
      tags.join(',')
    else
      tags.to_s
    end
    
    # Escape quotes and wrap in quotes
    escaped = tag_string.gsub('"', '""')
    "\"#{escaped}\""
  end

  # Escape CSV field - handles commas, quotes, and newlines
  def escape_csv_field(field)
    return '""' if field.nil?
    
    field_str = field.to_s
    # Need to quote if contains special chars
    if field_str.include?(',') || field_str.include?('"') || field_str.include?("\n")
      escaped = field_str.gsub('"', '""')
      "\"#{escaped}\""
    else
      field_str
    end
  end
end

