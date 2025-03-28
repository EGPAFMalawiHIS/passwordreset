# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# Create admin user
User.find_or_create_by!(username: 'admin') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.first_name = 'Admin'
  user.last_name = 'User'
end

# Create some sample users
User.find_or_create_by!(username: 'johndoe') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.first_name = 'John'
  user.last_name = 'Doe'
end

User.find_or_create_by!(username: 'janedoe') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
  user.first_name = 'Jane'
  user.last_name = 'Doe'
end

# Create some sample reset transactions
user = User.find_by(username: 'johndoe')
if user
  ResetTransaction.find_or_create_by!(reset_code: 'JODO20240325ABC123XYZ') do |transaction|
    transaction.user = user
    transaction.status = :active
    transaction.location = 'New York'
    transaction.date_of_birth = '1990-01-15'
    transaction.sex = 'male'
    transaction.expires_at = 24.hours.from_now
  end
  
  ResetTransaction.find_or_create_by!(reset_code: 'JODO20240324DEF456UVW') do |transaction|
    transaction.user = user
    transaction.status = :expired
    transaction.location = 'New York'
    transaction.date_of_birth = '1990-01-15'
    transaction.sex = 'male'
    transaction.expires_at = 1.day.ago
  end
end
