require 'sqlite3'
require 'fileutils'

# Database configuration module
module DatabaseConfig
  DB_PATH = File.join(File.dirname(__dir__), '..', 'db', 'expense_tracker.db')

  def self.setup
    db_dir = File.dirname(DB_PATH)
    FileUtils.mkdir_p(db_dir) unless Dir.exist?(db_dir)

    db = SQLite3::Database.new(DB_PATH)
    db.results_as_hash = true

    create_tables(db)
    db
  end

  def self.create_tables(db)
    db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    SQL

    db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        budget_limit REAL,
        user_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    SQL

    db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        description TEXT NOT NULL,
        category_id INTEGER,
        user_id INTEGER NOT NULL,
        tags TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories(id),
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    SQL

    db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        period_start TEXT NOT NULL,
        period_end TEXT NOT NULL,
        user_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories(id),
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    SQL
  end

  def self.connection
    @connection ||= setup
  end
end

