require 'handler'

class Reveal < Handler
  def handle_
    query = @e['QUERY_STRING']
    query.sub!(/&(.*)/,'')
    lang = $1
    q = CGI.unescape(query)
    q.sub!('/plain','')
    plain = $&

    q =~ /^([^\/]*)\/(.*)[\/_](\d+)$/
    pn = $1
    un = $2
    time = $3
    db = get_db(pn)
    dl = db.get('deadline')
    dl = dl.to_i
    pm = (dl > 0 && dl < Time.now.to_i) ? 1 : 0

    #f = "../code/#{q.tr('/','_').sub('_','/')}"
    f = "../code/#{pn}/#{un.gsub('/','%2F')}_#{time}"
    #if q.count('/') == 2
    #  f[f.rindex('/')] = '_'
    #end
    err("invalid query") if !File.file?(f)

    code = File.read(f)

    un = CGI.escapeHTML(un)

    if plain
      text_header
      print code
    else
      html_header

      title("anarchy golf - the source code")

      plink = %Q(<a href="#{problem_url(pn)}">#{pn}</a>)
      puts tag('h2', plink + " by " + un)

      if pm == 0
        puts %Q(not opened yet)
      else
        puts %Q(<pre>#{escape_binary(CGI.escapeHTML(code))}</pre>)
      end

      puts %Q(<p>Note that non-ascii characters in the above source code will be escaped (such as \\x9f).</p>)
      if lang == 'lamb'
#        puts '<p>Disassemble:<pre>'
#        IO.popen("ruby lamd '#{f}'") do |pipe|
#          puts pipe.read
#        end
#        puts '</pre>'
      elsif lang == 'ws'
        puts '<p>Disassemble:<pre>'
        IO.popen("perl wsdis.pl '#{f}'") do |pipe|
          puts pipe.read
        end
        puts '</pre>'
      elsif lang == 'z8b'
        puts '<p>Disassemble:<pre>'
        IO.popen("/usr/bin/z80dasm -a -t -g 0 '#{f}'") do |pipe|
          3.times{pipe.gets}
          puts pipe.read.upcase
        end
        puts '</pre>'
      elsif lang == 'out'
        puts '<p>Disassemble:<pre>'
        IO.popen("objdump -D -b binary -m i386 '#{f}'") do |pipe|
          5.times{pipe.gets}
          puts pipe.read
        end
        puts '</pre>'
#        puts '<p>ELF info:<pre>'
#        IO.popen("readelf -h '#{f}'") do |pipe|
#          puts pipe.read
#        end
#        puts '</pre>'
      end

      puts %Q(<p><a href="/reveal.rb?#{query}/plain">download</a></p>)

      foot
    end
  end
end
