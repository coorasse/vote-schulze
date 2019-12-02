require 'active_support/all'

# utility to generate a random example file for a votation.
puts "hello #{ARGV[0]}, #{ARGV[1]}"

candidates = (1..ARGV[0].to_i).to_a

votes = {}
ARGV[1].to_i.times do |vote_index|
  vote = candidates.shuffle.in_groups_of(candidates.sample).map { |g| g.compact.join(',')}.compact.join(';')
  votes[vote] ||= 0
  votes[vote] += 1
end

file_name = "vote#{ARGV[0]}-#{rand(10000)}.list"
File.open(File.join(File.dirname(__FILE__), 'support', 'examples', file_name), 'w') do |file|
  file.puts ARGV[0]
  votes.each do |key, value|
    file.puts "#{value}=#{key}"
  end
end

puts "file generated: #{file_name}"
