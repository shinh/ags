require 'handler'
require 'fileutils'

class Setpid < Handler
  @@serv = '192.168.36.2'
  @@port = 9999

  def handle_
    q = query

    pid = q.pid.to_i

    s = nil
    begin
      s = TCPSocket.open(@@serv, @@port)
    rescue
      puts %Q(now maintenance? it will be back soon. please try again later.)
      raise $!
    end

    payload = {
      :filename => 'setpid.rb',
      :code => "Process.setpriority(1764, 20, #{pid}); puts 'SUCCESS'",
      :inputs => [''],
    }
    encoded_payload = Marshal.dump(payload)
    s.puts(encoded_payload.size)
    s.print(encoded_payload)
    s.close_write

    payload = Marshal.load(s.read(s.gets.to_i))
    html_header
    title("setpid")
    puts payload[:stdout]
    err = payload[:stderr]
    if !err.empty?
      puts 'setpid failed (maybe the pid was too small or too big)'
    end
  end
end
