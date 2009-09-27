#!/usr/bin/env ruby
require'open-uri'
require'yaml/store'

UN = 'shinh'

fn = ARGV[0]
en = File.extname(fn)
bn = File.basename(fn, en)
url = ARGV[1]

db=YAML::Store.new("ag.db")
db.transaction do
  if url
    db[bn] = url
  else
    url = db[bn]
    if !url
      abort
    end
  end
end

url=~/p.rb\?/
pn=$'
url=$`+'submit.rb'

$A=open(fn)
require'submit'

on = "out#{en}"
on = 't/testing.vhdl' if en =~ /vhdl$/
c=%Q(curl -s -0 --form file=@#{on} --form-string problem=#{pn} --form-string reveal= --form-string user=#{UN} #{url})
puts `#{c}`

