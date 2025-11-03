require_relative '../models/category'

# Repository for category data access
class CategoryRepository
  def initialize(storage = {})
    @storage = storage
    @next_id = 1
  end

  def create(category)
    category.id = @next_id
    @next_id += 1
    @storage[category.id] = category.dup
    @storage[category.id]
  end

  def find_by_id(id)
    @storage[id]
  end

  def find_by_user(user_id)
    @storage.values.select { |c| c.user_id == user_id }
  end

  def find_by_name(name, user_id)
    @storage.values.find { |c| c.name == name && c.user_id == user_id }
  end

  def exists?(name, user_id)
    !find_by_name(name, user_id).nil?
  end

  def update(category)
    return nil unless @storage.key?(category.id)
    category.updated_at = Time.now
    @storage[category.id] = category.dup
    @storage[category.id]
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

