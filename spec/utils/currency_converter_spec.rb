require 'spec_helper'
require_relative '../../lib/utils/currency_converter'
require_relative '../../lib/models/expense'

RSpec.describe CurrencyConverter do
  describe '.convert' do
    it 'converts USD to EUR correctly' do
      result = CurrencyConverter.convert(100, 'USD', 'EUR')
      # 100 USD * (1/1.0) * 0.85 = 85 EUR
      expect(result).to be_within(0.01).of(85.0)
    end

    it 'converts EUR to USD correctly' do
      result = CurrencyConverter.convert(85, 'EUR', 'USD')
      # 85 EUR * (1/0.85) * 1.0 = 100 USD
      expect(result).to be_within(0.01).of(100.0)
    end

    it 'returns same amount when currencies are the same' do
      result = CurrencyConverter.convert(100, 'USD', 'USD')
      expect(result).to eq(100.0)
    end

    it 'handles JPY conversion' do
      result = CurrencyConverter.convert(100, 'USD', 'JPY')
      # 100 USD * (1/1.0) * 110.0 = 11000 JPY
      expect(result).to be_within(0.01).of(11000.0)
    end

    it 'returns nil for invalid source currency' do
      result = CurrencyConverter.convert(100, 'XYZ', 'USD')
      expect(result).to be_nil
    end

    it 'returns nil for invalid target currency' do
      result = CurrencyConverter.convert(100, 'USD', 'XYZ')
      expect(result).to be_nil
    end

    it 'returns nil for negative amounts' do
      result = CurrencyConverter.convert(-100, 'USD', 'EUR')
      expect(result).to be_nil
    end

    it 'rounds to 2 decimal places' do
      result = CurrencyConverter.convert(33.333, 'USD', 'EUR')
      expect(result).to be_a(Float)
      expect(result.to_s.split('.').last.length).to be <= 2
    end
  end

  describe '.convert_expense' do
    it 'converts expense amount to target currency' do
      expense = Expense.new(
        amount: 100,
        currency: 'USD',
        user_id: 1
      )
      result = CurrencyConverter.convert_expense(expense, 'EUR')
      expect(result).to be_within(0.01).of(85.0)
    end

    it 'returns nil for nil expense' do
      result = CurrencyConverter.convert_expense(nil, 'EUR')
      expect(result).to be_nil
    end

    it 'returns nil for expense without amount' do
      expense = Expense.new(currency: 'USD', user_id: 1)
      result = CurrencyConverter.convert_expense(expense, 'EUR')
      expect(result).to be_nil
    end
  end

  describe '.get_rate' do
    it 'returns exchange rate between two currencies' do
      rate = CurrencyConverter.get_rate('USD', 'EUR')
      expect(rate).to be_within(0.01).of(0.85)
    end

    it 'returns 1.0 for same currency' do
      rate = CurrencyConverter.get_rate('USD', 'USD')
      expect(rate).to eq(1.0)
    end

    it 'returns nil for invalid currencies' do
      rate = CurrencyConverter.get_rate('XYZ', 'USD')
      expect(rate).to be_nil
    end
  end

  describe '.supported?' do
    it 'returns true for supported currencies' do
      expect(CurrencyConverter.supported?('USD')).to be true
      expect(CurrencyConverter.supported?('EUR')).to be true
      expect(CurrencyConverter.supported?('GBP')).to be true
    end

    it 'returns false for unsupported currencies' do
      expect(CurrencyConverter.supported?('XYZ')).to be false
    end

    it 'handles case-insensitive input' do
      expect(CurrencyConverter.supported?('usd')).to be true
      expect(CurrencyConverter.supported?('Eur')).to be true
    end
  end

  describe '.supported_currencies' do
    it 'returns array of supported currency codes' do
      currencies = CurrencyConverter.supported_currencies
      expect(currencies).to be_an(Array)
      expect(currencies).to include('USD', 'EUR', 'GBP')
      expect(currencies.length).to be >= 8
    end

    it 'returns sorted array' do
      currencies = CurrencyConverter.supported_currencies
      expect(currencies).to eq(currencies.sort)
    end
  end
end

