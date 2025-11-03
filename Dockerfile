FROM ruby:3.0-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    sqlite3 \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy Gemfile and install dependencies
COPY Gemfile Gemfile.lock* ./
RUN bundle install

# Copy application code
COPY . .

# Create database directory
RUN mkdir -p db

# Expose port
EXPOSE 9292

# Run the application
CMD ["bundle", "exec", "rackup", "config.ru", "-o", "0.0.0.0", "-p", "9292"]

