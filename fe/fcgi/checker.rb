require 'handler'
require 'fileutils'

# multipart handling is from cgi.rb

class Checker < Handler
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

    begin
      fb = q.file.read
      fn = q.file.original_filename[/[^\/\\]+$/]
    rescue
      fb = q.code.read.gsub("\r\n", "\n")
      fn = 'test.' + q.ext.read
    end

    err("empty file") if fn == '' || fb == ''

    ext = File.extname(fn).tr('.','')
    exts = file_types
    err("unsupported suffix (#{ext})") if !exts.include?(ext)
    err('not ELF binary') if ext=='out' && (fb.size<3||fb[1,3]!='ELF')

    input = q.input.read

    s = execute2(fn, fb, [input], true)

    title("checker - result")
    puts tag('h1',"checker - result")

    payload = Marshal.load(s.read(s.gets.to_i))
    time = payload[:time]
    status = payload[:status]
    execnt = payload[:execnt]
    o = payload[:stdout]
    e = payload[:stderr]

    if !time
      time = 'timeout'
    else
      time = time.to_s
    end

    if (time !~ /\d/)
      puts tag('p', time)

      puts %Q(<p>your output:
<pre>#{output_filter(o)}</pre>
<p>stderr:
<pre>#{CGI.escapeHTML(e.to_s)}</pre>
)
    else
      puts %Q(<p>
size: #{fb.size}<br>
time: #{'%.6f' % time}sec<br>
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

if $0 == __FILE__
  c = Checker.new
  s = c.execute2(ARGV[0], ARGV[1], [''], true)

  payload = Marshal.load(s.read(s.gets.to_i))
  time = payload[:time]
  status = payload[:status]
  execnt = payload[:execnt]
  o = payload[:stdout]
  e = payload[:stderr]

  print o
  STDOUT.flush
  STDERR.print e
  exit status
end
