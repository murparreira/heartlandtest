require_relative 'photo_renamer'

if ARGV.size != 1
  puts 'Usage: ruby solution.rb <filename>'
  puts 'You can change the content inside photos.txt, or use another file'
  exit 1
end

filename = ARGV[0]

begin
  input_string = File.read(filename)
rescue Errno::ENOENT
  puts "Error: File not found - '#{filename}'"
  exit 1
end

renamer = PhotoRenamer.new
result = renamer.photo_renamer(input_string)
puts result
