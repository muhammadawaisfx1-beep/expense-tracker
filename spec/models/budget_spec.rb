require 'spec_helper'
require_relative '../../lib/models/budget'
require 'date'

RSpec.describe Budget do
  describe '#initialize' do
    it 'creates a budget with valid parameters' do
      budget = Budget.new(
        category_id: 1,
        amount: 500,
        period_start: Date.new(2025, 1, 1),
        period_end: Date.new(2025, 1, 31),
        user_id: 1
      )
      expect(budget.category_id).to eq(1)
      expect(budget.amount).to eq(500)
      expect(budget.user_id).to eq(1)
    end

    it 'sets default created_at when not provided' do
      budget = Budget.new(category_id: 1, amount: 500, period_start: Date.today, period_end: Date.today + 30, user_id: 1)
      expect(budget.created_at).not_to be_nil
    end
  end

  describe '#valid?' do
    it 'returns true for valid budget' do
      budget = Budget.new(
        category_id: 1,
        amount: 500,
        period_start: Date.new(2025, 1, 1),
        period_end: Date.new(2025, 1, 31),
        user_id: 1
      )
      expect(budget.valid?).to be true
    end

    it 'returns false when category_id is nil' do
      budget = Budget.new(amount: 500, period_start: Date.today, period_end: Date.today + 30, user_id: 1)
      expect(budget.valid?).to be false
    end

    it 'returns false when amount is zero or negative' do
      budget = Budget.new(category_id: 1, amount: 0, period_start: Date.today, period_end: Date.today + 30, user_id: 1)
      expect(budget.valid?).to be false
    end

    it 'returns false when period_start is after period_end' do
      budget = Budget.new(
        category_id: 1,
        amount: 500,
        period_start: Date.new(2025, 1, 31),
        period_end: Date.new(2025, 1, 1),
        user_id: 1
      )
      expect(budget.valid?).to be false
    end
  end

  describe '#active?' do
    it 'returns true when date is within budget period' do
      budget = Budget.new(
        category_id: 1,
        amount: 500,
        period_start: Date.new(2025, 1, 1),
        period_end: Date.new(2025, 1, 31),
        user_id: 1
      )
      expect(budget.active?(Date.new(2025, 1, 15))).to be true
    end

    it 'returns false when date is before period_start' do
      budget = Budget.new(
        category_id: 1,
        amount: 500,
        period_start: Date.new(2025, 1, 1),
        period_end: Date.new(2025, 1, 31),
        user_id: 1
      )
      expect(budget.active?(Date.new(2024, 12, 31))).to be false
    end

    it 'returns false when date is after period_end' do
      budget = Budget.new(
        category_id: 1,
        amount: 500,
        period_start: Date.new(2025, 1, 1),
        period_end: Date.new(2025, 1, 31),
        user_id: 1
      )
      expect(budget.active?(Date.new(2025, 2, 1))).to be false
    end
  end

  describe '#to_hash' do
    it 'converts budget to hash representation' do
      budget = Budget.new(
        id: 1,
        category_id: 1,
        amount: 500,
        period_start: Date.new(2025, 1, 1),
        period_end: Date.new(2025, 1, 31),
        user_id: 1
      )
      hash = budget.to_hash
      expect(hash[:id]).to eq(1)
      expect(hash[:category_id]).to eq(1)
      expect(hash[:amount]).to eq(500)
    end
  end
end

