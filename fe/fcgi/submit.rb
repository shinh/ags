require 'handler'
require 'fileutils'

# multipart handling is from cgi.rb

class Submit < Handler
  #@@serv = '192.168.35.2'
  @@serv = '192.168.11.13'
  @@port = 9999

  @@eol = "\r\n"

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

  def add_record(pn, un, ext, cs, time, code, dl)
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
          File.open("../code/#{pn}_#{un}_#{now.to_i}", 'w') do |o|
            o.print(code)
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

    if should_add
      r = [pn, un, ext, cs, time, now, rank, 10000*max/cs]
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
      fb = q.code.read
      fn = 'test.' + q.ext.read
    end

    err("empty file") if fn == '' || fb == ''
    fn = $`+'a+' if fn =~ /a $/

    ext = File.extname(fn).tr('.','')
    exts = file_types
    err("unsupported suffix (#{ext})") if !exts.include?(ext)
    err('not ELF binary') if ext=='out' && (fb.size<3||fb[0,4]!="\x7fELF")

    db = get_db(pn)
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

    sending_code = fb

    s = nil
    begin
      s = TCPSocket.open(@@serv, @@port)
    rescue
      puts %Q(now maintenance? it will be back soon. please try again later.)
      raise $!
    end

    modified_inputs = inputs.map do |input|
      if ext == 'sed' && (!input || input.size == 0)
        input = "\n"
      end
      if input
        #if ext == 'js' && input[-1] != 10
        #  input += "\n"
        #end
        input.gsub!("\r\n","\n")
      else
        input = ''
      end
      input
    end

    payload = {
      :filename => fn,
      :code => sending_code,
      :inputs => modified_inputs,
    }
    encoded_payload = Marshal.dump(payload)
    s.puts(encoded_payload.size)
    s.print(encoded_payload)
    s.close_write

#     s.puts(fn)
#     s.puts(sending_code.size)
#     s.print(sending_code)
#     s.puts(inputs.size)
#     inputs.each do |input|
# #      if (!input || input.size == 0)
#       if ext == 'sed' && (!input || input.size == 0)
#         input = "\n"
#       end
#       if input
#         if ext == 'js' && input[-1] != 10
#           input+="\n"
#         end
#         input.gsub!("\r\n","\n")
#         s.puts(input.size)
#         s.print(input)
#       else
#         s.puts(0)
#       end
#       s.puts(dexec)
#     end
#     s.close_write

    title("#{pn} - result")
    puts tag('h1',"#{pn} - result")

    start_buffering

    failed = false
    t = 0
    all_time = 0.0
    outputs.each do |output|
      time = s.gets
      if !time
        break
      end

      puts tag('h2', "test ##{t+=1}")
	  if pn == 'Timeout'
	    if (time.chomp == 'timeout')
	      time = "3"
	    else
		  time = 'Not timeout'
		end
	  end
      if (time !~ /\d/)
        failed = true
        puts tag('p', time)
		s.gets
		s.gets
        os = s.gets.to_i
        o = s.read(os)
        es = s.gets.to_i
        e = s.read(es)

        puts %Q(<p>your output:
<pre>#{output_filter(o)}</pre>
<p>stderr:
<pre>#{CGI.escapeHTML(e.to_s)}</pre>
)
      else
        all_time += time.to_f
        status = s.gets
        execnt = s.gets.to_i
        os = s.gets.to_i
        o = s.read(os)
        es = s.gets.to_i
        e = s.read(es)

        if pn == 'Quine'
          output = fb
        elsif pn == 'Palindromic Quine'
          output = fb
        elsif pn == 'Timeout'
          output = o
        else
          output = output.gsub("\r\n","\n").rstrip
          o = o.gsub("\r\n","\n").rstrip
        end

#        if (o.rstrip.gsub("\r\n","\n") == output.rstrip.gsub("\r\n","\n"))
        if ((execnt > 2 && dexec > 0 && ext != 'sh' && ext != 'di') &&
            (ext != 'erl') && (ext != 'pef') &&
            (ext != 'ijs' || execnt > 4) &&
            (ext != 'cy' || execnt > 4) &&
            (ext != 'vhdl' || execnt > 3) &&
            (ext != 'out' || execnt > 3) &&
            (ext != 'vi' || execnt > 8) &&
            (ext != 'l' || execnt > 3) &&
            (ext != 'r' || execnt > 7) &&
            (ext != 'lmn' || execnt > 6) &&
            (ext != 'java' || execnt > 4) &&
            (ext != 'class' || execnt > 5) &&
            (ext != 'com' || execnt > 19) &&
            (ext != 'groovy' || execnt > 3))
          puts tag('p', "exec is denied! (#{execnt})")
          failed = true
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
          if ok
            puts tag('p', 'success!')
          else
            failed = true
            puts tag('p', 'failed!')
          end
        end
        puts %Q(<p>
size: #{fb.size}<br>
time: #{time}sec<br>
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
    end
    s.close

    s = end_buffering

    if failed || all_time == 0.0
      puts '<p>Failed!</p>'
    else
      puts '<p>Success!'
      if add_record(pn, un, ext, fb.size, all_time, fb, dl)
        puts "And it's new record!"
      end
      puts '</p>'
    end

    puts s

    foot
  end

  def read_multipart(boundary, content_length)
    params = Hash.new([])
    boundary = "--" + boundary
    quoted_boundary = Regexp.quote(boundary, "n")
    buf = ""
    bufsize = 10 * 1024

    # start multipart/form-data
    @i.binmode if defined? @i.binmode
    boundary_size = boundary.size + @@eol.size
    content_length -= boundary_size
    status = @i.read(boundary_size)
    if nil == status
      raise EOFError, "no content body"
    elsif boundary + @@eol != status
      raise EOFError, "bad content body"
    end

    loop do
      head = nil
      if 10240 < content_length
        require "tempfile"
        body = Tempfile.new("CGI")
      else
        begin
          require "stringio"
          body = StringIO.new
        rescue LoadError
          require "tempfile"
          body = Tempfile.new("CGI")
        end
      end
      body.binmode if defined? body.binmode

      until head and /#{quoted_boundary}(?:#{@@eol}|--)/n.match(buf)

          if (not head) and /#{@@eol}#{@@eol}/n.match(buf)
              buf = buf.sub(/\A((?:.|\n)*?#{@@eol})#{@@eol}/n) do
            head = $1.dup
            ""
          end
            next
          end

        if head and ( (@@eol + boundary + @@eol).size < buf.size )
          body.print buf[0 ... (buf.size - (@@eol + boundary + @@eol).size)]
          buf[0 ... (buf.size - (@@eol + boundary + @@eol).size)] = ""
        end

        c = if bufsize < content_length
              @i.read(bufsize)
            else
              @i.read(content_length)
            end
        if c.nil? || c.empty?
          raise EOFError, "bad content body"
        end
        buf.concat(c)
        content_length -= c.size
      end

      buf = buf.sub(/\A((?:.|\n)*?)(?:[\r\n]{1,2})?#{quoted_boundary}([\r\n]{1,2}|--)/n) do
        body.print $1
        if "--" == $2
          content_length = -1
        end
        ""
      end

      body.rewind

      /Content-Disposition:.* filename="?([^\";]*)"?/ni.match(head)
      filename = ($1 or "")
      if /Mac/ni.match(@e['HTTP_USER_AGENT']) and
          /Mozilla/ni.match(@e['HTTP_USER_AGENT']) and
          (not /MSIE/ni.match(@e['HTTP_USER_AGENT']))
        filename = CGI::unescape(filename)
      end

      /Content-Type: (.*)/ni.match(head)
      content_type = ($1 or "")

      (class << body; self; end).class_eval do
        alias local_path path
        define_method(:original_filename) {filename.dup.taint}
        define_method(:content_type) {content_type.dup.taint}
      end

      /Content-Disposition:.* name="?([^\";]*)"?/ni.match(head)
      name = $1.dup

      if params.has_key?(name)
        params[name].push(body)
      else
        params[name] = [body]
      end
      break if buf.size == 0
      break if content_length === -1
    end

    params
  end # read_multipart
end

