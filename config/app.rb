# Application configuration
module AppConfig
  APP_NAME = 'Expense Tracker'
  VERSION = '1.0.0'
  ENV = ENV['RACK_ENV'] || 'development'

  # Default settings
  DEFAULT_CURRENCY = 'USD'
  DEFAULT_PAGE_SIZE = 50
  MAX_BUDGET_ALERT_THRESHOLD = 80 # percentage

  # Date formats
  DATE_FORMAT = '%Y-%m-%d'
  DATETIME_FORMAT = '%Y-%m-%d %H:%M:%S'

  def self.production?
    ENV == 'production'
  end

  def self.development?
    ENV == 'development'
  end

  def self.test?
    ENV == 'test'
  end
end

