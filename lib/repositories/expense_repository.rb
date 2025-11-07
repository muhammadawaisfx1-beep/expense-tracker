require_relative '../models/expense'

# Repository for expense data access
class ExpenseRepository
  # Shared storage across all repository instances
  @@storage = {}
  @@next_id = 1

  def initialize(storage = nil)
    @storage = storage || @@storage
    @next_id = @@next_id
  end

  def create(expense)
    expense.id = @@next_id
    @@next_id += 1
    @storage[expense.id] = expense.dup
    @storage[expense.id]
  end

  def find_by_id(id)
    @storage[id]
  end

  def find_by_user(user_id, filters = {})
    expenses = @storage.values.select { |e| e.user_id == user_id }

    # Filter by category
    expenses = expenses.select { |e| e.category_id == filters[:category_id] } if filters[:category_id]

    # Filter by date range
    if filters[:start_date] && filters[:end_date]
      expenses = expenses.select do |e|
        expense_date = e.date.is_a?(Date) ? e.date : Date.parse(e.date.to_s)
        expense_date >= filters[:start_date] && expense_date <= filters[:end_date]
      end
    end

    # Search by description (case-insensitive)
    if filters[:search]
      search_term = filters[:search].downcase
      expenses = expenses.select do |e|
        e.description.downcase.include?(search_term)
      end
    end

    # Filter by minimum amount
    if filters[:min_amount]
      expenses = expenses.select { |e| e.amount >= filters[:min_amount].to_f }
    end

    # Filter by maximum amount
    if filters[:max_amount]
      expenses = expenses.select { |e| e.amount <= filters[:max_amount].to_f }
    end

    # Filter by tags (expense must have all specified tags)
    if filters[:tags]
      tag_filter = filters[:tags].is_a?(Array) ? filters[:tags] : [filters[:tags]]
      tag_filter = tag_filter.map(&:to_s).map(&:strip).reject(&:empty?)
      expenses = expenses.select do |e|
        expense_tags = (e.tags || []).map(&:to_s).map(&:downcase)
        tag_filter.map(&:downcase).all? { |tag| expense_tags.include?(tag.downcase) }
      end
    end

    # Sorting
    sort_by = filters[:sort_by] || 'date'
    order = filters[:order] || 'desc'

    case sort_by.to_s
    when 'date'
      expenses = expenses.sort_by(&:date)
    when 'amount'
      expenses = expenses.sort_by(&:amount)
    when 'description'
      expenses = expenses.sort_by { |e| e.description.downcase }
    end

    expenses.reverse! if order.to_s.downcase == 'desc'

    expenses
  end

  def update(expense)
    return nil unless @storage.key?(expense.id)
    @storage[expense.id] = expense.dup
    @storage[expense.id]
  end

  def delete(id)
    @storage.delete(id)
  end

  def count
    @storage.count
  end

  def all
    @storage.values
  end
end

