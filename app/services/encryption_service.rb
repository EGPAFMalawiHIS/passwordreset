# app/services/compact_encryption.rb
=begin
The EncryptionService class generates a compact, 11-character Base62-encoded string from a user object
 containing firstname, lastname, username, and location_id, along with the current timestamp,
 to create a unique short code that expires after 24 hours. It extracts the first and last 
 characters of the first name, last name, and username (e.g., "Patrick" becomes "Pk"), and the four letter starting from index 4 and 
 last two characters of the UUID (e.g., "ba16d594-8d80-11d8-abbb-0024217bb78e" becomes "d594"), 
 then packs these into 66 bits—10 bits each for the name fields, 20 bits for the UUID segment, 
 and 26 bits for a timestamp offset from April 7, 2025—ensuring a lossless, 
 reversible representation within 12 characters. During decoding, it reconstructs the original data 
 and calculates the expiration time by adding 24 hours to the generation timestamp,
  providing a concise, efficient way to encode and verify time-sensitive user information
=end
require 'digest'

class EncryptionService  
  ALPHABET = ('a'..'z').to_a + ('0'..'9').to_a + ['/']
  CHAR_TO_INT = ALPHABET.each_with_index.to_h
  INT_TO_CHAR = CHAR_TO_INT.invert

  # Custom Base62 encoding/decoding module
  module Base62
    CHARS = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz".freeze
    BASE = CHARS.length

    def self.encode(num)
      return CHARS[0] if num == 0
      result = ""
      while num > 0
        result = CHARS[num % BASE] + result
        num /= BASE
      end
      result
    end

    def self.decode(str)
      str.chars.reduce(0) { |num, char| num * BASE + CHARS.index(char) }
    end
  end

  def self.string_to_int(str, max_chars)
    str = str.downcase[0, max_chars].ljust(max_chars, 'a')
    result = 0
    str.chars.each_with_index do |char, i|
      result += (CHAR_TO_INT[char] || 0) * (36 ** (max_chars - 1 - i))
    end
    result
  end

  def self.int_to_string(num, max_chars)
    result = ''
    temp = num
    max_chars.times do |i|
      power = max_chars - 1 - i
      char_idx = (temp / (36 ** power)) % 36
      result << INT_TO_CHAR[char_idx]
      temp -= char_idx * (36 ** power)
    end
    result
  end

  def self.derive_key(secret_key)
    key = Digest::SHA256.hexdigest(secret_key).to_i(16) & 0x3FFFFFFFFFFFF
    key
  end

  def self.encrypt_to_code(user, secret_key)
    generation_time = Time.now.to_i
    base_time = Time.now.to_i + 24 * 60 * 60  # 24 hours from now
    data = "#{user[:firstname][0] + user[:firstname][-1]}/#{user[:lastname][0] + user[:lastname][-1]}/#{user[:username][0] + user[:username][-1]}/#{user[:location_id]}/#{generation_time}"
    
    parts = data.split('/')
    fname = string_to_int(parts[0], 2)
    lname = string_to_int(parts[1], 2)
    username = string_to_int(parts[2], 2)
    location_id = parts[3].to_i
    timestamp = generation_time - base_time

    packed = 0
    packed |= timestamp & 0x3FFFFFF         # 26 bits, handles negative
    packed |= (location_id & 0x3FF) << 26   # 10 bits
    packed |= username << (26 + 10)
    packed |= lname << (26 + 10 + 10)
    packed |= fname << (26 + 10 + 10 + 10)

    key = derive_key(secret_key)
    obfuscated = packed ^ key

    short_code = Base62.encode(obfuscated)

    puts "Data to be encrypted: #{user}"
    puts "Original Data: #{data}"
    puts "Short Code: #{short_code} (Length: #{short_code.length})"

    short_code
  end

  def self.decrypt_from_code(received_code, secret_key)
    key = derive_key(secret_key)
    obfuscated = Base62.decode(received_code)
    packed = obfuscated ^ key

    fname = int_to_string(packed >> (26 + 10 + 10 + 10), 2)
    lname = int_to_string((packed >> (26 + 10 + 10)) & 0x3FF, 2)
    username = int_to_string((packed >> (26 + 10)) & 0x3FF, 2)
    location_id = ((packed >> 26) & 0x3FF).to_s
    timestamp = (packed & 0x3FFFFFF)
    timestamp = timestamp - 0x4000000 if timestamp >= 0x2000000
    generation_time = timestamp + (Time.now.to_i + 24 * 60 * 60)
    expiration_time = generation_time + 24 * 60 * 60

    original_data = "#{fname}/#{lname}/#{username}/#{location_id}/#{generation_time}"

    puts "Received Code: #{received_code}"
    puts "Decompressed Data (Generated At): #{original_data}"
    puts "Expiration Time: #{expiration_time} (#{Time.at(expiration_time).strftime('%I:%M %p')})"

    { generated_at: original_data, expires_at: expiration_time }
  rescue StandardError => e
    { error: "Decryption failed: #{e.message}" }
  end
end


