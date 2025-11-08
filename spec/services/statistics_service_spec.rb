require 'spec_helper'
require_relative '../../lib/services/statistics_service'
require_relative '../../lib/models/expense'
require_relative '../../lib/models/category'
require 'date'

RSpec.describe StatisticsService do
  let(:expense_repo) { double('ExpenseRepository') }
  let(:category_repo) { double('CategoryRepository') }
  let(:service) { StatisticsService.new(expense_repo, category_repo) }

  describe '#get_statistics' do
    let(:user_id) { 1 }
    let(:category1) { Category.new(id: 1, name: 'Food & Dining', user_id: user_id) }
    let(:category2) { Category.new(id: 2, name: 'Transportation', user_id: user_id) }

    context 'with expenses' do
      let(:expenses) do
        [
          Expense.new(
            id: 1,
            amount: 50.00,
            date: Date.new(2025, 1, 15),
            description: 'Lunch',
            category_id: 1,
            user_id: user_id,
            currency: 'USD'
          ),
          Expense.new(
            id: 2,
            amount: 100.00,
            date: Date.new(2025, 1, 20),
            description: 'Dinner',
            category_id: 1,
            user_id: user_id,
            currency: 'USD'
          ),
          Expense.new(
            id: 3,
            amount: 25.00,
            date: Date.new(2025, 1, 25),
            description: 'Bus ticket',
            category_id: 2,
            user_id: user_id,
            currency: 'EUR'
          )
        ]
      end

      before do
        allow(expense_repo).to receive(:find_by_user).with(user_id).and_return(expenses)
        allow(category_repo).to receive(:find_by_id).with(1).and_return(category1)
        allow(category_repo).to receive(:find_by_id).with(2).and_return(category2)
      end

      it 'calculates summary statistics correctly' do
        result = service.get_statistics(user_id)

        expect(result[:summary][:total_spending]).to eq(175.00)
        expect(result[:summary][:average_expense]).to eq(58.33)
        expect(result[:summary][:largest_expense]).to eq(100.00)
        expect(result[:summary][:smallest_expense]).to eq(25.00)
        expect(result[:summary][:expense_count]).to eq(3)
      end

      it 'calculates trend statistics correctly' do
        result = service.get_statistics(user_id)

        expect(result[:trends][:daily_average]).to be > 0
        expect(result[:trends][:weekly_average]).to be > 0
        expect(result[:trends][:monthly_average]).to be > 0
      end

      it 'calculates category breakdown correctly' do
        result = service.get_statistics(user_id)

        expect(result[:category_breakdown].length).to eq(2)
        
        food_category = result[:category_breakdown].find { |c| c[:category_id] == 1 }
        expect(food_category[:category_name]).to eq('Food & Dining')
        expect(food_category[:amount]).to eq(150.00)
        expect(food_category[:percentage]).to eq(85.71)
        
        transport_category = result[:category_breakdown].find { |c| c[:category_id] == 2 }
        expect(transport_category[:category_name]).to eq('Transportation')
        expect(transport_category[:amount]).to eq(25.00)
        expect(transport_category[:percentage]).to eq(14.29)
      end

      it 'calculates currency breakdown correctly' do
        result = service.get_statistics(user_id)

        expect(result[:currency_breakdown].length).to eq(2)
        
        usd_currency = result[:currency_breakdown].find { |c| c[:currency] == 'USD' }
        expect(usd_currency[:amount]).to eq(150.00)
        expect(usd_currency[:percentage]).to eq(85.71)
        
        eur_currency = result[:currency_breakdown].find { |c| c[:currency] == 'EUR' }
        expect(eur_currency[:amount]).to eq(25.00)
        expect(eur_currency[:percentage]).to eq(14.29)
      end

      it 'includes date range in result' do
        result = service.get_statistics(user_id)

        expect(result[:date_range][:start]).to eq('2025-01-15')
        expect(result[:date_range][:end]).to eq('2025-01-25')
      end

      it 'filters by date range when provided' do
        date_range = {
          start: Date.new(2025, 1, 15),
          end: Date.new(2025, 1, 20)
        }
        
        filtered_expenses = expenses.select { |e| e.date >= date_range[:start] && e.date <= date_range[:end] }
        allow(expense_repo).to receive(:find_by_user).with(user_id).and_return(expenses)
        allow(category_repo).to receive(:find_by_id).with(1).and_return(category1)

        result = service.get_statistics(user_id, date_range)

        expect(result[:summary][:expense_count]).to eq(2)
        expect(result[:summary][:total_spending]).to eq(150.00)
        expect(result[:date_range][:start]).to eq('2025-01-15')
        expect(result[:date_range][:end]).to eq('2025-01-20')
      end
    end

    context 'with no expenses' do
      before do
        allow(expense_repo).to receive(:find_by_user).with(user_id).and_return([])
      end

      it 'returns zero statistics' do
        result = service.get_statistics(user_id)

        expect(result[:summary][:total_spending]).to eq(0.0)
        expect(result[:summary][:average_expense]).to eq(0.0)
        expect(result[:summary][:largest_expense]).to eq(0.0)
        expect(result[:summary][:smallest_expense]).to eq(0.0)
        expect(result[:summary][:expense_count]).to eq(0)
        expect(result[:trends][:daily_average]).to eq(0.0)
        expect(result[:trends][:weekly_average]).to eq(0.0)
        expect(result[:trends][:monthly_average]).to eq(0.0)
        expect(result[:category_breakdown]).to eq([])
        expect(result[:currency_breakdown]).to eq([])
      end
    end

    context 'with single expense' do
      let(:single_expense) do
        [
          Expense.new(
            id: 1,
            amount: 50.00,
            date: Date.new(2025, 1, 15),
            description: 'Lunch',
            category_id: 1,
            user_id: user_id,
            currency: 'USD'
          )
        ]
      end

      before do
        allow(expense_repo).to receive(:find_by_user).with(user_id).and_return(single_expense)
        allow(category_repo).to receive(:find_by_id).with(1).and_return(category1)
      end

      it 'calculates statistics correctly for single expense' do
        result = service.get_statistics(user_id)

        expect(result[:summary][:total_spending]).to eq(50.00)
        expect(result[:summary][:average_expense]).to eq(50.00)
        expect(result[:summary][:largest_expense]).to eq(50.00)
        expect(result[:summary][:smallest_expense]).to eq(50.00)
        expect(result[:summary][:expense_count]).to eq(1)
      end
    end
  end
end

