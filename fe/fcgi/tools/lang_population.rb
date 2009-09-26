require 'pstore'
m=Hash.new{0}
`find db/ -name _ranks.db`.each do |l|
  db = PStore.new(l.chomp)
  db.transaction(true) do
    db.roots.each do |k|
	  m[k] += db[k].size
    end
  end
end
m.each do |k, v|
	puts "#{v} #{k}"
end
