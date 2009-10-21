require 'socket'
require 'open4'

Process.setrlimit(Process::RLIMIT_NPROC, 1024)
Process.setrlimit(Process::RLIMIT_RSS, 50)

SYSCALLS = {
  :execve => 11,
  :fork => 2,
  :vfork => 190,
  :clone => 120,
  :setpgid => 57,
  :setsid => 66,
  :getpriority => 96,
  :setpriority => 97,
  :setuid => 23,
  :setuid32 => 213,
  :setreuid => 70,
  :setreuid32 => 203,
  :setresuid => 164,
  :setresuid32 => 208,
  :setfsuid => 138,
  :setfsuid32 => 215,
  :setgid => 46,
  :setgid32 => 214,
  :setregid => 71,
  :setregid32 => 204,
  :setresgid => 170,
  :setresgid32 => 210,
  :setfsgid => 139,
  :setfsgid32 => 216,
}
SANDBOX_MAGIC_PRIORITY = 1764

def get_sandbox_val(sym)
  20 - Process.getpriority(1764, SYSCALLS[sym])
end

def set_sandbox_val(sym, cnt)
  Process.setpriority(1764, SYSCALLS[sym], cnt)
end

SERV='192.168.35.2'
#SERV='localhost'
PORT=9999
#PORT=9997

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

def setup_sandbox
  SYSCALLS.each do |sym, num|
    if sym != :setpriority
      set_sandbox_val(sym, 0)
    end
  end
end

def get_sandbox_vals
  m = {}
  SYSCALLS.each do |sym, num|
    m[sym] = get_sandbox_val(sym)
  end
  m
end

def sweep_prcesses
  setup_sandbox
  `pgrep -U 1000`.each do |l|
    l = l.to_i
    if l != $$ && l != Process.ppid
      puts "kill #{l}"
      Process.kill(:KILL, l) rescue puts "already died? #{l}"
    end
  end
end

def run(exe, i = nil, timeout = 60)
  setup_sandbox
  sandbox_vals = get_sandbox_vals

  begin
    pid, stdin, stdout, stderr = Open4.popen4(exe)
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

  # get values before killing.
  sandbox_cnts = {}
  get_sandbox_vals.each do |sym, val|
    sandbox_cnts[sym] = val - sandbox_vals[sym]
  end

  if status
    if IO.select([stdout], nil, nil, 0)
      lo = stdout.read(100000)
      lo = '' if !lo
      o += lo
    end
    if IO.select([stderr], nil, nil, 0)
      e = stderr.read(100000)
    end
    e = '' if !e

    ret = [@n-start, status.exitstatus, o, e]
  else
    setup_sandbox
    `pgrep -P #{pid}`.each do |l|
      puts "kill #{l}"
      Process.kill(:KILL, l.to_i) rescue puts "already died? #{l}"
    end
    puts "kill #{pid}"
    #Process::kill(:INT, pid)
    Process::kill(:KILL, pid) rescue puts "already died? #{pid}"
    Process::wait(pid)

    # TODO: show some outputs for timeout solutions
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
    ret = [nil, nil, o, e]
  end

  exec_cnt = sandbox_cnts[:execve]
  notice = []
  if sandbox_cnts[:setpriority] != 0
    puts 'cheat?'
    exec_cnt = -1
    notice << 'setpriority was called for cheating?'
  else
    if exec_cnt < 2
      notice << 'exec count is too small (execnt=%d). this message should not happen. please report this at shinichiro.hamaji _at_ gamil.com' % exec_cnt
      puts 'mysterious exec count: %d' % exec_cnt
    end
  end

  if sandbox_cnts[:fork] >= 100
    notice << 'some of your fork attempts might fail. you cannot fork >100 times'
  end

  [:setpgid, :setsid, :setuid, :setuid32, :setreuid, :setreuid32,
   :setresuid, :setresuid32, :setfsuid, :setfsuid32, :setgid, :setgid32,
   :setregid, :setregid32, :setresgid, :setresgid32,
   :setfsgid, :setfsgid32].each do |sys|
    if sandbox_cnts[sys] > 0
      notice << "you called forbidden system call (#{sys}). if you need this, please contact at shinichiro.hamaji _at_ gamil.com"
    end
  end


  ret << exec_cnt
  ret << sandbox_cnts
  ret << notice

  sweep_prcesses

  ret
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
    setup_sandbox
    Dir::chdir("/")
    if !system("/golf/remount")
      raise 'remount failed'
    end
    Dir::chdir("/golf/test")

    payload_size = s.gets.to_i
    payload = Marshal.load(s.read(payload_size))

    fn = payload[:filename]
    t = File.extname(fn).tr('.','')
    c = payload[:code]
    # TODO: remove this flag
    testing = false
    inputs = payload[:inputs]

    File.open(f="test."+t, 'w') do |of|
      of.write(c)
    end

    log.puts("connected #{fn} #{c.size}")

    ext = t
    cmd = "/golf/s/#{t} #{f} #{fn}"

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

    inputs.each do |i|
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
      t, r, o, e, execnt, sandbox_cnts, notice = run(cmd, i, timeout)

      if !notice.empty?
        log.puts('notice: %s' % notice.inspect)
      end

      payload = {
        :time => t,
        :status => r,
        :execnt => execnt,
        :stdout => o,
        :stderr => e,
        :notice => notice,
      }
      encoded_payload = Marshal.dump(payload)
      s.puts(encoded_payload.size)
      s.print(encoded_payload)

      if t
        log.puts("OK (execnt=#{execnt})")
      else
        log.puts("timeout err (execnt=#{execnt})")
      end
    end

    Dir.open("."){|d|
      d.each{|e|
        File.unlink(e) if e != '.' && e != '..'
      }
    }

    s.close
  rescue
    s.close
    log.puts($!)
    log.puts($!.backtrace*"\n")
  end
end
