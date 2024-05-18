require 'base64'
require 'cgi'
require 'debug'

# Function to convert Base64URL to standard Base64
def base64url_to_base64(base64url)
  base64 = base64url.tr('-_', '+/')
  padding = base64.length % 4
  base64 += '=' * (4 - padding) unless padding == 0
  base64
end

# Read the exported HTTP request file
http_request = File.read("/Users/david/src/repos/oink/joinsystem_http")

# Debug: Output the content of the HTTP request
puts "HTTP Request Content:"
puts http_request

# Extract the Base64URL string using a more robust parsing approach
begin
  params = CGI::parse(http_request)
  encoded_string = params["B64"].first
  raise "B64 parameter not found" if encoded_string.nil?
rescue => e
  puts "Error parsing HTTP request: #{e.message}"
  exit 1
end

# Debug: Output the Base64URL encoded string
puts "Base64URL Encoded String:"
puts encoded_string

# Convert Base64URL to standard Base64
encoded_string = base64url_to_base64(encoded_string)

# Debug: Output the converted Base64 string
puts "Converted Base64 String:"
puts encoded_string

# Decode the Base64 string
begin
  decoded_bytes = Base64.decode64(encoded_string)
rescue ArgumentError => e
  puts "Error decoding Base64 string: #{e.message}"
  exit 1
end

# Save the decoded bytes to a file
begin
  File.open("decoded_output.zip", "wb") do |file|
    file.write(decoded_bytes)
  end
  puts "Decoded data saved to 'decoded_output.zip'"
rescue => e
  puts "Error writing to file: #{e.message}"
  exit 1
end

# Check the first few bytes of the decoded file
signature = decoded_bytes[0, 4].unpack('H*').first
puts "File signature: #{signature}"

# Known file signatures for common formats
file_signatures = {
  "zip" => "504b0304", # ZIP files
  "pdf" => "25504446", # PDF files
  "jpg" => "ffd8ffe0", # JPEG files
  "png" => "89504e47", # PNG files
  # Add more signatures as needed
}

# Determine the file type based on the signature
file_type = file_signatures.key(signature)
if file_type
  puts "Detected file type: #{file_type}"
else
  puts "Unknown file type"
end

# Try to extract the ZIP file using rubyzip
begin
  require 'zip'
  Zip::File.open('decoded_output.zip') do |zip_file|
    zip_file.each do |entry|
      puts "Extracting #{entry.name}"
      entry.extract(entry.name)
    end
  end
  puts "ZIP file extracted successfully"
rescue Zip::Error => e
  puts "Error extracting ZIP file: #{e.message}"
end
