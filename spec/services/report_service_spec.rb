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

  describe '#generate_yearly_report' do
    let(:user_id) { 1 }
    let(:year) { 2025 }

    context 'with expenses across multiple months' do
      it 'generates yearly report with monthly breakdown' do
        expenses = [
          Expense.new(id: 1, amount: 100.0, date: Date.new(2025, 1, 15), description: 'Jan expense', category_id: 1, user_id: user_id),
          Expense.new(id: 2, amount: 150.0, date: Date.new(2025, 1, 20), description: 'Jan expense 2', category_id: 2, user_id: user_id),
          Expense.new(id: 3, amount: 200.0, date: Date.new(2025, 2, 10), description: 'Feb expense', category_id: 1, user_id: user_id),
          Expense.new(id: 4, amount: 75.0, date: Date.new(2025, 3, 5), description: 'Mar expense', category_id: 2, user_id: user_id),
          Expense.new(id: 5, amount: 50.0, date: Date.new(2025, 12, 20), description: 'Dec expense', category_id: 1, user_id: user_id)
        ]

        allow(expense_repo).to receive(:find_by_user).with(user_id).and_return(expenses)

        result = service.generate_yearly_report(user_id, year)

        expect(result[:success]).to be true
        expect(result[:data][:year]).to eq(2025)
        expect(result[:data][:total]).to eq(575.0)
        expect(result[:data][:expense_count]).to eq(5)
        expect(result[:data][:by_month].length).to eq(12)
        jan_month = result[:data][:by_month].find { |m| m[:month] == 1 }
        expect(jan_month[:total]).to eq(250.0)
        expect(jan_month[:count]).to eq(2)
        expect(result[:data][:by_month].find { |m| m[:month] == 2 }[:total]).to eq(200.0)
        expect(result[:data][:by_month].find { |m| m[:month] == 2 }[:count]).to eq(1)
        expect(result[:data][:by_month].find { |m| m[:month] == 3 }[:total]).to eq(75.0)
        expect(result[:data][:by_month].find { |m| m[:month] == 12 }[:total]).to eq(50.0)
      end
    end

    context 'with category breakdown' do
      it 'calculates category totals correctly' do
        expenses = [
          Expense.new(id: 1, amount: 100.0, date: Date.new(2025, 1, 10), description: 'Cat 1 expense', category_id: 1, user_id: user_id),
          Expense.new(id: 2, amount: 150.0, date: Date.new(2025, 2, 15), description: 'Cat 1 expense 2', category_id: 1, user_id: user_id),
          Expense.new(id: 3, amount: 200.0, date: Date.new(2025, 3, 20), description: 'Cat 2 expense', category_id: 2, user_id: user_id),
          Expense.new(id: 4, amount: 75.0, date: Date.new(2025, 4, 5), description: 'Cat 2 expense 2', category_id: 2, user_id: user_id),
          Expense.new(id: 5, amount: 50.0, date: Date.new(2025, 5, 10), description: 'Cat 3 expense', category_id: 3, user_id: user_id)
        ]

        allow(expense_repo).to receive(:find_by_user).with(user_id).and_return(expenses)

        result = service.generate_yearly_report(user_id, year)

        expect(result[:success]).to be true
        expect(result[:data][:total]).to eq(575.0)
        expect(result[:data][:by_category]).to eq({ 1 => 250.0, 2 => 275.0, 3 => 50.0 })
      end
    end

    context 'when there are no expenses in the year' do
      it 'returns zero totals' do
        expenses = [
          Expense.new(id: 1, amount: 100.0, date: Date.new(2024, 12, 31), description: 'Prev year', category_id: 1, user_id: user_id),
          Expense.new(id: 2, amount: 200.0, date: Date.new(2026, 1, 1), description: 'Next year', category_id: 1, user_id: user_id)
        ]

        allow(expense_repo).to receive(:find_by_user).with(user_id).and_return(expenses)

        result = service.generate_yearly_report(user_id, year)

        expect(result[:success]).to be true
        expect(result[:data][:year]).to eq(2025)
        expect(result[:data][:total]).to eq(0.0)
        expect(result[:data][:expense_count]).to eq(0)
        expect(result[:data][:by_month].all? { |m| m[:total] == 0.0 && m[:count] == 0 }).to be true
        expect(result[:data][:by_category]).to eq({})
      end
    end

    context 'with expenses for all months' do
      it 'includes all 12 months in the breakdown' do
        expenses = (1..12).map do |month|
          Expense.new(id: month, amount: 100.0 * month, date: Date.new(2025, month, 15), description: "Month #{month}", category_id: 1, user_id: user_id)
        end

        allow(expense_repo).to receive(:find_by_user).with(user_id).and_return(expenses)

        result = service.generate_yearly_report(user_id, year)

        expect(result[:success]).to be true
        expect(result[:data][:by_month].length).to eq(12)
        expect(result[:data][:by_month].map { |m| m[:month] }).to eq((1..12).to_a)
        result[:data][:by_month].each do |month_data|
          expect(month_data[:total]).to eq(100.0 * month_data[:month])
          expect(month_data[:count]).to eq(1)
        end
      end
    end
  end
end

