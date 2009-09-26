require 'pstore'
db=PStore.new('db/problem.db')
db.transaction do
  a=[]
  db['root'].each do |pn|
    puts pn
    pdb=PStore.new("db/#{pn}.db")
    pdb.transaction(true) do
      p pdb['deadline']
      a << pdb['deadline']
    end
  end
  p a
  db['deadline'] = a
end

