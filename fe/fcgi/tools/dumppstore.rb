require 'pstore'

db = PStore.new(ARGV[0])
db.transaction do
  if ARGV[1] == '-y'
    print db['root'].to_yaml
  else
    p db
  end
end

