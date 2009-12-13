require 'pstore'
db=PStore.new('db/problem.db')
db.transaction do
  prob = ARGV[0]
  i = db['root'].index(prob)
  p db['root'][i]
  p Time.at(db['deadline'][i])

  if ARGV[1] == '-f'
    db['root'].delete_at(i)
    db['deadline'].delete_at(i)
  end
end

