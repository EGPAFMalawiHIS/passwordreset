# Disable foreign key checks
ActiveRecord::Base.connection.execute("SET FOREIGN_KEY_CHECKS=0")

# Clear existing data
PasswordReset.delete_all
Location.delete_all
User.delete_all

# Re-enable foreign key checks
ActiveRecord::Base.connection.execute("SET FOREIGN_KEY_CHECKS=1")

# Import locations from CSV
require 'csv'

def import_locations
  csv_path = Rails.root.join('public', 'locations.csv')
  
  CSV.foreach(csv_path, headers: true, quote_char: '"', col_sep: ',', liberal_parsing: true) do |row|
    Location.create!(
      name: row['name']&.strip,
      description: row['description']&.gsub('""', '"')&.strip,
      retired: row['retired'] == '1' || row['retired']&.downcase == 'true',
      uuid: row['uuid']&.strip
    )
  end
  
  puts "Imported #{Location.count} locations"
end

# Import locations first
import_locations

# Create a default location if none exists
default_location = Location.find_or_create_by!(
  name: 'Unknown',
  description: 'Default location when no specific location is selected',
  retired: false,
  uuid: SecureRandom.uuid
)

# Create admin user
admin_user = User.create!(
  username: 'admin',
  email: 'admin@example.com',
  phone: '+265888876600',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Admin',
  last_name: 'User',
  role: 'admin'
)

puts "Seeding complete!"
puts "Total Locations: #{Location.count}"