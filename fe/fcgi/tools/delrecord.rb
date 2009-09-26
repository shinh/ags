require 'pstore'
db=PStore.new('db/numwarp/_ranks.db')
db.transaction do
#p db['hs'][0][0]='tanakh'
#p db['c'].delete_at(0)
#p db['rb'].delete_at(0)
#p db['rb'].delete_at(7)
#p db['ps'].delete_at(7)
p db['ps'].delete_at(2)
#p db['ps'][2]
#p db['rb'][7]

#p db['php'][-2]
#p db['php'].delete_at(-2)

#db['php'].insert(-2, ["ToastyX", 2, 3.0, Time.mktime(2008,1,28,4,2,14), [0], 1])
#db['php'].insert(-2, ["seon", 2, 3.0, Time.mktime(2008,1,29,14,28,38), [0], 1])
#db['l'].push(["mc", 9, 3.0, Time.mktime(2008,1,2,17,38,26), [0], 1])

#p db['z8b'][8]
#p db['java'][20][0]='bystonwell'
#  p db['bef'][2]
#p db['ml'].delete_at(1)
#p db['ml'].delete_at(2)
#p db['sed'].delete_at(0)
end

#db=PStore.new('db/recent.db')
#db.transaction do
#  p db['root'].delete_at(0)
#end
