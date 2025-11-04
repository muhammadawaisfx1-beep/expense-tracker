require 'spec_helper'
require_relative '../../lib/services/budget_service'
require_relative '../../lib/models/budget'
require 'date'

RSpec.describe BudgetService do
  let(:expense_repository) { double('ExpenseRepository') }
  let(:budget_repository) { double('BudgetRepository') }
  let(:service) { BudgetService.new(expense_repository, budget_repository) }

  describe '#create_budget' do
    it 'creates a valid budget successfully' do
      budget_params = {
        category_id: 1,
        amount: 500,
        period_start: Date.new(2025, 1, 1),
        period_end: Date.new(2025, 1, 31),
        user_id: 1
      }
      budget = Budget.new(budget_params)
      allow(Budget).to receive(:new).and_return(budget)
      allow(budget_repository).to receive(:create).and_return(budget)

      result = service.create_budget(budget_params)

      expect(result[:success]).to be true
      expect(result[:data]).to eq(budget)
    end

    it 'returns error for invalid budget' do
      budget_params = { category_id: 1, amount: -100, user_id: 1 }
      budget = Budget.new(budget_params)
      allow(Budget).to receive(:new).and_return(budget)

      result = service.create_budget(budget_params)

      expect(result[:success]).to be false
      expect(result[:errors]).not_to be_empty
    end
  end

  describe '#get_budget' do
    it 'returns budget when found' do
      budget = Budget.new(id: 1, category_id: 1, amount: 500, period_start: Date.today, period_end: Date.today + 30, user_id: 1)
      allow(budget_repository).to receive(:find_by_id).with(1).and_return(budget)

      result = service.get_budget(1)

      expect(result[:success]).to be true
      expect(result[:data]).to eq(budget)
    end

    it 'returns error when budget not found' do
      allow(budget_repository).to receive(:find_by_id).with(999).and_return(nil)

      result = service.get_budget(999)

      expect(result[:success]).to be false
      expect(result[:errors]).to include('Budget not found')
    end
  end

  describe '#check_budget_status' do
    it 'calculates budget status correctly' do
      budget = Budget.new(
        id: 1,
        category_id: 1,
        amount: 500,
        period_start: Date.new(2025, 1, 1),
        period_end: Date.new(2025, 1, 31),
        user_id: 1
      )
      # Create actual Expense objects for proper date comparison
      require_relative '../../lib/models/expense'
      expense1 = Expense.new(amount: 100, category_id: 1, date: Date.new(2025, 1, 15), description: 'Test', user_id: 1)
      expense2 = Expense.new(amount: 200, category_id: 1, date: Date.new(2025, 1, 20), description: 'Test', user_id: 1)
      expenses = [expense1, expense2]
      
      allow(expense_repository).to receive(:find_by_user).with(1).and_return(expenses)

      result = service.check_budget_status(budget, 1)

      expect(result[:success]).to be true
      expect(result[:data][:spending]).to eq(300)
      expect(result[:data][:remaining]).to eq(200)
      expect(result[:data][:percentage_used]).to eq(60.0)
      expect(result[:data][:exceeded]).to be false
    end

    it 'detects when budget is exceeded' do
      budget = Budget.new(
        id: 1,
        category_id: 1,
        amount: 500,
        period_start: Date.new(2025, 1, 1),
        period_end: Date.new(2025, 1, 31),
        user_id: 1
      )
      require_relative '../../lib/models/expense'
      expense1 = Expense.new(amount: 300, category_id: 1, date: Date.new(2025, 1, 15), description: 'Test', user_id: 1)
      expense2 = Expense.new(amount: 250, category_id: 1, date: Date.new(2025, 1, 20), description: 'Test', user_id: 1)
      expenses = [expense1, expense2]
      
      allow(expense_repository).to receive(:find_by_user).with(1).and_return(expenses)

      result = service.check_budget_status(budget, 1)

      expect(result[:success]).to be true
      expect(result[:data][:exceeded]).to be true
      expect(result[:data][:remaining]).to be < 0
    end
  end
end

