#!/usr/bin/env ruby

require 'socket'

s = TCPSocket.new('192.168.36.2', 9999)
payload = {
  :filename => 'version.rb',
  :code => File.read('version.rb'),
  :inputs => [''],
}
encoded_payload = Marshal.dump(payload)
s.puts(encoded_payload.size)
s.print(encoded_payload)
s.close_write

payload = Marshal.load(s.read(s.gets.to_i))
puts payload[:stdout]


