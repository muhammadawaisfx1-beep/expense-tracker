require 'spec_helper'
require_relative '../../lib/services/report_service'
require_relative '../../lib/models/expense'
require 'date'

RSpec.describe ReportService do
  let(:expense_repo) { double('ExpenseRepository') }
  let(:category_repo) { double('CategoryRepository') }
  let(:service) { ReportService.new(expense_repo, category_repo) }

  describe '#generate_monthly_report' do
    let(:user_id) { 1 }
    let(:year) { 2025 }
    let(:month) { 1 }
    let(:start_date) { Date.new(year, month, 1) }
    let(:end_date) { start_date.next_month.prev_day }

    context 'without filters' do
      it 'generates a basic monthly report with all expenses' do
        expenses = [
          Expense.new(id: 1, amount: 50.0, date: Date.new(2025, 1, 15), description: 'Lunch', category_id: 1, user_id: user_id),
          Expense.new(id: 2, amount: 100.0, date: Date.new(2025, 1, 20), description: 'Dinner', category_id: 2, user_id: user_id),
          Expense.new(id: 3, amount: 25.0, date: Date.new(2025, 2, 5), description: 'Breakfast', category_id: 1, user_id: user_id)
        ]

        allow(expense_repo).to receive(:find_by_user).with(user_id).and_return(expenses)

        result = service.generate_monthly_report(user_id, year, month)

        expect(result[:success]).to be true
        expect(result[:data][:period]).to eq('2025-01')
        expect(result[:data][:total]).to eq(150.0)
        expect(result[:data][:expense_count]).to eq(2)
        expect(result[:data][:by_category]).to eq({ 1 => 50.0, 2 => 100.0 })
      end
    end

    context 'with category filter' do
      it 'generates a monthly report filtered by category_id' do
        expenses = [
          Expense.new(id: 1, amount: 50.0, date: Date.new(2025, 1, 15), description: 'Lunch', category_id: 1, user_id: user_id),
          Expense.new(id: 2, amount: 100.0, date: Date.new(2025, 1, 20), description: 'Dinner', category_id: 2, user_id: user_id),
          Expense.new(id: 3, amount: 75.0, date: Date.new(2025, 1, 25), description: 'Snack', category_id: 1, user_id: user_id)
        ]

        allow(expense_repo).to receive(:find_by_user).with(user_id).and_return(expenses)

        filters = { category_id: 1 }
        result = service.generate_monthly_report(user_id, year, month, filters)

        expect(result[:success]).to be true
        expect(result[:data][:total]).to eq(125.0)
        expect(result[:data][:expense_count]).to eq(2)
        expect(result[:data][:by_category]).to eq({ 1 => 125.0 })
      end
    end

    context 'with amount range filters' do
      it 'generates a monthly report filtered by min_amount and max_amount' do
        expenses = [
          Expense.new(id: 1, amount: 20.0, date: Date.new(2025, 1, 15), description: 'Coffee', category_id: 1, user_id: user_id),
          Expense.new(id: 2, amount: 50.0, date: Date.new(2025, 1, 20), description: 'Lunch', category_id: 1, user_id: user_id),
          Expense.new(id: 3, amount: 150.0, date: Date.new(2025, 1, 25), description: 'Dinner', category_id: 2, user_id: user_id),
          Expense.new(id: 4, amount: 80.0, date: Date.new(2025, 1, 28), description: 'Groceries', category_id: 1, user_id: user_id)
        ]

        allow(expense_repo).to receive(:find_by_user).with(user_id).and_return(expenses)

        filters = { min_amount: 30, max_amount: 100 }
        result = service.generate_monthly_report(user_id, year, month, filters)

        expect(result[:success]).to be true
        expect(result[:data][:total]).to eq(130.0)
        expect(result[:data][:expense_count]).to eq(2)
        expect(result[:data][:by_category]).to eq({ 1 => 130.0 })
      end
    end

    context 'with combined filters' do
      it 'generates a monthly report with category and amount filters combined' do
        expenses = [
          Expense.new(id: 1, amount: 30.0, date: Date.new(2025, 1, 15), description: 'Lunch', category_id: 1, user_id: user_id),
          Expense.new(id: 2, amount: 150.0, date: Date.new(2025, 1, 20), description: 'Dinner', category_id: 1, user_id: user_id),
          Expense.new(id: 3, amount: 50.0, date: Date.new(2025, 1, 25), description: 'Snack', category_id: 1, user_id: user_id),
          Expense.new(id: 4, amount: 40.0, date: Date.new(2025, 1, 28), description: 'Breakfast', category_id: 2, user_id: user_id)
        ]

        allow(expense_repo).to receive(:find_by_user).with(user_id).and_return(expenses)

        filters = { category_id: 1, min_amount: 35, max_amount: 100 }
        result = service.generate_monthly_report(user_id, year, month, filters)

        expect(result[:success]).to be true
        expect(result[:data][:total]).to eq(50.0)
        expect(result[:data][:expense_count]).to eq(1)
        expect(result[:data][:by_category]).to eq({ 1 => 50.0 })
      end
    end

    context 'with no matching expenses' do
      it 'returns zero totals when filters exclude all expenses' do
        expenses = [
          Expense.new(id: 1, amount: 10.0, date: Date.new(2025, 1, 15), description: 'Coffee', category_id: 1, user_id: user_id),
          Expense.new(id: 2, amount: 200.0, date: Date.new(2025, 1, 20), description: 'Dinner', category_id: 2, user_id: user_id)
        ]

        allow(expense_repo).to receive(:find_by_user).with(user_id).and_return(expenses)

        filters = { category_id: 1, min_amount: 50, max_amount: 100 }
        result = service.generate_monthly_report(user_id, year, month, filters)

        expect(result[:success]).to be true
        expect(result[:data][:total]).to eq(0.0)
        expect(result[:data][:expense_count]).to eq(0)
        expect(result[:data][:by_category]).to eq({})
      end
    end
  end
end

