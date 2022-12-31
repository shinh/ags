require 'handler'
require 'fileutils'

# multipart handling is from cgi.rb

class Submit < Handler
  def get_statistics(s)
    a=[0,0,0,0]
    an=/[a-zA-Z0-9]/
    ws=/[ \t\n]/
    s.each_byte{|x|
      s=x.chr
      a[an=~s ?2:ws=~s ?1: x<127&&x>32?3:0]+=1
    }
    a
  end

  def add_record(pn, un, ext, cs, time, code, dl, fn)
#    udb = PStore.new("db/#{pn}/#{un}.udb")

    st = get_statistics(code)
    rank = -1
    now = Time.now

    dl = dl.to_i
    pm = (dl > 0 && dl < Time.now.to_i) ? 1 : 0

    should_add = true
    ldb = PStore.new("db/#{pn}/_ranks.db")
    max = -1
    ldb.transaction do
      ldb[ext] = [] if !ldb.root?(ext)
      l = ldb[ext]
      if (v = l.find{|x|x[0] == un})
        if v[1] > cs
          l = l.reject{|x|x[0] == un && x[5].to_i == pm}
        else
          should_add = false
        end
      end

      if (should_add)
        if @op == ''
          st = st[0,1]
        end

        if (dl > 0)
          FileUtils.mkdir_p("../code/#{pn}")
          record_key = "#{un.gsub('/','%2F')}_#{now.to_i}"
          File.open("../code/#{pn}/#{record_key}", 'w') do |o|
            o.print(code)
          end
          File.open("../code/#{pn}/#{record_key}_fn", 'w') do |o|
            o.print(fn)
          end
        end

        l << a = [un, cs, time, now, st, pm]
        l.sort!{|x,y|
          r = x[5].to_i<=>y[5].to_i
          if r != 0
            r
          else
            r = x[1]<=>y[1]
            if r != 0
              r
            else
              x[3] <=> y[3]
            end
          end
        }
        rank = l.index(a) + 1
        max = l[0][1]
        ldb[ext] = l
      end
    end

    if should_add && pn != 'testing'
      r = [pn, un, ext, cs, time, now, rank, (10000*max/cs).to_i]
      rdb = PStore.new('db/recent.db')
      rdb.transaction do
        rdb['root'] = [] if !rdb.root?('root')
        rdb['root'].unshift(r)
        while rdb['root'].size > 100
          rdb['root'].pop
        end
      end
      mircbot(%Q(#{un} submits #{cs}B of #{ext2lang(ext)} for #{pn}, ranking ##{rank} (#{r[7]}pts).))
    end

    should_add
  end

  def output_filter(s)
    escape_binary(CGI.escapeHTML(s.to_s.gsub("\r\n","\n"))).gsub("\n",%Q(<span class="gray">\\n\n</span>))
  end

  def handle_
    #if true
    #  err('Sorry, now under maintenance')
    #end

    unless ("POST" == @e['REQUEST_METHOD']) and
        %r|\Amultipart/form-data.*boundary=\"?([^\";,]+)\"?|n.match(@e['CONTENT_TYPE'])
      err('not multipart submission')
    end

    boundary = $1.dup
    @multipart = true
    clen = Integer(@e['CONTENT_LENGTH'])
    err('over 20k') if (clen > 20000)
    q = read_multipart(boundary, clen)

    pn = q.problem.read.tr('+',' ')
    un = q.user.read
    un.sub!(/\s*;.*/,'')
    un.rstrip!
    @op = q['reveal'].to_s

    html_header({'Set-Cookie'=>"un=#{CGI.escape(un.sub(/\s*\(.*$/,''))}; expires=#{CGI::rfc1123_date(Time.now+60*60*24*365)}; path=/;"})

    begin
      fb = q.file.read
      fn = q.file.original_filename[/[^\/\\]+$/]
    rescue
      fb = q.code.read.gsub("\r\n", "\n")
      fn = 'test.' + q.ext.read
    end

    err("empty file") if fn == '' || fb == ''
    fn = $`+'a+' if fn =~ /a $/

    ext = File.extname(fn).tr('.','')
    exts = file_types
    err("unsupported suffix (#{ext})") if !exts.include?(ext)
    err('not ELF binary') if ext=='out' && (fb.size<3||fb[0,4]!="\x7fELF")

    db = get_db(pn)
    title, desc, input, output, i2, o2, i3, o3, dexec, dl, rejudge =
      db.get('title', 'desc', 'input', 'output',
             'input2', 'output2', 'input3', 'output3', 'dexec', 'deadline', 'rejudge')
    dexec = dexec == 'on' ? 1 : dexec.to_i

    rejudge = dl == 0 ? 0 : rejudge.to_i
    if rejudge != 1 && ext == "atl"
      err("Atlas is in alpha and currently available for problems rejudge feature enabled")
    end

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

    sending_code = fb

    s = execute2(fn, sending_code, inputs)

    title("#{pn} - result")
    puts tag('h1',"#{pn} - result")

    start_buffering

    failed = false
    t = 0
    all_time = 0.0
    outputs.each do |output|
      payload = Marshal.load(s.read(s.gets.to_i))
      time = payload[:time]
      status = payload[:status]
      execnt = payload[:execnt]
      o = payload[:stdout]
      e = payload[:stderr]

      notice = ''
      if !payload[:notice].empty?
        notice += '<p>notice:<ul>'
        payload[:notice].each do |n|
          notice += '<li>' + n
        end
        notice += '</ul>'
      end

      puts tag('h2', "test ##{t+=1}")
      if pn == 'Timeout'
        if time
          time = 'Not timeout'
        else
          time = 3
        end
      end
      if !time
        time = 'timeout'
      end
      if time.class == String
        failed = true
        puts tag('p', time)

        puts %Q(<p>your output:
<pre>#{output_filter(o)}</pre>
<p>stderr:
<pre>#{CGI.escapeHTML(e)}</pre>
#{notice}
)
      else
        all_time += time

        if pn == 'Quine'
          output = fb
        elsif pn == 'Not Quine'
        elsif pn == 'Inverse Quine'
        elsif pn == 'Palindromic Quine'
          output = fb
        elsif pn == 'Timeout'
          output = o
        else
          output = output.gsub("\r\n","\n").rstrip
          o = o.gsub("\r\n","\n").rstrip
        end

#        if (o.rstrip.gsub("\r\n","\n") == output.rstrip.gsub("\r\n","\n"))
        if ((execnt > 2 && dexec > 0 && ext != 'sh' && ext != 'di' && ext != 'zsh' && ext != 'fish') &&
            (ext != 'erl') && (ext != 'pef') &&
            (ext != 'ijs' || execnt > 4) &&
            (ext != 'cy' || execnt > 4) &&
            (ext != 'wake' || execnt > 3) &&
            (ext != 'vhdl' || execnt > 3) &&
            (ext != 'out' || execnt > 4) &&
            (ext != 'vi' || execnt > 8) &&
            (ext != 'l' || execnt > 3) &&
            (ext != 'r' || execnt > 7) &&
            (ext != 'lmn' || execnt > 7) &&
            (ext != 'java' || execnt > 4) &&
            (ext != 'clj' || execnt > 3) &&
            (ext != 'class' || execnt > 5) &&
            (ext != 'com' || execnt > 26) &&
            (ext != 'max' || execnt > 12) &&
            (ext != 'groovy' || execnt > 19) &&
            (ext != 'pl6' || execnt > 3) &&
            (ext != 'mk' || execnt > 3) &&
            (ext != 'scala' || execnt > 6))
          puts tag('p', "exec is denied! (#{execnt})")
          failed = true
        elsif execnt == -1
          puts tag('p', "you called setpriority for cheating?")
          failed =true
        elsif execnt < 2
          puts tag('p', "it seems the execution server is broken. please contact at shinichiro.hamaji  _at_ gmail.com")
          failed =true
        else
          ok = true
          unless (o == output && (pn != 'Quine' || (ext == 'ws' && fb.size > 5) || fb.rstrip != ""))
            ok = false
          end
          if pn == 'Palindromic Quine' && (fb != fb.reverse || fb.size < 2)
            ok = false
          end
          if pn == 'Error'
            ok = e.size > 0
          end
          if ok && pn == 'Whitespaceless Hello world'
            ok = false if fb =~ /[ \t\n]/
          end
          if ok && pn == 'Helloworldless Hello world'
            ok = false if fb =~ /[Hello, world!]/
          end
          if ok && pn == 'Hello transposable world'
            ok = false if fb.chomp != fb.chomp.split("\n").map{|_|_.chars.to_a}.transpose.map{|_|_*""}*"\n"
          end
          if pn == 'Inverse Quine'
            x = [*0..127].map{|_|_.chr} - fb.chars.sort.uniq
            y = o.chars.sort
            ok = x == y
          end
          if pn == 'Not Quine'
            x = fb.chars.to_a
            y = o.chars.to_a
            if x.sort == y.sort && x.zip(y).all?{|x, y|x != y}
              ok = true
            else
              ok = false
            end
          end
          if ok
            puts tag('p', 'success!')
          else
            failed = true
            puts tag('p', 'failed!')
          end
        end
        puts %Q(<p>
size: #{fb.size}<br>
time: #{'%.6f' % time}sec<br>
status: #{status}<br>
</p>
<p>your output:
<pre>#{output_filter(o)}</pre>
)
      if failed
        puts %Q(<p>expected:
<pre>#{output_filter(output)}</pre>
)
      end
      puts %Q(<p>stderr:
<pre>#{CGI.escapeHTML(e.to_s)}</pre>
)
      end
      puts notice
    end
    s.close

    s = end_buffering

    if failed || all_time == 0.0
      puts '<p>Failed!</p>'
    else
      puts '<p>Success!'
      score = fb.size
      if / broken keyboard$/ =~ pn
        score = fb.chars.sort.uniq.size + fb.size * 0.001
      end
      if add_record(pn, un, ext, score, all_time, fb, dl, fn)
        puts "And it's a new record!"
      end
      puts '</p>'
    end

    puts s

    foot
  end
end

