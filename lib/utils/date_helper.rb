require 'date'

# Utility module for date operations
module DateHelper
  def self.start_of_month(year, month)
    Date.new(year, month, 1)
  end

  def self.end_of_month(year, month)
    start = start_of_month(year, month)
    start.next_month.prev_day
  end

  def self.start_of_year(year)
    Date.new(year, 1, 1)
  end

  def self.end_of_year(year)
    Date.new(year, 12, 31)
  end

  def self.days_in_month(year, month)
    end_of_month(year, month).day
  end

  def self.months_between(start_date, end_date)
    (end_date.year * 12 + end_date.month) - (start_date.year * 12 + start_date.month)
  end

  def self.is_same_month?(date1, date2)
    date1.year == date2.year && date1.month == date2.month
  end

  def self.is_same_year?(date1, date2)
    date1.year == date2.year
  end

  def self.parse_safe(date_string)
    Date.parse(date_string)
  rescue ArgumentError
    nil
  end
end

