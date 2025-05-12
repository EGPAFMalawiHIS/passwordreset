# Disable foreign key checks
ActiveRecord::Base.connection.execute("SET FOREIGN_KEY_CHECKS=0")

# Clear existing data
PasswordReset.delete_all
Location.delete_all
User.delete_all

# Re-enable foreign key checks
ActiveRecord::Base.connection.execute("SET FOREIGN_KEY_CHECKS=1")

# Import locations from JSON file
require 'json'

def import_locations
  json_path = Rails.root.join('public', 'locations.json')
  locations_data = JSON.parse(File.read(json_path))

  locations_data.each do |location|
    Location.create!(
      name: location['name']&.strip,
      location_id: location['location_id'],
      description: location['description']&.strip,
      retired: location['retired'] == 1 || location['retired'] == true,
      uuid: location['uuid']&.strip
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
  username: 'superadmin',
  email: 'admin@example.com',
  phone: '+265888876600',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Admin',
  last_name: 'User',
  role: 'admin'
)

admin_user = User.create!(
  username: 'lilian',
  email: 'lmajawa@pedaids.org',
  phone: '+265991312980',
  password: 'password@123',
  password_confirmation: 'password@123',
  first_name: 'Lilian',
  last_name: 'Majawa',
  role: 'admin'
)

puts "Seeding complete!"
puts "Total Locations: #{Location.count}"