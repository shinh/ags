require 'pstore'
db=PStore.new('db/problem.db')
db.transaction do
#  p db['deadline'].delete_at(149)
#  p db['root'].delete('CALC')
  p db['root'].delete('Simultaneous Equations')
end

