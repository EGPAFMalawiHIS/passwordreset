# app/services/compact_encryption.rb
=begin
The EncryptionService class generates a compact, 11-character Base62-encoded string from a user object
 containing firstname, lastname, username, and location_uuid, along with the current timestamp,
 to create a unique short code that expires after 24 hours. It extracts the first and last 
 characters of the first name, last name, and username (e.g., "Patrick" becomes "Pk"), and the first two and 
 last two characters of the UUID (e.g., "ba16d594-8d80-11d8-abbb-0024217bb78e" becomes "ba8e"), 
 then packs these into 66 bits—10 bits each for the name fields, 20 bits for the UUID segment, 
 and 26 bits for a timestamp offset from April 7, 2025—ensuring a lossless, 
 reversible representation within 12 characters. During decoding, it reconstructs the original data 
 and calculates the expiration time by adding 24 hours to the generation timestamp,
  providing a concise, efficient way to encode and verify time-sensitive user information
=end
 require 'base62'

class EncryptionService
  DELIMITER = "-"
  
  # Alphabet: a-z, 0-5, /
  ALPHABET = ('a'..'z').to_a + %w(0 1 2 3 4 5 /)
  CHAR_TO_INT = ALPHABET.each_with_index.to_h
  INT_TO_CHAR = CHAR_TO_INT.invert
  BASE_TIME = Time.new(2025, 4, 7).to_i  # Base timestamp: 1744022400

  # Encode string to integer (5 bits/char)
  def self.string_to_int(str, max_chars)
    str = str.downcase[0, max_chars].ljust(max_chars, 'a')
    result = 0
    str.chars.each_with_index do |char, i|
      result |= (CHAR_TO_INT[char] || 0) << (5 * (max_chars - 1 - i))
    end
    result
  end

  # Decode integer to string
  def self.int_to_string(num, max_chars)
    result = ''
    max_chars.times do
      char_idx = (num >> (5 * (max_chars - 1))) & 0x1F
      result << INT_TO_CHAR[char_idx]
      num <<= 5
    end
    result
  end

  # Generate short code with current time
  def self.encrypt_to_code(user, _secret_key = nil)
    # Construct data with generation time using hash
    generation_time = Time.now.to_i
    data = "#{user[:firstname][0] + user[:firstname][-1]}/#{user[:lastname][0] + user[:lastname][-1]}/#{user[:username][0] + user[:username][-1]}/#{user[:location_uuid][0, 2] + user[:location_uuid][-2, 2]}/#{generation_time}"

    parts = data.split('/')
    fname = string_to_int(parts[0], 2)      # 10 bits
    lname = string_to_int(parts[1], 2)      # 10 bits
    username = string_to_int(parts[2], 2)   # 10 bits
    location_uuid = string_to_int(parts[3], 4)  # 20 bits
    timestamp = generation_time - BASE_TIME # 26 bits (offset)

    # Pack into 66 bits
    packed = 0
    packed |= timestamp & 0x3FFFFFF         # 26 bits
    packed |= location_uuid << 26           # 20 bits
    packed |= username << (26 + 20)         # 10 bits
    packed |= lname << (26 + 20 + 10)       # 10 bits
    packed |= fname << (26 + 20 + 10 + 10)  # 10 bits

    short_code = Base62.encode(packed).upcase

    # Log for debugging
    puts "Original Data: #{data}"
    puts "Short Code: #{short_code} (Length: #{short_code.length})"

    short_code
  end

  # Decode short code and infer expiration
  def self.decrypt_from_code(received_code, _secret_key = nil)
    packed = Base62.decode(received_code)
    fname = int_to_string(packed >> (26 + 20 + 10 + 10), 2)
    lname = int_to_string((packed >> (26 + 20 + 10)) & 0x3FF, 2)
    username = int_to_string((packed >> (26 + 20)) & 0x3FF, 2)
    location_uuid = int_to_string((packed >> 26) & 0xFFFFF, 4)
    generation_time = (packed & 0x3FFFFFF) + BASE_TIME
    expiration_time = generation_time + 24 * 60 * 60  # Add 24 hours

    original_data = "#{fname}/#{lname}/#{username}/#{location_uuid}/#{generation_time}"
    expiration_data = "#{fname}/#{lname}/#{username}/#{location_uuid}/#{expiration_time}"

    # Log for debugging
    puts "Received Code: #{received_code}"
    puts "Decompressed Data (Generated At): #{original_data}"
    puts "Expiration Time: #{expiration_time} (#{Time.at(expiration_time).utc})"

    # Return both for convenience
    { generated_at: original_data, expires_at: expiration_time }
  rescue StandardError => e
    "Error: #{e.message}"
  end
end
