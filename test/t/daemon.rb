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

daemon
sleep
