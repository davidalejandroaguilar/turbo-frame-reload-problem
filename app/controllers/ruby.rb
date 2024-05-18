require 'base64'

# Your encoded string
encoded_string = File.read("/Users/david/src/repos/oink/http_raw_data_b64_key.bin")

# Decode the Base64 string
decoded_bytes = Base64.decode64(encoded_string)

# Check the first few bytes of the decoded file
signature = decoded_bytes[0, 4]
puts "File signature: #{signature.inspect}"

puts "Decoded data: #{decoded_bytes}"

File.delete("./decoded_output.zip") if File.exist?("./decoded_output.zip")

# Save the decoded bytes to a file
File.open("decoded_output.zip", "wb") do |file|
  file.write(decoded_bytes)
end

puts "Decoded data saved to 'decoded_output.zip'"
