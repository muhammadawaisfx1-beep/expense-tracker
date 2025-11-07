require_relative '../../config/app'

# Utility module for currency conversion
module CurrencyConverter
  # Exchange rates (base: USD)
  # In a real application, these would be fetched from an API
  EXCHANGE_RATES = {
    'USD' => 1.0,
    'EUR' => 0.85,
    'GBP' => 0.73,
    'JPY' => 110.0,
    'CAD' => 1.25,
    'AUD' => 1.35,
    'CHF' => 0.92,
    'CNY' => 6.45,
    'INR' => 74.0
  }.freeze

  # Convert amount from one currency to another
  # @param amount [Float] The amount to convert
  # @param from_currency [String] Source currency code
  # @param to_currency [String] Target currency code
  # @return [Float] Converted amount
  def self.convert(amount, from_currency, to_currency)
    return amount if from_currency.to_s.upcase == to_currency.to_s.upcase
    return nil if amount.nil? || amount < 0

    from_rate = EXCHANGE_RATES[from_currency.to_s.upcase]
    to_rate = EXCHANGE_RATES[to_currency.to_s.upcase]

    return nil unless from_rate && to_rate

    # Convert to USD first (base currency), then to target currency
    usd_amount = amount / from_rate
    converted_amount = usd_amount * to_rate

    (converted_amount * 100).round / 100.0 # Round to 2 decimal places
  end

  # Convert expense amount to a target currency
  # @param expense [Expense] The expense object
  # @param target_currency [String] Target currency code
  # @return [Float] Converted amount, or nil if conversion fails
  def self.convert_expense(expense, target_currency)
    return nil unless expense && expense.amount && expense.currency
    convert(expense.amount, expense.currency, target_currency)
  end

  # Get exchange rate between two currencies
  # @param from_currency [String] Source currency code
  # @param to_currency [String] Target currency code
  # @return [Float] Exchange rate, or nil if currencies are invalid
  def self.get_rate(from_currency, to_currency)
    return 1.0 if from_currency.to_s.upcase == to_currency.to_s.upcase

    from_rate = EXCHANGE_RATES[from_currency.to_s.upcase]
    to_rate = EXCHANGE_RATES[to_currency.to_s.upcase]

    return nil unless from_rate && to_rate

    to_rate / from_rate
  end

  # Check if a currency code is supported
  # @param currency [String] Currency code to check
  # @return [Boolean] True if currency is supported
  def self.supported?(currency)
    EXCHANGE_RATES.key?(currency.to_s.upcase)
  end

  # Get list of supported currencies
  # @return [Array<String>] Array of supported currency codes
  def self.supported_currencies
    EXCHANGE_RATES.keys.sort
  end
end

