require 'spec_helper'
require_relative '../../lib/models/recurring_expense'
require 'date'

RSpec.describe RecurringExpense do
  describe '#initialize' do
    it 'creates a recurring expense with valid parameters' do
      recurring = RecurringExpense.new(
        amount: 99.99,
        description: 'Netflix Subscription',
        category_id: 1,
        user_id: 1,
        frequency: 'monthly',
        start_date: Date.new(2025, 1, 1),
        end_date: Date.new(2025, 12, 31)
      )
      expect(recurring.amount).to eq(99.99)
      expect(recurring.description).to eq('Netflix Subscription')
      expect(recurring.frequency).to eq('monthly')
    end

    it 'sets default next_occurrence_date to start_date when not provided' do
      start_date = Date.new(2025, 1, 1)
      recurring = RecurringExpense.new(
        amount: 50,
        description: 'Test',
        user_id: 1,
        frequency: 'monthly',
        start_date: start_date
      )
      expect(recurring.next_occurrence_date).to eq(start_date)
    end

    it 'sets default created_at when not provided' do
      recurring = RecurringExpense.new(
        amount: 50,
        description: 'Test',
        user_id: 1,
        frequency: 'monthly',
        start_date: Date.today
      )
      expect(recurring.created_at).not_to be_nil
    end
  end

  describe '#valid?' do
    it 'returns true for valid recurring expense' do
      recurring = RecurringExpense.new(
        amount: 99.99,
        description: 'Netflix Subscription',
        user_id: 1,
        frequency: 'monthly',
        start_date: Date.new(2025, 1, 1)
      )
      expect(recurring.valid?).to be true
    end

    it 'returns false when amount is nil or zero' do
      recurring = RecurringExpense.new(
        description: 'Test',
        user_id: 1,
        frequency: 'monthly',
        start_date: Date.today
      )
      expect(recurring.valid?).to be false
    end

    it 'returns false when description is empty' do
      recurring = RecurringExpense.new(
        amount: 50,
        description: '',
        user_id: 1,
        frequency: 'monthly',
        start_date: Date.today
      )
      expect(recurring.valid?).to be false
    end

    it 'returns false when frequency is invalid' do
      recurring = RecurringExpense.new(
        amount: 50,
        description: 'Test',
        user_id: 1,
        frequency: 'invalid',
        start_date: Date.today
      )
      expect(recurring.valid?).to be false
    end

    it 'returns false when end_date is before start_date' do
      recurring = RecurringExpense.new(
        amount: 50,
        description: 'Test',
        user_id: 1,
        frequency: 'monthly',
        start_date: Date.new(2025, 12, 31),
        end_date: Date.new(2025, 1, 1)
      )
      expect(recurring.valid?).to be false
    end
  end

  describe '#active?' do
    it 'returns true when date is within active period' do
      recurring = RecurringExpense.new(
        amount: 50,
        description: 'Test',
        user_id: 1,
        frequency: 'monthly',
        start_date: Date.new(2025, 1, 1),
        end_date: Date.new(2025, 12, 31)
      )
      expect(recurring.active?(Date.new(2025, 6, 15))).to be true
    end

    it 'returns false when date is before start_date' do
      recurring = RecurringExpense.new(
        amount: 50,
        description: 'Test',
        user_id: 1,
        frequency: 'monthly',
        start_date: Date.new(2025, 1, 1)
      )
      expect(recurring.active?(Date.new(2024, 12, 31))).to be false
    end

    it 'returns false when date is after end_date' do
      recurring = RecurringExpense.new(
        amount: 50,
        description: 'Test',
        user_id: 1,
        frequency: 'monthly',
        start_date: Date.new(2025, 1, 1),
        end_date: Date.new(2025, 12, 31)
      )
      expect(recurring.active?(Date.new(2026, 1, 1))).to be false
    end
  end

  describe '#calculate_next_occurrence' do
    it 'calculates next daily occurrence' do
      recurring = RecurringExpense.new(
        amount: 50,
        description: 'Test',
        user_id: 1,
        frequency: 'daily',
        start_date: Date.new(2025, 1, 1)
      )
      next_date = recurring.calculate_next_occurrence(Date.new(2025, 1, 1))
      expect(next_date).to eq(Date.new(2025, 1, 2))
    end

    it 'calculates next monthly occurrence' do
      recurring = RecurringExpense.new(
        amount: 50,
        description: 'Test',
        user_id: 1,
        frequency: 'monthly',
        start_date: Date.new(2025, 1, 15)
      )
      next_date = recurring.calculate_next_occurrence(Date.new(2025, 1, 15))
      expect(next_date).to eq(Date.new(2025, 2, 15))
    end

    it 'handles month boundary edge cases for monthly frequency' do
      recurring = RecurringExpense.new(
        amount: 50,
        description: 'Test',
        user_id: 1,
        frequency: 'monthly',
        start_date: Date.new(2025, 1, 31)
      )
      next_date = recurring.calculate_next_occurrence(Date.new(2025, 1, 31))
      expect(next_date).to eq(Date.new(2025, 2, 28))
    end
  end

  describe '#to_hash' do
    it 'converts recurring expense to hash representation' do
      recurring = RecurringExpense.new(
        id: 1,
        amount: 99.99,
        description: 'Netflix',
        category_id: 1,
        user_id: 1,
        frequency: 'monthly',
        start_date: Date.new(2025, 1, 1),
        end_date: Date.new(2025, 12, 31)
      )
      hash = recurring.to_hash
      expect(hash[:id]).to eq(1)
      expect(hash[:amount]).to eq(99.99)
      expect(hash[:frequency]).to eq('monthly')
    end
  end
end

