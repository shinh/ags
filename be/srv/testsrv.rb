require 'socket'
require 'open4'

SERV='192.168.35.2'
#SERV='localhost'
PORT=9999
#PORT=9997

NON_STRACE = ['sh', 'bf', 'ws', 'bef', 'unl', 'ms', 'pef', 'wr']

def daemon
  catch(:RUN_DAEMON) do
    unless (fork) then
      Process::setsid
      unless (fork) then
        Dir::chdir("/")
        File::umask(0)
        STDIN.close
        STDOUT.close
        STDERR.close
        throw :RUN_DAEMON
      end
    end
    exit!
  end
end

def run(exe, i = nil, timeout = 60)
begin
  pid, stdin, stdout, stderr = Open4.popen4("/golf/local/limit #{exe}")
rescue
  exit 1
end
  if i && i.size > 0
    begin
      stdin.print(i)
    rescue
    end
  end
  stdin.close

  start = Time.now

  o = ''
  status = nil
  eof = false
  while !status
    if eof
      sleep 0.01
    else
      sel = IO.select([stdout], nil, nil, 0.01)
      if sel
        begin
          o += stdout.sysread(100000)
          if o.size > 1000000
            eof = true
          end
        rescue EOFError
          eof = true
        end
      end
    end
    ignored, status = Process::waitpid2(pid, Process::WNOHANG)
    @n = Time.now
    if @n-start > timeout
      break
    end
  end

  if status
    lo = stdout.read(100000)
    lo = '' if !lo
    o += lo
    o = '' if !o
    e = stderr.read(100000)
    e = '' if !e
    [@n-start, status.exitstatus, o, e]
  else
    `pgrep -P #{pid}`.each do |l|
       puts "kill #{l}"
       Process.kill(:KILL, l.to_i) rescue puts "already died? #{l}"
    end
    puts "kill #{pid}"
#    Process::kill(:INT, pid)
    Process::kill(:KILL, pid) rescue puts "already died? #{pid}"
    Process::wait(pid)
    o=''
    e=''
#    if a=IO.select([stdout], [], [], 0.1)
##      o = stdout.read
#      o = a[0][0].read
#      if o.size > 100000
#        o = '(EXCESS OUTPUTS!)' + o[0,100000]
#      end
#    end
#    if a=IO.select([stderr], [], [], 0.1)
#      e = stderr.read
#      if e.size > 100000
#        e = '(EXCESS OUTPUTS!)' + e[0,100000]
#      end
#    end

#     o = ''
#     while c = stdout.getc
#       o += c.chr
#       if o.size > 10000
#         o = '(EXCESS OUTPUTS!) ' + o
#         break
#       end
#     end
#     e = ''
#     while c = stderr.getc
#       e += c.chr
#       if e.size > 10000
#         e = '(EXCESS OUTPUTS!) ' + e
#         break
#       end
#     end
    stdout.close
    stderr.close
    [nil, nil, o, e]
  end
end

if ARGV[0] == '-d'
  daemon
  log = File.open('log', 'w')
else
  log = STDOUT
end

#gs = TCPServer.open(SERV, PORT)
gs = TCPServer.open(PORT)

while true
  s = gs.accept

  begin
    Dir::chdir("/")
    if !system("/golf/remount")
      raise 'remount failed'
    end
    Dir::chdir("/golf/test")

    fn = s.gets.chomp
    t = File.extname(fn).tr('.','')
    cs = s.gets.to_i
    c = s.read(cs)
    tnum = s.gets.to_i
    testing = false
    if tnum == -1
      testing = true
      tnum = 1
    end
    inputs = []
    tnum.times {
      is = s.gets.to_i
      inputs << [s.read(is), s.gets.to_i]
    }
    File.open(f="test."+t, 'w') do |of|
      of.write(c)
    end

    log.puts("connected #{fn} #{cs}")

    ext = t
    scmd = cmd = "/golf/s/#{t} #{f} #{fn}"
    if !NON_STRACE.include?(ext)
      scmd = "strace -f -e execve -c -o str.log /golf/s/#{t} #{f} #{fn}"
      #scmd = "sh -c 'LD_PRELOAD=/golf/local/watch.so /golf/s/#{t} #{f} #{fn}'"
    end

    if File.exists?("/golf/s/_#{t}")
      t, r, o, e = run("/golf/s/_#{t} #{f} #{fn}")
      if !t
        s.puts "compile timeout"
        s.close
        log.puts("compile timeout err")
        next
      elsif r != 0
        #s.puts t
        s.puts 'compile error'
        s.puts r
        s.puts 0
        s.puts o.size
        s.print o
        s.puts e.size
        s.print e

        File.unlink(f) if File.exists?(f)
        s.close
        log.puts("compile err")
        next
      end
    end

    #ENV['LD_PRELOAD'] = '/golf/local/watch.so'

    inputs.each do |i|
      i, mode = i
      timeout = 1
      if testing
        timeout = 5
      else
        timeout = timeout * 3.0 / inputs.size
      end
      timeout += 0.5 if ext == 'java'
      timeout += 1 if ext == 'asy'
      timeout += 1 if ext == 'cs'
      timeout += 4 if ext == 'cy'
      timeout += 1 if ext == 'io'
      timeout += 1 if ext == 'erl'
      timeout += 1 if ext == 'r'
      timeout += 1 if ext == 'pl6'
      timeout += 4 if ext == 'exe'
      timeout += 3 if ext == 'groovy'
      timeout += 9 if ext == 'scala'
      timeout += 4 if ext == 'arc'
      if mode == 2
        cmd = scmd
      end
      t, r, o, e = run(cmd, i, timeout)

      if t
        execnt = 1  # for strace
        if File.exists?('/golf/test/watch.log')
          File.open('/golf/test/watch.log') do |ifile|
            ifile.each do |watch_line|
              if watch_line =~ /^open (\S*\/\S*)/ && (del_file = $1) && del_file !~ /^\/dev\//
                begin
                  puts "deleting #{del_file}"
                  File.unlink(del_file)
                rescue
                end
              elsif watch_line =~ /^exec/
                execnt += 1
              end
            end
          end
          #system('cp watch.log /tmp/t')
          File.unlink('/golf/test/watch.log')
        else
          execnt = 99999
        end
        puts "exec cnt: #{execnt}"

        if mode == 2
          execnt = 2
          if !NON_STRACE.include?(ext)
            begin
              trace = File.read('str.log').grep(/execve/)[0].split
              execnt = trace[3].to_i-trace[4].to_i
            rescue
            end
          end
        elsif mode == 0
          execnt = 2
        end

        s.puts t
        s.puts r
        s.puts execnt
        s.puts o.size
        s.print o
        s.puts e.size
        s.print e

        log.puts("done")
      else
        s.puts("timeout")
        s.puts 0
        s.puts execnt
        s.puts o.size
        s.print o
        s.puts e.size
        s.print e

        log.puts("timeout err (execnt=%d)" % execnt)
      end
    end

    #ENV['LD_PRELOAD'] = ''

    Dir.open("."){|d|
      d.each{|e|
        File.unlink(e) if e != '.' && e != '..'
      }
    }
#    File.unlink(f) if File.exists?(f)
#    File.unlink('a.out') if File.exists?('a.out')
    s.close
  rescue
    s.close
    log.puts($!)
    log.puts($!.backtrace*"\n")
  end
end
