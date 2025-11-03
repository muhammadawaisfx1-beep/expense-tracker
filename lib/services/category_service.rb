require_relative '../repositories/category_repository'
require_relative '../utils/validators'

# Service layer for category business logic
class CategoryService
  def initialize(repository = CategoryRepository.new)
    @repository = repository
  end

  def create_category(params)
    category = Category.new(params)
    return { success: false, errors: ['Invalid category data'] } unless category.valid?
    return { success: false, errors: ['Category name already exists'] } if @repository.exists?(params[:name], params[:user_id])

    result = @repository.create(category)
    { success: true, data: result }
  rescue StandardError => e
    { success: false, errors: [e.message] }
  end

  def update_category(id, params)
    category = @repository.find_by_id(id)
    return { success: false, errors: ['Category not found'] } if category.nil?

    params.each do |key, value|
      category.send("#{key}=", value) if category.respond_to?("#{key}=")
    end

    return { success: false, errors: ['Invalid category data'] } unless category.valid?

    result = @repository.update(category)
    { success: true, data: result }
  rescue StandardError => e
    { success: false, errors: [e.message] }
  end

  def delete_category(id)
    category = @repository.find_by_id(id)
    return { success: false, errors: ['Category not found'] } if category.nil?

    @repository.delete(id)
    { success: true }
  rescue StandardError => e
    { success: false, errors: [e.message] }
  end

  def get_category(id)
    category = @repository.find_by_id(id)
    return { success: false, errors: ['Category not found'] } if category.nil?
    { success: true, data: category }
  end

  def list_categories(user_id)
    categories = @repository.find_by_user(user_id)
    { success: true, data: categories }
  end

  def get_category_with_expenses(category_id, user_id)
    category = @repository.find_by_id(category_id)
    return { success: false, errors: ['Category not found'] } if category.nil?
    return { success: false, errors: ['Unauthorized'] } unless category.user_id == user_id

    # This would typically join with expense repository
    { success: true, data: category }
  end
end

