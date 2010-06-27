require 'handler'
require 'fileutils'

class Setpid < Handler
  def handle_
    q = query

    pid = q.pid.to_i

    s = execute2('setpid.rb',
                 "Process.setpriority(1764, 20, #{pid}); puts 'SUCCESS'",
                 [''])

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
