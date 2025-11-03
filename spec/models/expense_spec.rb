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
end

