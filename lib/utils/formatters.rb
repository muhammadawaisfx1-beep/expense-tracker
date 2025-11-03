require 'date'

# Utility module for formatting functions
module Formatters
  def self.format_currency(amount, currency = 'USD')
    case currency
    when 'USD'
      "$#{format('%.2f', amount)}"
    when 'EUR'
      "€#{format('%.2f', amount)}"
    when 'GBP'
      "£#{format('%.2f', amount)}"
    else
      "#{format('%.2f', amount)} #{currency}"
    end
  end

  def self.format_date(date)
    return '' if date.nil?
    date.is_a?(Date) ? date.strftime('%Y-%m-%d') : Date.parse(date.to_s).strftime('%Y-%m-%d')
  rescue ArgumentError
    date.to_s
  end

  def self.format_date_long(date)
    return '' if date.nil?
    date_obj = date.is_a?(Date) ? date : Date.parse(date.to_s)
    date_obj.strftime('%B %d, %Y')
  rescue ArgumentError
    date.to_s
  end

  def self.format_percentage(value, decimals = 2)
    "#{format("%.#{decimals}f", value)}%"
  end

  def self.format_month_year(year, month)
    Date.new(year, month, 1).strftime('%B %Y')
  end
end

