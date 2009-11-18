require 'handler'
require 'fileutils'

# multipart handling is from cgi.rb

class Checker < Handler
  @@serv = '192.168.36.2'
  @@port = 9999

  @@eol = "\r\n"

  def output_filter(s)
    escape_binary(CGI.escapeHTML(s.gsub("\r\n","\n")).gsub("\n",%Q(<span class="gray">\\n\n</span>)))
  end

  def handle_
    html_header

    unless ("POST" == @e['REQUEST_METHOD']) and
        %r|\Amultipart/form-data.*boundary=\"?([^\";,]+)\"?|n.match(@e['CONTENT_TYPE'])
      err('not multipart submission')
    end

    boundary = $1.dup
    @multipart = true
    clen = Integer(@e['CONTENT_LENGTH'])
    err('over 10K') if (clen > 10000)
    q = read_multipart(boundary, clen)

    fb = q.file.read
    fn = q.file.original_filename[/[^\/\\]+$/]

    err("empty file") if fn == '' || fb == ''

    ext = File.extname(fn).tr('.','')
    exts = file_types
    err("unsupported suffix (#{ext})") if !exts.include?(ext)
    err('not ELF binary') if ext=='out' && (fb.size<3||fb[1,3]!='ELF')

    input = q.input.read

    s = nil
    begin
      s = TCPSocket.open(@@serv, @@port)
    rescue
      puts %Q(now maintenance? it will be back soon. please try again later.)
      raise $!
    end
    s.puts(fn)
    s.puts(fb.size)
    s.print(fb)
    s.puts(-1)
    if ext == 'sed' && (!input || input.size == 0)
      input = "\n"
    end
    if input
      if ext == 'js' && input[-1] != 10
        input+="\n"
      end
      input.gsub!("\r\n","\n")
      s.puts(input.size)
      s.print(input)
    else
      s.puts(0)
    end
    s.close_write

    title("checker - result")
    puts tag('h1',"checker - result")

    time = s.gets

    if (time !~ /\d/)
      puts tag('p', time)
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
      status = s.gets
      execnt = s.gets.to_i
      os = s.gets.to_i
      o = s.read(os)
      es = s.gets.to_i
      e = s.read(es)

      puts %Q(<p>
size: #{fb.size}<br>
time: #{time}sec<br>
status: #{status}<br>
</p>
<p>your output:
<pre>#{output_filter(o)}</pre>
)
      puts %Q(<p>stderr:
<pre>#{CGI.escapeHTML(e.to_s)}</pre>
)
    end
    s.close

    foot
  end
end

