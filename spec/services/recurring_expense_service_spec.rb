require 'spec_helper'
require_relative '../../lib/services/recurring_expense_service'
require_relative '../../lib/models/recurring_expense'
require_relative '../../lib/models/expense'
require 'date'

RSpec.describe RecurringExpenseService do
  let(:recurring_repository) { double('RecurringExpenseRepository') }
  let(:expense_repository) { double('ExpenseRepository') }
  let(:service) { RecurringExpenseService.new(recurring_repository, expense_repository) }

  describe '#create_recurring_expense' do
    it 'creates a valid recurring expense successfully' do
      params = {
        amount: 99.99,
        description: 'Netflix Subscription',
        category_id: 1,
        user_id: 1,
        frequency: 'monthly',
        start_date: Date.new(2025, 1, 1),
        end_date: Date.new(2025, 12, 31)
      }
      recurring = RecurringExpense.new(params)
      allow(RecurringExpense).to receive(:new).and_return(recurring)
      allow(recurring_repository).to receive(:create).and_return(recurring)

      result = service.create_recurring_expense(params)

      expect(result[:success]).to be true
      expect(result[:data]).to eq(recurring)
    end

    it 'returns error for invalid recurring expense' do
      params = {
        amount: -50,
        description: 'Test',
        user_id: 1,
        frequency: 'monthly',
        start_date: Date.today
      }
      recurring = RecurringExpense.new(params)
      allow(RecurringExpense).to receive(:new).and_return(recurring)

      result = service.create_recurring_expense(params)

      expect(result[:success]).to be false
      expect(result[:errors]).not_to be_empty
    end

    it 'parses string dates correctly' do
      params = {
        amount: 99.99,
        description: 'Netflix',
        user_id: 1,
        frequency: 'monthly',
        start_date: '2025-01-01',
        end_date: '2025-12-31'
      }
      recurring = RecurringExpense.new(
        amount: 99.99,
        description: 'Netflix',
        user_id: 1,
        frequency: 'monthly',
        start_date: Date.new(2025, 1, 1),
        end_date: Date.new(2025, 12, 31)
      )
      allow(RecurringExpense).to receive(:new).and_return(recurring)
      allow(recurring_repository).to receive(:create).and_return(recurring)

      result = service.create_recurring_expense(params)

      expect(result[:success]).to be true
    end
  end

  describe '#get_recurring_expense' do
    it 'returns recurring expense when found' do
      recurring = RecurringExpense.new(
        id: 1,
        amount: 99.99,
        description: 'Netflix',
        user_id: 1,
        frequency: 'monthly',
        start_date: Date.today
      )
      allow(recurring_repository).to receive(:find_by_id).with(1).and_return(recurring)

      result = service.get_recurring_expense(1)

      expect(result[:success]).to be true
      expect(result[:data]).to eq(recurring)
    end

    it 'returns error when recurring expense not found' do
      allow(recurring_repository).to receive(:find_by_id).with(999).and_return(nil)

      result = service.get_recurring_expense(999)

      expect(result[:success]).to be false
      expect(result[:errors]).to include('Recurring expense not found')
    end
  end

  describe '#generate_expenses' do
    it 'generates expenses from active recurring expenses' do
      recurring = RecurringExpense.new(
        id: 1,
        amount: 99.99,
        description: 'Netflix Subscription',
        category_id: 1,
        user_id: 1,
        frequency: 'monthly',
        start_date: Date.new(2025, 1, 1),
        end_date: Date.new(2025, 12, 31),
        next_occurrence_date: Date.new(2025, 1, 1)
      )
      
      expense1 = Expense.new(
        id: 1,
        amount: 99.99,
        date: Date.new(2025, 1, 1),
        description: 'Netflix Subscription',
        category_id: 1,
        user_id: 1
      )
      
      expense2 = Expense.new(
        id: 2,
        amount: 99.99,
        date: Date.new(2025, 2, 1),
        description: 'Netflix Subscription',
        category_id: 1,
        user_id: 1
      )

      allow(recurring_repository).to receive(:find_active_by_user).with(1, Date.new(2025, 2, 1)).and_return([recurring])
      allow(expense_repository).to receive(:find_by_user).with(1).and_return([])
      allow(expense_repository).to receive(:create).and_return(expense1, expense2)
      allow(recurring_repository).to receive(:update).and_return(recurring)

      result = service.generate_expenses(1, Date.new(2025, 2, 1))

      expect(result[:success]).to be true
      expect(result[:data][:generated_count]).to eq(2)
    end

    it 'prevents duplicate expense generation' do
      recurring = RecurringExpense.new(
        id: 1,
        amount: 99.99,
        description: 'Netflix Subscription',
        category_id: 1,
        user_id: 1,
        frequency: 'monthly',
        start_date: Date.new(2025, 1, 1),
        next_occurrence_date: Date.new(2025, 1, 1)
      )

      existing_expense = Expense.new(
        id: 1,
        amount: 99.99,
        date: Date.new(2025, 1, 1),
        description: 'Netflix Subscription',
        category_id: 1,
        user_id: 1
      )
      
      new_expense = Expense.new(
        id: 2,
        amount: 99.99,
        date: Date.new(2025, 2, 1),
        description: 'Netflix Subscription',
        category_id: 1,
        user_id: 1
      )

      allow(recurring_repository).to receive(:find_active_by_user).with(1, Date.new(2025, 2, 1)).and_return([recurring])
      allow(expense_repository).to receive(:find_by_user).with(1).and_return([existing_expense])
      allow(expense_repository).to receive(:create).and_return(new_expense)
      allow(recurring_repository).to receive(:update).and_return(recurring)

      result = service.generate_expenses(1, Date.new(2025, 2, 1))

      expect(result[:success]).to be true
      expect(result[:data][:generated_count]).to eq(1) # Only Feb expense should be generated
    end
  end

  describe '#list_recurring_expenses' do
    it 'returns all recurring expenses for a user' do
      recurring1 = RecurringExpense.new(id: 1, amount: 50, description: 'Test1', user_id: 1, frequency: 'monthly', start_date: Date.today)
      recurring2 = RecurringExpense.new(id: 2, amount: 100, description: 'Test2', user_id: 1, frequency: 'weekly', start_date: Date.today)
      
      allow(recurring_repository).to receive(:find_by_user).with(1).and_return([recurring1, recurring2])

      result = service.list_recurring_expenses(1)

      expect(result[:success]).to be true
      expect(result[:data].length).to eq(2)
    end
  end
end

