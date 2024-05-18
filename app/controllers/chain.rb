require 'keychain'
require 'debug'

# Open the keychain
# keychain_path = File.expand_path('~/Library/Keychains/mal-db')
keychain_path = File.expand_path('~/Library/Keychains/login.keychain-db')
keychain = Keychain.open(keychain_path)

debugger

# Fetch and display generic passwords
puts "Generic Passwords:"
keychain.generic_passwords.all.each do |item|
  puts "Service: #{item.service}"
  puts "Account: #{item.account}"
  puts "Label: #{item.label}"
  begin
    puts "Password: #{item.password}"
  rescue => e
    puts "Error fetching password: #{e.message}"
  end
  puts "-" * 40
end

# Fetch and display internet passwords
puts "Internet Passwords:"
keychain.internet_passwords.all.each do |item|
  puts "Server: #{item.server}"
  puts "Account: #{item.account}"
  puts "Label: #{item.label}"
  begin
    puts "Password: #{item.password}"
  rescue => e
    puts "Error fetching password: #{e.message}"
  end
  puts "-" * 40
end
