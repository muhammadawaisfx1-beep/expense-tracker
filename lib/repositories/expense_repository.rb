require_relative '../models/expense'

# Repository for expense data access
class ExpenseRepository
  def initialize(storage = {})
    @storage = storage
    @next_id = 1
  end

  def create(expense)
    expense.id = @next_id
    @next_id += 1
    @storage[expense.id] = expense.dup
    @storage[expense.id]
  end

  def find_by_id(id)
    @storage[id]
  end

  def find_by_user(user_id, filters = {})
    expenses = @storage.values.select { |e| e.user_id == user_id }

    expenses = expenses.select { |e| e.category_id == filters[:category_id] } if filters[:category_id]
    expenses = expenses.select { |e| e.date >= filters[:start_date] && e.date <= filters[:end_date] } if filters[:start_date] && filters[:end_date]
    expenses = expenses.select { |e| e.description.downcase.include?(filters[:search].downcase) } if filters[:search]

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

