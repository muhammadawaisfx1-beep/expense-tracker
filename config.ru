require_relative 'lib/app'
require_relative 'config/app'
require_relative 'config/database'

# Initialize database
DatabaseConfig.setup

# Run the application
run ExpenseTrackerApp

