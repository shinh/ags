require 'handler'
require 'fileutils'

# multipart handling is from cgi.rb

class Checker < Handler
  @@serv = '192.168.35.2'
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

