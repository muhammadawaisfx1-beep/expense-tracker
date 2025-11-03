require 'bcrypt'

# User model representing an application user
class User
  attr_accessor :id, :name, :email, :password_hash, :created_at

  def initialize(params = {})
    @id = params[:id]
    @name = params[:name] || ''
    @email = params[:email] || ''
    @password_hash = params[:password_hash]
    @created_at = params[:created_at] || Time.now
  end

  def valid?
    return false if name.nil? || name.strip.empty?
    return false if email.nil? || email.strip.empty?
    return false unless email.include?('@')
    true
  end

  def set_password(password)
    return false if password.nil? || password.length < 6
    @password_hash = BCrypt::Password.create(password)
    true
  end

  def authenticate(password)
    return false if password_hash.nil? || password.nil?
    BCrypt::Password.new(password_hash) == password
  end

  def to_hash
    {
      id: id,
      name: name,
      email: email,
      created_at: created_at.to_s
    }
  end

  def to_json(*args)
    to_hash.to_json(*args)
  end
end

