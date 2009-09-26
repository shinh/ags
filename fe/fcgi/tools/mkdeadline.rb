require 'pstore'
db=PStore.new('db/problem.db')
db.transaction do
  deadlines = []
  db['root'].each do |prob|
    pdb=PStore.new("db/#{prob}.db")
    pdb.transaction(true) do
      dl = pdb['deadline']
      if dl && dl < Time.now.to_i
        dl = nil
      end
      deadlines << dl
    end
  end
  db['deadline'] = deadlines
end
