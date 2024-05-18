require 'base64'
require 'cgi'
require 'debug'
require 'zlib'

# Read the exported HTTP request file
http_request = File.read("/Users/david/src/repos/oink/joinsystem_http")

# Debug: Output the content of the HTTP request
puts "HTTP Request Content:"
puts http_request

# Parse the query string to extract the 'B64' parameter
params = CGI::parse(http_request)

encoded_string = params["B64"].first

# Debug: Output the Base64 encoded string
puts "Base64 Encoded String:"
puts encoded_string

# Ensure the Base64 string is complete and has correct padding
encoded_string = encoded_string.gsub("\n", "").gsub(" ", "")

# Decode the Base64 string
begin
  decoded_bytes = Base64.decode64(encoded_string)
rescue ArgumentError => e
  puts "Error decoding Base64 string: #{e.message}"
  exit 1
end

File.delete("./decoded_output.zip") if File.exist?("./decoded_output.zip")

# Save the decoded bytes to a zip file

File.open("decoded_output.zip", "wb") do |file|
  file.write(decoded_bytes)
end

puts "Decoded data saved to 'decoded_output.zip'"

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

# Verify the ZIP file integrity using the Zlib library
begin
  Zlib::GzipReader.open('decoded_output.zip') do |gz|
    puts "GZIP File Contents:"
    puts gz.read
  end
rescue Zlib::GzipFile::Error => e
  puts "Error reading GZIP file: #{e.message}"
end

# Try to list contents of the ZIP file using the 'zipinfo' command
system("zipinfo decoded_output.zip")

# Try to extract the ZIP file using the 'unzip' command
system("unzip -l decoded_output.zip")
