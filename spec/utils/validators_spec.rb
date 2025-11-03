require 'spec_helper'
require_relative '../../lib/utils/validators'
require 'date'

RSpec.describe Validators do
  describe '.validate_amount' do
    it 'returns true for positive amounts' do
      expect(Validators.validate_amount(100)).to be true
      expect(Validators.validate_amount(100.50)).to be true
    end

    it 'returns false for zero or negative amounts' do
      expect(Validators.validate_amount(0)).to be false
      expect(Validators.validate_amount(-10)).to be false
    end

    it 'returns false for nil or non-numeric values' do
      expect(Validators.validate_amount(nil)).to be false
      expect(Validators.validate_amount('100')).to be false
    end
  end

  describe '.validate_date' do
    it 'returns true for valid Date objects' do
      expect(Validators.validate_date(Date.today)).to be true
    end

    it 'returns true for valid date strings' do
      expect(Validators.validate_date('2025-01-15')).to be true
    end

    it 'returns false for invalid date strings' do
      expect(Validators.validate_date('invalid-date')).to be false
    end

    it 'returns false for nil' do
      expect(Validators.validate_date(nil)).to be false
    end
  end

  describe '.validate_email' do
    it 'returns true for valid email addresses' do
      expect(Validators.validate_email('user@example.com')).to be true
    end

    it 'returns false for invalid email addresses' do
      expect(Validators.validate_email('invalid')).to be false
      expect(Validators.validate_email('user@')).to be false
      expect(Validators.validate_email('@example.com')).to be false
    end
  end
end

