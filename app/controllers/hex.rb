require 'hexdump'

# Read the keychain file
file_path = "841221146/login-keychain"
file_content = File.read(file_path)

# Output the first few bytes as a hex dump
hex_dump = Hexdump.dump(file_content[0, 256]) # Adjust the range as needed to inspect more bytes

puts hex_dump
