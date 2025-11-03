# Expense model representing a single expense entry
class Expense
  attr_accessor :id, :amount, :date, :description, :category_id, :user_id, :tags, :created_at

  def initialize(params = {})
    @id = params[:id]
    @amount = params[:amount]
    @date = params[:date] || Date.today
    @description = params[:description] || ''
    @category_id = params[:category_id]
    @user_id = params[:user_id]
    @tags = params[:tags] || []
    @created_at = params[:created_at] || Time.now
  end

  def valid?
    return false if amount.nil? || amount <= 0
    return false if date.nil?
    return false if user_id.nil?
    return false if description.to_s.strip.empty?
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
      created_at: created_at.to_s
    }
  end

  def to_json(*args)
    to_hash.to_json(*args)
  end
end

