require 'spec_helper'
require_relative '../../lib/services/export_service'
require_relative '../../lib/models/expense'
require 'date'

RSpec.describe ExportService do
  let(:expense_repo) { double('ExpenseRepository') }
  let(:service) { ExportService.new(expense_repo) }

  describe '#export_to_csv' do
    let(:user_id) { 1 }
    let(:expenses) do
      [
        Expense.new(
          id: 1,
          amount: 50.00,
          date: Date.new(2025, 1, 15),
          description: 'Lunch at restaurant',
          category_id: 1,
          user_id: user_id,
          tags: ['food', 'dining'],
          currency: 'USD',
          created_at: Time.new(2025, 1, 15, 10, 30, 0)
        ),
        Expense.new(
          id: 2,
          amount: 100.50,
          date: Date.new(2025, 1, 20),
          description: 'Dinner',
          category_id: 2,
          user_id: user_id,
          tags: [],
          currency: 'EUR',
          created_at: Time.new(2025, 1, 20, 18, 0, 0)
        )
      ]
    end

    context 'with expenses' do
      it 'generates CSV with header row' do
        allow(expense_repo).to receive(:find_by_user).with(user_id, {}).and_return(expenses)
        
        csv = service.export_to_csv(user_id)
        lines = csv.split("\n")
        
        expect(lines[0]).to eq('id,amount,date,description,category_id,user_id,tags,currency,created_at')
      end

      it 'generates CSV with expense data' do
        allow(expense_repo).to receive(:find_by_user).with(user_id, {}).and_return(expenses)
        
        csv = service.export_to_csv(user_id)
        lines = csv.split("\n")
        
        expect(lines.length).to eq(3) # header + 2 expenses
        expect(lines[1]).to include('1,50.00,2025-01-15')
        expect(lines[1]).to include('Lunch at restaurant')
        expect(lines[1]).to include('"food,dining"')
        expect(lines[2]).to include('2,100.50,2025-01-20')
      end

      it 'formats amounts with 2 decimal places' do
        allow(expense_repo).to receive(:find_by_user).with(user_id, {}).and_return(expenses)
        
        csv = service.export_to_csv(user_id)
        lines = csv.split("\n")
        
        expect(lines[1]).to include('50.00')
        expect(lines[2]).to include('100.50')
      end

      it 'handles tags properly in CSV' do
        allow(expense_repo).to receive(:find_by_user).with(user_id, {}).and_return(expenses)
        
        csv = service.export_to_csv(user_id)
        lines = csv.split("\n")
        
        # First expense has tags
        expect(lines[1]).to include('"food,dining"')
        # Second expense has no tags
        expect(lines[2]).to include('""')
      end

      it 'escapes special characters in CSV' do
        expense_with_comma = Expense.new(
          id: 3,
          amount: 25.00,
          date: Date.new(2025, 1, 25),
          description: 'Lunch, dinner, and snacks',
          category_id: 1,
          user_id: user_id,
          tags: [],
          currency: 'USD',
          created_at: Time.new(2025, 1, 25, 12, 0, 0)
        )
        
        allow(expense_repo).to receive(:find_by_user).with(user_id, {}).and_return([expense_with_comma])
        
        csv = service.export_to_csv(user_id)
        lines = csv.split("\n")
        
        expect(lines[1]).to include('"Lunch, dinner, and snacks"')
      end

      it 'applies filters when provided' do
        filters = { category_id: 1 }
        allow(expense_repo).to receive(:find_by_user).with(user_id, filters).and_return([expenses[0]])
        
        csv = service.export_to_csv(user_id, filters)
        lines = csv.split("\n")
        
        expect(lines.length).to eq(2) # header + 1 expense
        expect(lines[1]).to include('1,50.00')
      end
    end

    context 'with no expenses' do
      it 'returns only header row' do
        allow(expense_repo).to receive(:find_by_user).with(user_id, {}).and_return([])
        
        csv = service.export_to_csv(user_id)
        lines = csv.split("\n")
        
        expect(lines.length).to eq(1)
        expect(lines[0]).to eq('id,amount,date,description,category_id,user_id,tags,currency,created_at')
      end
    end
  end

  describe '#export_to_json' do
    let(:user_id) { 1 }
    let(:expenses) do
      [
        Expense.new(
          id: 1,
          amount: 50.00,
          date: Date.new(2025, 1, 15),
          description: 'Lunch at restaurant',
          category_id: 1,
          user_id: user_id,
          tags: ['food', 'dining'],
          currency: 'USD',
          created_at: Time.new(2025, 1, 15, 10, 30, 0)
        ),
        Expense.new(
          id: 2,
          amount: 100.50,
          date: Date.new(2025, 1, 20),
          description: 'Dinner',
          category_id: 2,
          user_id: user_id,
          tags: ['dining'],
          currency: 'EUR',
          created_at: Time.new(2025, 1, 20, 18, 0, 0)
        )
      ]
    end

    context 'with expenses' do
      it 'generates JSON array with expense data' do
        allow(expense_repo).to receive(:find_by_user).with(user_id, {}).and_return(expenses)
        
        json = service.export_to_json(user_id)
        data = JSON.parse(json)
        
        expect(data).to be_an(Array)
        expect(data.length).to eq(2)
        expect(data[0]['id']).to eq(1)
        expect(data[0]['amount']).to eq(50.00)
        expect(data[0]['date']).to eq('2025-01-15')
        expect(data[0]['description']).to eq('Lunch at restaurant')
        expect(data[0]['tags']).to eq(['food', 'dining'])
      end

      it 'formats dates correctly in JSON' do
        allow(expense_repo).to receive(:find_by_user).with(user_id, {}).and_return(expenses)
        
        json = service.export_to_json(user_id)
        data = JSON.parse(json)
        
        expect(data[0]['date']).to eq('2025-01-15')
        expect(data[1]['date']).to eq('2025-01-20')
      end

      it 'includes all expense fields in JSON' do
        allow(expense_repo).to receive(:find_by_user).with(user_id, {}).and_return(expenses)
        
        json = service.export_to_json(user_id)
        data = JSON.parse(json)
        
        expense = data[0]
        expect(expense).to have_key('id')
        expect(expense).to have_key('amount')
        expect(expense).to have_key('date')
        expect(expense).to have_key('description')
        expect(expense).to have_key('category_id')
        expect(expense).to have_key('user_id')
        expect(expense).to have_key('tags')
        expect(expense).to have_key('currency')
        expect(expense).to have_key('created_at')
      end

      it 'serializes tags as JSON array' do
        allow(expense_repo).to receive(:find_by_user).with(user_id, {}).and_return(expenses)
        
        json = service.export_to_json(user_id)
        data = JSON.parse(json)
        
        expect(data[0]['tags']).to be_an(Array)
        expect(data[0]['tags']).to eq(['food', 'dining'])
        expect(data[1]['tags']).to eq(['dining'])
      end

      it 'applies filters when provided' do
        filters = { category_id: 1 }
        allow(expense_repo).to receive(:find_by_user).with(user_id, filters).and_return([expenses[0]])
        
        json = service.export_to_json(user_id, filters)
        data = JSON.parse(json)
        
        expect(data.length).to eq(1)
        expect(data[0]['id']).to eq(1)
      end
    end

    context 'with no expenses' do
      it 'returns empty JSON array' do
        allow(expense_repo).to receive(:find_by_user).with(user_id, {}).and_return([])
        
        json = service.export_to_json(user_id)
        data = JSON.parse(json)
        
        expect(data).to eq([])
      end
    end
  end

  describe '#get_expenses_for_export' do
    let(:user_id) { 1 }
    let(:filters) { { category_id: 1 } }
    let(:expenses) { [Expense.new(id: 1, amount: 50.00, date: Date.today, description: 'Test', category_id: 1, user_id: user_id)] }

    it 'retrieves expenses from repository with filters' do
      expect(expense_repo).to receive(:find_by_user).with(user_id, filters).and_return(expenses)
      
      result = service.get_expenses_for_export(user_id, filters)
      expect(result).to eq(expenses)
    end

    it 'retrieves expenses without filters' do
      expect(expense_repo).to receive(:find_by_user).with(user_id, {}).and_return(expenses)
      
      result = service.get_expenses_for_export(user_id)
      expect(result).to eq(expenses)
    end
  end
end

