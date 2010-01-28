require 'pstore'
raise if ARGV.size != 3
pn = ARGV[0]
lang = ARGV[1]
rank = ARGV[2].to_i
db=PStore.new("db/#{ARGV[0]}/_ranks.db")

record = db.transaction(true) do
  db[ARGV[1]][rank]
end
p record

puts 'Are you sure? Press return to continue'
STDIN.gets

db.transaction do
  p db[ARGV[1]].delete_at(rank)
end
puts 'done'
