require 'spec_helper'
require_relative '../../lib/services/expense_service'
require_relative '../../lib/models/expense'
require 'date'

RSpec.describe ExpenseService do
  let(:repository) { double('ExpenseRepository') }
  let(:service) { ExpenseService.new(repository) }

  describe '#create_expense' do
    it 'creates a valid expense successfully' do
      expense_params = {
        amount: 100,
        date: Date.today,
        description: 'Test expense',
        user_id: 1,
        category_id: 1
      }
      expense = Expense.new(expense_params)
      allow(Expense).to receive(:new).and_return(expense)
      allow(repository).to receive(:create).and_return(expense)

      result = service.create_expense(expense_params)

      expect(result[:success]).to be true
      expect(result[:data]).to eq(expense)
    end

    it 'returns error for invalid expense' do
      expense_params = { amount: -100, user_id: 1 }
      expense = Expense.new(expense_params)
      allow(Expense).to receive(:new).and_return(expense)

      result = service.create_expense(expense_params)

      expect(result[:success]).to be false
      expect(result[:errors]).not_to be_empty
    end
  end

  describe '#get_expense' do
    it 'returns expense when found' do
      expense = Expense.new(id: 1, amount: 100, date: Date.today, description: 'Test', user_id: 1)
      allow(repository).to receive(:find_by_id).with(1).and_return(expense)

      result = service.get_expense(1)

      expect(result[:success]).to be true
      expect(result[:data]).to eq(expense)
    end

    it 'returns error when expense not found' do
      allow(repository).to receive(:find_by_id).with(999).and_return(nil)

      result = service.get_expense(999)

      expect(result[:success]).to be false
      expect(result[:errors]).to include('Expense not found')
    end
  end
end

