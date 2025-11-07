require 'spec_helper'
require_relative '../../lib/repositories/expense_repository'
require_relative '../../lib/models/expense'
require 'date'

RSpec.describe ExpenseRepository do
  let(:repository) { ExpenseRepository.new }
  let(:user_id) { 1 }

  before do
    # Clear shared storage
    ExpenseRepository.class_variable_set(:@@storage, {})
    ExpenseRepository.class_variable_set(:@@next_id, 1)
  end

  describe '#find_by_user with filters' do
    before do
      # Create test expenses
      @expense1 = Expense.new(
        amount: 50.0,
        date: Date.new(2025, 1, 15),
        description: 'Lunch at restaurant',
        category_id: 1,
        user_id: user_id
      )
      @expense2 = Expense.new(
        amount: 25.5,
        date: Date.new(2025, 1, 20),
        description: 'Coffee shop',
        category_id: 2,
        user_id: user_id
      )
      @expense3 = Expense.new(
        amount: 100.0,
        date: Date.new(2025, 2, 1),
        description: 'Grocery shopping',
        category_id: 1,
        user_id: user_id
      )

      repository.create(@expense1)
      repository.create(@expense2)
      repository.create(@expense3)
    end

    it 'filters by category_id' do
      results = repository.find_by_user(user_id, category_id: 1)
      expect(results.length).to eq(2)
      expect(results.map(&:description)).to contain_exactly('Lunch at restaurant', 'Grocery shopping')
    end

    it 'searches by description keyword' do
      results = repository.find_by_user(user_id, search: 'lunch')
      expect(results.length).to eq(1)
      expect(results.first.description).to eq('Lunch at restaurant')
    end

    it 'filters by date range' do
      results = repository.find_by_user(user_id, start_date: Date.new(2025, 1, 1), end_date: Date.new(2025, 1, 31))
      expect(results.length).to eq(2)
      expect(results.map(&:description)).to contain_exactly('Lunch at restaurant', 'Coffee shop')
    end

    it 'filters by minimum amount' do
      results = repository.find_by_user(user_id, min_amount: 50.0)
      expect(results.length).to eq(2)
      expect(results.map(&:amount)).to contain_exactly(50.0, 100.0)
    end

    it 'filters by maximum amount' do
      results = repository.find_by_user(user_id, max_amount: 50.0)
      expect(results.length).to eq(2)
      expect(results.map(&:amount)).to contain_exactly(50.0, 25.5)
    end

    it 'filters by amount range' do
      results = repository.find_by_user(user_id, min_amount: 30.0, max_amount: 75.0)
      expect(results.length).to eq(1)
      expect(results.first.amount).to eq(50.0)
    end

    it 'sorts by date ascending' do
      results = repository.find_by_user(user_id, sort_by: 'date', order: 'asc')
      expect(results.map(&:date)).to eq([Date.new(2025, 1, 15), Date.new(2025, 1, 20), Date.new(2025, 2, 1)])
    end

    it 'sorts by amount descending' do
      results = repository.find_by_user(user_id, sort_by: 'amount', order: 'desc')
      expect(results.map(&:amount)).to eq([100.0, 50.0, 25.5])
    end

    it 'sorts by description ascending' do
      results = repository.find_by_user(user_id, sort_by: 'description', order: 'asc')
      expect(results.first.description).to eq('Coffee shop')
    end

    it 'combines multiple filters' do
      results = repository.find_by_user(user_id, 
        category_id: 1,
        min_amount: 50.0,
        sort_by: 'amount',
        order: 'desc'
      )
      expect(results.length).to eq(2)
      expect(results.map(&:amount)).to eq([100.0, 50.0])
    end

    it 'filters by tags' do
      expense1 = Expense.new(
        amount: 50.0,
        date: Date.new(2025, 1, 15),
        description: 'Lunch',
        category_id: 1,
        user_id: user_id,
        tags: ['food', 'restaurant']
      )
      expense2 = Expense.new(
        amount: 25.5,
        date: Date.new(2025, 1, 20),
        description: 'Coffee',
        category_id: 2,
        user_id: user_id,
        tags: ['food', 'beverage']
      )
      expense3 = Expense.new(
        amount: 100.0,
        date: Date.new(2025, 2, 1),
        description: 'Grocery',
        category_id: 1,
        user_id: user_id,
        tags: ['food', 'grocery']
      )

      repository.create(expense1)
      repository.create(expense2)
      repository.create(expense3)

      # Filter by single tag
      results = repository.find_by_user(user_id, tags: ['food'])
      expect(results.length).to eq(3)

      # Filter by multiple tags (expense must have all)
      results = repository.find_by_user(user_id, tags: ['food', 'restaurant'])
      expect(results.length).to eq(1)
      expect(results.first.description).to eq('Lunch')

      # Filter by tag that doesn't exist
      results = repository.find_by_user(user_id, tags: ['nonexistent'])
      expect(results.length).to eq(0)
    end
  end
end

