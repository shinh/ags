#!/usr/bin/env ruby

test_cnt = 0
fail_cnt = 0

[
 ['daemon.rb', 'testing', /setsid/],
 ['testing.grb', 'testing', /Success/],
 ['testing.vi', 'testing', /Success/],
 ['testing.groovy', 'testing', /Success/],
 ['testing.r', 'testing', /Success/],
 ['out.class', 'testing', /Success/],
 ['testing.ms', 'testing', /Success/],
 ['google_wait.rb', 'google', /timeout/],
 ['hello_wait.rb', 'hello+world', /Success/],
 ['testing.a+', 'testing', /Success/],
 ['testing.adb', 'testing', /Success/],
 ['testing.awk', 'testing', /Success/],
 ['testing.bas', 'testing', /Success/],
 ['testing.bef', 'testing', /Success/],
 ['testing.bf', 'testing', /Success/],
 ['testing.c', 'testing', /Success/],
 ['testing.cpp', 'testing', /Success/],
 ['testing.cob', 'testing', /Success/],
 ['testing.cpp', 'testing', /Success/],
 ['testing.cs', 'testing', /Success/],
 ['testing.curry', 'testing', /Success/],
 ['testing.d', 'testing', /Success/],
 ['testing.di', 'testing', /Success/],
 ['testing.erl', 'testing', /Success/],
 ['testing.f95', 'testing', /Success/],
 ['testing.for', 'testing', /Success/],
 ['testing.hs', 'testing', /Success/],
 ['testing.ijs', 'testing', /Success/],
 ['testing.io', 'testing', /Success/],
 ['testing.java', 'testing', /Success/],
 ['testing.js', 'testing', /Success/],
 ['testing.l', 'testing', /Success/],
 ['testing.lazy', 'testing', /Success/],
 ['testing.lua', 'testing', /Success/],
 ['testing.m', 'testing', /Success/],
 ['testing.m4', 'testing', /Success/],
 ['testing.mind', 'testing', /Success/],
 ['testing.ml', 'testing', /Success/],
 ['testing.out', 'testing', /Success/],
 ['testing.pas', 'testing', /Success/],
 ['testing.pef', 'testing', /Success/],
 ['testing.php', 'testing', /Success/],
 ['testing.pl', 'testing', /Success/],
 ['testing.pl6', 'testing', /Success/],
 ['testing.pro', 'testing', /Success/],
 ['testing.ps', 'testing', /Success/],
 ['testing.py', 'testing', /Success/],
 ['testing.rb', 'testing', /Success/],
 ['testing.s', 'testing', /Success/],
 ['testing.scm', 'testing', /Success/],
 ['testing.sed', 'testing', /Success/],
 ['testing.sh', 'testing', /Success/],
 ['testing.st', 'testing', /Success/],
 ['testing.tcl', 'testing', /Success/],
 ['testing.unl', 'testing', /Success/],
 ['testing.vhdl', 'testing', /Success/],
 ['testing.wr', 'testing', /Success/],
 ['testing.ws', 'testing', /Success/],
 ['testing.xgawk', 'testing', /Success/],
 ['testing.xtal', 'testing', /Success/],
 ['testing_exec.rb', 'testing', /denied/],
 ['hello.rb', 'hello+world', /Success/],
 ['hello_exec.rb', 'hello+world', /Success/],
 ['hello.ijs', 'hello+world', /Success/],
 ['google.bef', 'google', /Success/],
 ['google.c', 'google', /Success/],
 ['google.d', 'google', /failed/],
 ['google.hs', 'google', /Success/],
 ['google.pl', 'google', /Success/],
 ['google.rb', 'google', /Success/],
 ['google.sed', 'google', /Success/],
 ['fizz.rb', 'FizzBuzz', /Success/],
 ['fizz.c', 'FizzBuzz', /Success/],
 ['fizz.out', 'FizzBuzz', /Success/],
 ['fizz.cs', 'FizzBuzz', /Success/],
 ['fizz.di', 'FizzBuzz', /Success/],
 ['fizz.pl', 'FizzBuzz', /Success/],
 ['fizz.rb', 'FizzBuzz', /Success/],
 ['fizz.sed', 'FizzBuzz', /Success/],
 ['fizz.sh', 'FizzBuzz', /Success/],
 ['fizz_exec.c', 'FizzBuzz', /exec is denied/],
 ['fizz_fail.c', 'FizzBuzz', /failed/],
 ['fizz_exec.l', 'FizzBuzz', /exec is denied/],
 ['fizz_fail.l', 'FizzBuzz', /failed/],
 ['fizz_exec.cs', 'FizzBuzz', /exec is denied/],
 ['fizz_fail.cs', 'FizzBuzz', /failed/],
 ['fizz_exec.out', 'FizzBuzz', /exec is denied/],
 ['fizz_exec.ijs', 'FizzBuzz', /exec is denied/],
 ['mk_hello.rb', 'hello+world', /failed/],
 ['load_hello.rb', 'hello+world', /failed/],
 ['cc.sh', 'Evil+C+Compiler', /Success/],
 # TODO: more message?
 ['fork_bomb.sh', 'testing', /failed/],
 ['timeout.rb', 'Timeout', /Success/],
 ['timeout_fail.rb', 'Timeout', /Not timeout/],
].each do |s, u, r|
  test_cnt += 1

  print "Testing #{s}... "
  c = `./ag.rb t/#{s} http://localhost/p.rb?#{u}`
  #c = `./ag.rb t/#{s} http://golf.shinh.org/p.rb?#{u}`
  if c !~ r
    puts 'failed'
    fail_cnt += 1
  else
    puts 'success'
  end
  File.open("log/#{s}.log", 'w') do |of|
    of.print(c)
  end
end

if fail_cnt == 0
  puts 'All tests passed!'
else
  puts "%d of %d tests failed" % [fail_cnt, test_cnt]
end

