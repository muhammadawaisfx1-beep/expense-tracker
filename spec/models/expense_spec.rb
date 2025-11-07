require 'spec_helper'
require_relative '../../lib/models/expense'
require 'date'

RSpec.describe Expense do
  describe '#initialize' do
    it 'creates an expense with valid parameters' do
      expense = Expense.new(
        amount: 100.50,
        date: Date.today,
        description: 'Test expense',
        category_id: 1,
        user_id: 1
      )
      expect(expense.amount).to eq(100.50)
      expect(expense.description).to eq('Test expense')
    end

    it 'sets default values when parameters are missing' do
      expense = Expense.new(amount: 50, user_id: 1)
      expect(expense.date).to eq(Date.today)
      expect(expense.description).to eq('')
      expect(expense.tags).to eq([])
    end
  end

  describe '#valid?' do
    it 'returns true for valid expense' do
      expense = Expense.new(
        amount: 100,
        date: Date.today,
        description: 'Valid expense',
        user_id: 1
      )
      expect(expense.valid?).to be true
    end

    it 'returns false when amount is nil' do
      expense = Expense.new(date: Date.today, description: 'Test', user_id: 1)
      expect(expense.valid?).to be false
    end

    it 'returns false when amount is negative or zero' do
      expense = Expense.new(amount: -10, date: Date.today, description: 'Test', user_id: 1)
      expect(expense.valid?).to be false
    end

    it 'returns false when description is empty' do
      expense = Expense.new(amount: 100, date: Date.today, description: '', user_id: 1)
      expect(expense.valid?).to be false
    end
  end

  describe '#to_hash' do
    it 'converts expense to hash representation' do
      expense = Expense.new(
        id: 1,
        amount: 100,
        date: Date.new(2025, 1, 15),
        description: 'Test',
        category_id: 1,
        user_id: 1
      )
      hash = expense.to_hash
      expect(hash[:id]).to eq(1)
      expect(hash[:amount]).to eq(100)
      expect(hash[:description]).to eq('Test')
    end
  end

  describe '#normalize_tags' do
    it 'handles array of tags' do
      expense = Expense.new(
        amount: 100,
        user_id: 1,
        tags: ['food', 'restaurant', 'lunch']
      )
      expect(expense.tags).to eq(['food', 'restaurant', 'lunch'])
    end

    it 'handles comma-separated string tags' do
      expense = Expense.new(
        amount: 100,
        user_id: 1,
        tags: 'food, restaurant, lunch'
      )
      expect(expense.tags).to eq(['food', 'restaurant', 'lunch'])
    end

    it 'removes duplicate tags' do
      expense = Expense.new(
        amount: 100,
        user_id: 1,
        tags: ['food', 'food', 'restaurant']
      )
      expect(expense.tags).to eq(['food', 'restaurant'])
    end

    it 'trims whitespace from tags' do
      expense = Expense.new(
        amount: 100,
        user_id: 1,
        tags: '  food  ,  restaurant  ,  lunch  '
      )
      expect(expense.tags).to eq(['food', 'restaurant', 'lunch'])
    end

    it 'handles empty tags' do
      expense = Expense.new(
        amount: 100,
        user_id: 1,
        tags: []
      )
      expect(expense.tags).to eq([])
    end

    it 'handles nil tags' do
      expense = Expense.new(
        amount: 100,
        user_id: 1,
        tags: nil
      )
      expect(expense.tags).to eq([])
    end

    it 'handles empty string tags' do
      expense = Expense.new(
        amount: 100,
        user_id: 1,
        tags: ''
      )
      expect(expense.tags).to eq([])
    end

    it 'includes tags in hash representation' do
      expense = Expense.new(
        id: 1,
        amount: 100,
        date: Date.new(2025, 1, 15),
        description: 'Test',
        category_id: 1,
        user_id: 1,
        tags: ['food', 'lunch']
      )
      hash = expense.to_hash
      expect(hash[:tags]).to eq(['food', 'lunch'])
    end
  end

  describe '#currency' do
    it 'sets default currency to USD when not provided' do
      expense = Expense.new(
        amount: 100,
        user_id: 1
      )
      expect(expense.currency).to eq('USD')
    end

    it 'accepts valid currency codes' do
      expense = Expense.new(
        amount: 100,
        description: 'Test expense',
        user_id: 1,
        currency: 'EUR'
      )
      expect(expense.currency).to eq('EUR')
      expect(expense.valid?).to be true
    end

    it 'rejects invalid currency codes' do
      expense = Expense.new(
        amount: 100,
        description: 'Test expense',
        user_id: 1,
        currency: 'XYZ'
      )
      expect(expense.valid?).to be false
    end

    it 'includes currency in hash representation' do
      expense = Expense.new(
        id: 1,
        amount: 100,
        user_id: 1,
        currency: 'EUR'
      )
      hash = expense.to_hash
      expect(hash[:currency]).to eq('EUR')
    end

    it 'handles case-insensitive currency codes' do
      expense = Expense.new(
        amount: 100,
        user_id: 1,
        currency: 'eur'
      )
      expect(expense.currency).to eq('eur')
      # Validation should normalize to uppercase
      expect(Expense::VALID_CURRENCIES.include?(expense.currency.upcase)).to be true
    end
  end
end

