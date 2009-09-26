require 'pstore'
`find db/ -name _ranks.db`.each do |l|
  db = PStore.new(l.chomp)
  db.transaction do
    db.roots.each do |k|
      db[k].each_with_index do |x, i|
	     if x[0]=~/Jitensya/
		 p db[k][i]
		p db[k].delete_at(i)
#		 p db[k][i]
		 end
#        if x[2] == 0.0
#p x, k, l
#          p db[k].delete_at(i)
#        end
      end
    end
  end
end
