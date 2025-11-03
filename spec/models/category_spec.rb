require 'spec_helper'
require_relative '../../lib/models/category'

RSpec.describe Category do
  describe '#initialize' do
    it 'creates a category with valid parameters' do
      category = Category.new(name: 'Food', budget_limit: 500, user_id: 1)
      expect(category.name).to eq('Food')
      expect(category.budget_limit).to eq(500)
    end

    it 'sets default values when parameters are missing' do
      category = Category.new(user_id: 1)
      expect(category.name).to eq('')
    end
  end

  describe '#valid?' do
    it 'returns true for valid category' do
      category = Category.new(name: 'Transportation', user_id: 1)
      expect(category.valid?).to be true
    end

    it 'returns false when name is empty' do
      category = Category.new(name: '', user_id: 1)
      expect(category.valid?).to be false
    end

    it 'returns false when budget_limit is negative' do
      category = Category.new(name: 'Test', budget_limit: -100, user_id: 1)
      expect(category.valid?).to be false
    end
  end

  describe '#to_hash' do
    it 'converts category to hash representation' do
      category = Category.new(id: 1, name: 'Food', budget_limit: 500, user_id: 1)
      hash = category.to_hash
      expect(hash[:id]).to eq(1)
      expect(hash[:name]).to eq('Food')
      expect(hash[:budget_limit]).to eq(500)
    end
  end
end

