require_relative '../../config/app'

# Expense model representing a single expense entry
class Expense
  attr_accessor :id, :amount, :date, :description, :category_id, :user_id, :tags, :currency, :created_at

  VALID_CURRENCIES = %w[USD EUR GBP JPY CAD AUD CHF CNY INR].freeze

  def initialize(params = {})
    @id = params[:id]
    @amount = params[:amount]
    @date = params[:date] || Date.today
    @description = params[:description] || ''
    @category_id = params[:category_id]
    @user_id = params[:user_id]
    @tags = normalize_tags(params[:tags])
    @currency = params[:currency] || AppConfig::DEFAULT_CURRENCY
    @created_at = params[:created_at] || Time.now
  end

  def normalize_tags(tags)
    return [] if tags.nil?
    return [] if tags.is_a?(String) && tags.strip.empty?
    
    # Convert string to array if needed (comma-separated or single tag)
    tag_array = if tags.is_a?(String)
      tags.split(',').map(&:strip).reject(&:empty?)
    elsif tags.is_a?(Array)
      tags.map { |tag| tag.is_a?(String) ? tag.strip : tag.to_s.strip }.reject(&:empty?)
    else
      [tags.to_s.strip]
    end
    
    tag_array.uniq
  end

  def valid?
    return false if amount.nil? || amount <= 0
    return false if date.nil?
    return false if user_id.nil?
    return false if description.to_s.strip.empty?
    return false if currency && !VALID_CURRENCIES.include?(currency.to_s.upcase)
    true
  end

  def to_hash
    {
      id: id,
      amount: amount,
      date: date.to_s,
      description: description,
      category_id: category_id,
      user_id: user_id,
      tags: tags,
      currency: currency,
      created_at: created_at.to_s
    }
  end

  def to_json(*args)
    to_hash.to_json(*args)
  end
end

