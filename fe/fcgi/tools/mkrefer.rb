#!/usr/bin/env ruby
require 'zlib'
require 'pstore'
require 'open-uri'

f=Zlib::GzipReader.new(File.open(ARGV[0]))
dbs={}
while f.gets
  if $_ !~ /GET \/p\.rb\?(\S+).*?" 200 .*?"([^"]+)/
    next
  end

  prob = $1
  refer = $2

  next if prob =~ /%/
  next if refer == '-' || refer =~ /\.shinh.org/ || refer =~ /\.google\./ || refer =~ /\.goo\./ || refer =~ /\.yahoo\./ || refer =~ /\.search\./

  puts "#{prob} #{refer}"

  db = dbs[prob]
  if !db
  	begin
      db = PStore.new("db/#{prob.tr("+"," ")}/_refer.db")
	rescue
	  next
	end
    dbs[prob] = db
  end

  db.transaction do
    if db.root?(refer)
      if db[refer]
        db[refer] += 1
      end
    else
      begin
        c = open(refer).read
        if c =~ /golf\.shinh\.org\/p\.rb\?/
          db[refer] = 1
        else
          db[refer] = nil
        end
      rescue
        db[refer] = nil
      end
    end
  end
end
