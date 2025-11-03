# Budget model representing a budget period for a category
class Budget
  attr_accessor :id, :category_id, :amount, :period_start, :period_end, :user_id, :created_at

  def initialize(params = {})
    @id = params[:id]
    @category_id = params[:category_id]
    @amount = params[:amount]
    @period_start = params[:period_start]
    @period_end = params[:period_end]
    @user_id = params[:user_id]
    @created_at = params[:created_at] || Time.now
  end

  def valid?
    return false if category_id.nil?
    return false if amount.nil? || amount <= 0
    return false if period_start.nil?
    return false if period_end.nil?
    return false if period_start >= period_end
    return false if user_id.nil?
    true
  end

  def active?(date = Date.today)
    date >= period_start && date <= period_end
  end

  def to_hash
    {
      id: id,
      category_id: category_id,
      amount: amount,
      period_start: period_start.to_s,
      period_end: period_end.to_s,
      user_id: user_id,
      created_at: created_at.to_s
    }
  end

  def to_json(*args)
    to_hash.to_json(*args)
  end
end

