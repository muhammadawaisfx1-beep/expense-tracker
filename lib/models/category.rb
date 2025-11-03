# Category model representing an expense category
class Category
  attr_accessor :id, :name, :budget_limit, :user_id, :created_at, :updated_at

  def initialize(params = {})
    @id = params[:id]
    @name = params[:name] || ''
    @budget_limit = params[:budget_limit]
    @user_id = params[:user_id]
    @created_at = params[:created_at] || Time.now
    @updated_at = params[:updated_at] || Time.now
  end

  def valid?
    return false if name.nil? || name.strip.empty?
    return false if user_id.nil?
    return false if budget_limit && budget_limit < 0
    true
  end

  def to_hash
    {
      id: id,
      name: name,
      budget_limit: budget_limit,
      user_id: user_id,
      created_at: created_at.to_s,
      updated_at: updated_at.to_s
    }
  end

  def to_json(*args)
    to_hash.to_json(*args)
  end
end

