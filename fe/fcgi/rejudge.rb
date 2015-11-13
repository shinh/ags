#!/usr/bin/env ruby

require './handler'

class Rejudge < Handler
  def rejudge(pn, lang, rank)
    ldb = PStore.new("db/#{pn}/_ranks.db")
    record = ldb.transaction(true) do
      ldb[lang][rank.to_i]
    end
    record_key = "#{record[0]}_#{record[3].to_i}"
    code = File.read("../code/#{pn}/#{record_key}")

    db = PStore.new("db/#{pn}.db")
    title, desc, input, output, i2, o2, i3, o3, dexec, dl =
      db.get('title', 'desc', 'input', 'output',
             'input2', 'output2', 'input3', 'output3', 'dexec', 'deadline')
    dexec = dexec == 'on' ? 1 : dexec.to_i

    inputs = [input]
    outputs = [output]
    if o2 && o2 != ''
      inputs << i2
      outputs << o2
    end
    if o3 && o3 != ''
      inputs << i3
      outputs << o3
    end

    ok = true
    s = execute2("test.#{lang}", code, inputs)
    outputs.each do |output|
      payload = Marshal.load(s.read(s.gets.to_i))
      time = payload[:time]
      status = payload[:status]
      execnt = payload[:execnt]
      o = payload[:stdout]
      e = payload[:stderr]

      output = output.gsub("\r\n","\n").rstrip
      o = o.gsub("\r\n","\n").rstrip
      if o != output
        STDERR.puts "#{record_key}: FAIL"
        ok = false
      else
        STDERR.puts "#{record_key}: OK"
      end
    end

    if !ok
      ldb.transaction do
        STDERR.puts ldb[lang].delete_at(rank)
      end
    end

  end
end

if $0 == __FILE__
  pn, lang, rank = ARGV
  if !pn
    puts "Usage: #$0 <problem-name> [lang] [rank]"
    exit
  end

  lang_ranks = []
  if lang && rank
    lang_ranks = [[lang, rank]]
  else
    ldb = PStore.new("db/#{pn}/_ranks.db")
    ldb.transaction(true) do
      ldb.roots.each do |lang|
        ldb[lang].each_with_index do |rank, i|
          lang_ranks << [lang, i]
        end
      end
    end
  end

  lang_ranks.reverse.each do |lang, rank|
    rejudge = Rejudge.new
    rejudge.rejudge(pn, lang, rank)
  end
end
