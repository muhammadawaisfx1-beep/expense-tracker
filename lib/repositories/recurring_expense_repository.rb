require_relative '../models/recurring_expense'

# Repository for recurring expense data access
class RecurringExpenseRepository
  # Shared storage across all repository instances
  @@storage = {}
  @@next_id = 1

  def initialize(storage = nil)
    @storage = storage || @@storage
    @next_id = @@next_id
  end

  def create(recurring_expense)
    recurring_expense.id = @@next_id
    @@next_id += 1
    @storage[recurring_expense.id] = recurring_expense.dup
    @storage[recurring_expense.id]
  end

  def find_by_id(id)
    @storage[id]
  end

  def find_by_user(user_id)
    @storage.values.select { |re| re.user_id == user_id }
  end

  def find_active_by_user(user_id, date = Date.today)
    @storage.values.select do |re|
      re.user_id == user_id && re.active?(date)
    end
  end

  def update(recurring_expense)
    return nil unless @storage.key?(recurring_expense.id)
    @storage[recurring_expense.id] = recurring_expense.dup
    @storage[recurring_expense.id]
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

