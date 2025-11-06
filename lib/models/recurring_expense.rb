require 'date'

# RecurringExpense model representing a recurring expense template
class RecurringExpense
  attr_accessor :id, :amount, :description, :category_id, :user_id, :frequency, 
                :start_date, :end_date, :next_occurrence_date, :created_at

  VALID_FREQUENCIES = %w[daily weekly monthly yearly].freeze

  def initialize(params = {})
    @id = params[:id]
    @amount = params[:amount]
    @description = params[:description] || ''
    @category_id = params[:category_id]
    @user_id = params[:user_id]
    @frequency = params[:frequency]
    @start_date = params[:start_date]
    @end_date = params[:end_date]
    @next_occurrence_date = params[:next_occurrence_date] || params[:start_date]
    @created_at = params[:created_at] || Time.now
  end

  def valid?
    return false if amount.nil? || amount <= 0
    return false if description.to_s.strip.empty?
    return false if user_id.nil?
    return false if frequency.nil? || !VALID_FREQUENCIES.include?(frequency.to_s.downcase)
    return false if start_date.nil?
    return false if end_date && start_date && end_date < start_date
    true
  end

  def active?(date = Date.today)
    return false if date < start_date
    return false if end_date && date > end_date
    true
  end

  def calculate_next_occurrence(current_date = nil)
    current = current_date || Date.today
    return nil unless active?(current)

    base_date = next_occurrence_date || start_date
    base_date = Date.parse(base_date.to_s) if base_date.is_a?(String)
    current = Date.parse(current.to_s) if current.is_a?(String)

    return nil if base_date > current

    case frequency.to_s.downcase
    when 'daily'
      base_date + 1
    when 'weekly'
      base_date + 7
    when 'monthly'
      next_month_date(base_date)
    when 'yearly'
      next_year_date(base_date)
    else
      nil
    end
  end

  def to_hash
    {
      id: id,
      amount: amount,
      description: description,
      category_id: category_id,
      user_id: user_id,
      frequency: frequency,
      start_date: start_date.to_s,
      end_date: end_date&.to_s,
      next_occurrence_date: next_occurrence_date.to_s,
      created_at: created_at.to_s
    }
  end

  def to_json(*args)
    to_hash.to_json(*args)
  end

  private

  def next_month_date(date)
    date_obj = date.is_a?(Date) ? date : Date.parse(date.to_s)
    next_month = date_obj >> 1
    
    # Handle edge case: if start date is 31st and next month has fewer days
    if date_obj.day > 28
      last_day_of_month = Date.new(next_month.year, next_month.month, -1)
      next_month = last_day_of_month if date_obj.day > last_day_of_month.day
    end
    
    next_month
  end

  def next_year_date(date)
    date_obj = date.is_a?(Date) ? date : Date.parse(date.to_s)
    next_year = Date.new(date_obj.year + 1, date_obj.month, date_obj.day)
    
    # Handle leap year edge case (Feb 29)
    if date_obj.month == 2 && date_obj.day == 29
      next_year = Date.new(date_obj.year + 1, 2, 28) unless Date.valid_date?(next_year.year, 2, 29)
    end
    
    next_year
  end
end

