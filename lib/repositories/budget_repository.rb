require_relative '../models/budget'

# Repository for budget data access
class BudgetRepository
  # Shared storage across all repository instances
  @@storage = {}
  @@next_id = 1

  def initialize(storage = nil)
    @storage = storage || @@storage
    @next_id = @@next_id
  end

  def create(budget)
    budget.id = @@next_id
    @@next_id += 1
    @storage[budget.id] = budget.dup
    @storage[budget.id]
  end

  def find_by_id(id)
    @storage[id]
  end

  def find_by_user(user_id)
    @storage.values.select { |b| b.user_id == user_id }
  end

  def find_by_category(category_id, user_id)
    @storage.values.find { |b| b.category_id == category_id && b.user_id == user_id }
  end

  def update(budget)
    return nil unless @storage.key?(budget.id)
    @storage[budget.id] = budget.dup
    @storage[budget.id]
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

