require 'date'

# Utility module for validation functions
module Validators
  def self.validate_amount(amount)
    return false if amount.nil?
    return false unless amount.is_a?(Numeric)
    return false if amount <= 0
    true
  end

  def self.validate_date(date)
    return false if date.nil?
    return true if date.is_a?(Date)
    
    if date.is_a?(String)
      begin
        Date.parse(date)
        true
      rescue ArgumentError
        false
      end
    else
      false
    end
  end

  def self.validate_email(email)
    return false if email.nil? || email.strip.empty?
    return false unless email.include?('@')
    parts = email.split('@')
    return false if parts.length != 2
    return false if parts[0].empty? || parts[1].empty?
    return false unless parts[1].include?('.')
    true
  end

  def self.validate_date_range(start_date, end_date)
    return false if start_date.nil? || end_date.nil?
    start = start_date.is_a?(Date) ? start_date : Date.parse(start_date)
    end_dt = end_date.is_a?(Date) ? end_date : Date.parse(end_date)
    start <= end_dt
  rescue ArgumentError
    false
  end

  def self.validate_positive_number(value)
    return false if value.nil?
    return false unless value.is_a?(Numeric)
    value > 0
  end
end

