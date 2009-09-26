#!/usr/bin/env ruby

require 'fcgi'
require 'cgi'

m = {}

def update_check(m, s)
  if (!m.key?(s) || m[s][:time] < File.mtime(s))
    File.open(s) do |i|
      eval(i.read)
    end
    if (!m.key?(s))
      m[s] = {}
    end
    m[s][:time] = Time.now
    m[s][:class] = eval(s[/[a-z]+/].capitalize)
  end
end

FCGI.each do |req|
  o = req.out
  e = req.env
  s = req.env['SCRIPT_NAME']

  begin
    s = s[/\/(.*)/,1]
    if (!File.exists?(s))
      o.print "Status Code: 404 Not Found\r\n"
      req.finish
      next
    end

    update_check(m, 'handler.rb')
    update_check(m, s)

    h = m[s][:class].send(:new)
    h.handle(req)
  rescue
    o.print "Content-Type: text/plain\r\n\r\n"
    o.puts "CORE in #{s}"
    o.puts "#{$!}"
    o.puts "#{$!.backtrace*"\n"}"
    req.finish
  end
end
