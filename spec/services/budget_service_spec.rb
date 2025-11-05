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

  describe '#generate_alert' do
    it 'generates exceeded alert when spending exceeds budget' do
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

      alert = service.generate_alert(budget, 1)

      expect(alert).not_to be_nil
      expect(alert[:alert_type]).to eq('exceeded')
      expect(alert[:spending]).to eq(550)
      expect(alert[:remaining]).to eq(-50)
      expect(alert[:percentage_used]).to eq(110.0)
      expect(alert[:message]).to include('Budget exceeded')
    end

    it 'generates near_limit alert when spending approaches threshold' do
      budget = Budget.new(
        id: 1,
        category_id: 1,
        amount: 500,
        period_start: Date.new(2025, 1, 1),
        period_end: Date.new(2025, 1, 31),
        user_id: 1
      )
      require_relative '../../lib/models/expense'
      expense1 = Expense.new(amount: 200, category_id: 1, date: Date.new(2025, 1, 15), description: 'Test', user_id: 1)
      expense2 = Expense.new(amount: 250, category_id: 1, date: Date.new(2025, 1, 20), description: 'Test', user_id: 1)
      expenses = [expense1, expense2]
      
      allow(expense_repository).to receive(:find_by_user).with(1).and_return(expenses)

      alert = service.generate_alert(budget, 1, 80)

      expect(alert).not_to be_nil
      expect(alert[:alert_type]).to eq('near_limit')
      expect(alert[:spending]).to eq(450)
      expect(alert[:remaining]).to eq(50)
      expect(alert[:percentage_used]).to eq(90.0)
      expect(alert[:message]).to include('Budget is 90.0% used')
    end

    it 'returns nil when budget is within limits and below threshold' do
      budget = Budget.new(
        id: 1,
        category_id: 1,
        amount: 500,
        period_start: Date.new(2025, 1, 1),
        period_end: Date.new(2025, 1, 31),
        user_id: 1
      )
      require_relative '../../lib/models/expense'
      expense1 = Expense.new(amount: 100, category_id: 1, date: Date.new(2025, 1, 15), description: 'Test', user_id: 1)
      expense2 = Expense.new(amount: 150, category_id: 1, date: Date.new(2025, 1, 20), description: 'Test', user_id: 1)
      expenses = [expense1, expense2]
      
      allow(expense_repository).to receive(:find_by_user).with(1).and_return(expenses)

      alert = service.generate_alert(budget, 1, 80)

      expect(alert).to be_nil
    end

    it 'respects custom threshold percentage' do
      budget = Budget.new(
        id: 1,
        category_id: 1,
        amount: 500,
        period_start: Date.new(2025, 1, 1),
        period_end: Date.new(2025, 1, 31),
        user_id: 1
      )
      require_relative '../../lib/models/expense'
      expense1 = Expense.new(amount: 200, category_id: 1, date: Date.new(2025, 1, 15), description: 'Test', user_id: 1)
      expenses = [expense1]
      
      allow(expense_repository).to receive(:find_by_user).with(1).and_return(expenses)

      # With 90% threshold, 200/500 = 40% should not trigger alert
      alert_low = service.generate_alert(budget, 1, 90)
      expect(alert_low).to be_nil

      # With 30% threshold, 200/500 = 40% should trigger alert
      alert_high = service.generate_alert(budget, 1, 30)
      expect(alert_high).not_to be_nil
      expect(alert_high[:alert_type]).to eq('near_limit')
    end
  end

  describe '#get_budget_alerts' do
    it 'returns all alerts for a user' do
      budget1 = Budget.new(id: 1, category_id: 1, amount: 500, period_start: Date.new(2025, 1, 1), period_end: Date.new(2025, 1, 31), user_id: 1)
      budget2 = Budget.new(id: 2, category_id: 2, amount: 300, period_start: Date.new(2025, 1, 1), period_end: Date.new(2025, 1, 31), user_id: 1)
      
      require_relative '../../lib/models/expense'
      expense1 = Expense.new(amount: 300, category_id: 1, date: Date.new(2025, 1, 15), description: 'Test', user_id: 1)
      expense2 = Expense.new(amount: 250, category_id: 1, date: Date.new(2025, 1, 20), description: 'Test', user_id: 1)
      expense3 = Expense.new(amount: 250, category_id: 2, date: Date.new(2025, 1, 18), description: 'Test', user_id: 1)
      expenses = [expense1, expense2, expense3]
      
      allow(budget_repository).to receive(:find_by_user).with(1).and_return([budget1, budget2])
      allow(expense_repository).to receive(:find_by_user).with(1).and_return(expenses)

      result = service.get_budget_alerts(1, 'all', 80)

      expect(result[:success]).to be true
      expect(result[:data][:alerts].length).to eq(2)
      expect(result[:data][:total_alerts]).to eq(2)
      expect(result[:data][:exceeded_count]).to eq(1)
      expect(result[:data][:near_limit_count]).to eq(1)
    end

    it 'filters alerts by type' do
      budget1 = Budget.new(id: 1, category_id: 1, amount: 500, period_start: Date.new(2025, 1, 1), period_end: Date.new(2025, 1, 31), user_id: 1)
      budget2 = Budget.new(id: 2, category_id: 2, amount: 300, period_start: Date.new(2025, 1, 1), period_end: Date.new(2025, 1, 31), user_id: 1)
      
      require_relative '../../lib/models/expense'
      expense1 = Expense.new(amount: 300, category_id: 1, date: Date.new(2025, 1, 15), description: 'Test', user_id: 1)
      expense2 = Expense.new(amount: 250, category_id: 1, date: Date.new(2025, 1, 20), description: 'Test', user_id: 1)
      expense3 = Expense.new(amount: 250, category_id: 2, date: Date.new(2025, 1, 18), description: 'Test', user_id: 1)
      expenses = [expense1, expense2, expense3]
      
      allow(budget_repository).to receive(:find_by_user).with(1).and_return([budget1, budget2])
      allow(expense_repository).to receive(:find_by_user).with(1).and_return(expenses)

      result = service.get_budget_alerts(1, 'exceeded', 80)

      expect(result[:success]).to be true
      expect(result[:data][:alerts].length).to eq(1)
      expect(result[:data][:alerts].first[:alert_type]).to eq('exceeded')
      expect(result[:data][:exceeded_count]).to eq(1)
      expect(result[:data][:near_limit_count]).to eq(0)
    end

    it 'returns empty alerts when no budgets need alerts' do
      budget = Budget.new(id: 1, category_id: 1, amount: 500, period_start: Date.new(2025, 1, 1), period_end: Date.new(2025, 1, 31), user_id: 1)
      
      require_relative '../../lib/models/expense'
      expense1 = Expense.new(amount: 100, category_id: 1, date: Date.new(2025, 1, 15), description: 'Test', user_id: 1)
      expenses = [expense1]
      
      allow(budget_repository).to receive(:find_by_user).with(1).and_return([budget])
      allow(expense_repository).to receive(:find_by_user).with(1).and_return(expenses)

      result = service.get_budget_alerts(1, 'all', 80)

      expect(result[:success]).to be true
      expect(result[:data][:alerts]).to be_empty
      expect(result[:data][:total_alerts]).to eq(0)
    end
  end
end

