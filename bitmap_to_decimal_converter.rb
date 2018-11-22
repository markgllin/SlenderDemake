lines = []
lines_reversed = []
File.readlines('bitmap').each do |line|
  lines << line.to_i(2)
  lines_reversed << line.reverse!.to_i(2)
end

chars = lines.each_slice(8).to_a

parsed = []
chars.each do |char|
  parsed << "dc.b #{char.join(',')}"
end

chars_reversed = lines_reversed.each_slice(8).to_a
parsed_reveresed = []
chars_reversed.each do |char|
  parsed_reveresed << "dc.b #{char.join(',')}"
end

puts parsed
puts ''
puts parsed_reveresed
