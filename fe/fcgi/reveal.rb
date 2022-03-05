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
    rejudge = dl == 0 ? 0 : db.get('rejudge').to_i

    #f = "../code/#{q.tr('/','_').sub('_','/')}"
    f = "../code/#{pn}/#{un.gsub('/','%2F')}_#{time}"
    #if q.count('/') == 2
    #  f[f.rindex('/')] = '_'
    #end
    err("invalid query") if !File.file?(f)

    code = File.read(f)

    un = CGI.escapeHTML(un)

    if plain && pm == 1
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

        puts %Q(<p>Note that non-ascii characters in the above source code will be escaped (such as \\x9f).</p>)
        if lang == 'lamb'
#          puts '<p>Disassemble:<pre>'
#          IO.popen("ruby lamd '#{f}'") do |pipe|
#            puts pipe.read
#          end
#          puts '</pre>'
        elsif lang == 'ws'
          puts '<p>Disassemble:<pre>'
          IO.popen("perl wsdis.pl '#{f}'") do |pipe|
            puts pipe.read
          end
          puts '</pre>'
        elsif lang == 'jelly'
          puts '<p>Disassemble:<pre>'
          jelly_code_page = ["\xC2\xA1", "\xC2\xA2", "\xC2\xA3", "\xC2\xA4", "\xC2\xA5", "\xC2\xA6", "\xC2\xA9", "\xC2\xAC", "\xC2\xAE", "\xC2\xB5", "\xC2\xBD", "\xC2\xBF", "\xE2\x82\xAC", "\xC3\x86", "\xC3\x87", "\xC3\x90", "\xC3\x91", "\xC3\x97", "\xC3\x98", "\xC5\x92", "\xC3\x9E", "\xC3\x9F", "\xC3\xA6", "\xC3\xA7", "\xC3\xB0", "\xC4\xB1", "\xC8\xB7", "\xC3\xB1", "\xC3\xB7", "\xC3\xB8", "\xC5\x93", "\xC3\xBE", " ", "!", "\"", "#", "$", "%", "&", "'", "(", ")", "*", "+", ",", "-", ".", "/", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ":", ";", "<", "=", ">", "?", "@", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "[", "\\", "]", "^", "_", "`", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "{", "|", "}", "~", "\xC2\xB6", "\xC2\xB0", "\xC2\xB9", "\xC2\xB2", "\xC2\xB3", "\xE2\x81\xB4", "\xE2\x81\xB5", "\xE2\x81\xB6", "\xE2\x81\xB7", "\xE2\x81\xB8", "\xE2\x81\xB9", "\xE2\x81\xBA", "\xE2\x81\xBB", "\xE2\x81\xBC", "\xE2\x81\xBD", "\xE2\x81\xBE", "\xC6\x81", "\xC6\x87", "\xC6\x8A", "\xC6\x91", "\xC6\x93", "\xC6\x98", "\xE2\xB1\xAE", "\xC6\x9D", "\xC6\xA4", "\xC6\xAC", "\xC6\xB2", "\xC8\xA4", "\xC9\x93", "\xC6\x88", "\xC9\x97", "\xC6\x92", "\xC9\xA0", "\xC9\xA6", "\xC6\x99", "\xC9\xB1", "\xC9\xB2", "\xC6\xA5", "\xCA\xA0", "\xC9\xBC", "\xCA\x82", "\xC6\xAD", "\xCA\x8B", "\xC8\xA5", "\xE1\xBA\xA0", "\xE1\xB8\x84", "\xE1\xB8\x8C", "\xE1\xBA\xB8", "\xE1\xB8\xA4", "\xE1\xBB\x8A", "\xE1\xB8\xB2", "\xE1\xB8\xB6", "\xE1\xB9\x82", "\xE1\xB9\x86", "\xE1\xBB\x8C", "\xE1\xB9\x9A", "\xE1\xB9\xA2", "\xE1\xB9\xAC", "\xE1\xBB\xA4", "\xE1\xB9\xBE", "\xE1\xBA\x88", "\xE1\xBB\xB4", "\xE1\xBA\x92", "\xC8\xA6", "\xE1\xB8\x82", "\xC4\x8A", "\xE1\xB8\x8A", "\xC4\x96", "\xE1\xB8\x9E", "\xC4\xA0", "\xE1\xB8\xA2", "\xC4\xB0", "\xC4\xBF", "\xE1\xB9\x80", "\xE1\xB9\x84", "\xC8\xAE", "\xE1\xB9\x96", "\xE1\xB9\x98", "\xE1\xB9\xA0", "\xE1\xB9\xAA", "\xE1\xBA\x86", "\xE1\xBA\x8A", "\xE1\xBA\x8E", "\xC5\xBB", "\xE1\xBA\xA1", "\xE1\xB8\x85", "\xE1\xB8\x8D", "\xE1\xBA\xB9", "\xE1\xB8\xA5", "\xE1\xBB\x8B", "\xE1\xB8\xB3", "\xE1\xB8\xB7", "\xE1\xB9\x83", "\xE1\xB9\x87", "\xE1\xBB\x8D", "\xE1\xB9\x9B", "\xE1\xB9\xA3", "\xE1\xB9\xAD", "\xC2\xA7", "\xC3\x84", "\xE1\xBA\x89", "\xE1\xBB\xB5", "\xE1\xBA\x93", "\xC8\xA7", "\xE1\xB8\x83", "\xC4\x8B", "\xE1\xB8\x8B", "\xC4\x97", "\xE1\xB8\x9F", "\xC4\xA1", "\xE1\xB8\xA3", "\xC5\x80", "\xE1\xB9\x81", "\xE1\xB9\x85", "\xC8\xAF", "\xE1\xB9\x97", "\xE1\xB9\x99", "\xE1\xB9\xA1", "\xE1\xB9\xAB", "\xE1\xBA\x87", "\xE1\xBA\x8B", "\xE1\xBA\x8F", "\xC5\xBC", "\xC2\xAB", "\xC2\xBB", "\xE2\x80\x98", "\xE2\x80\x99", "\xE2\x80\x9C", "\xE2\x80\x9D"]
          puts code.bytes.map{|c|jelly_code_page[c]}.join
          puts '</pre>'
        elsif lang == 'z8b'
          puts '<p>Disassemble:<pre>'
          IO.popen("/usr/bin/z80dasm -a -t -g 0 '#{f}'") do |pipe|
            3.times{pipe.gets}
            puts pipe.read.upcase
          end
          puts '</pre>'
        elsif lang == 'nbb'
          require 'tempfile'
          tmp = Tempfile.new(["nibbles",".nbb"])
          tmp.write(code)
          tmp.close

          puts '<p>Disassemble:<pre>'
          IO.popen("./nibbles -e '#{tmp.path}'") do |pipe|
            puts pipe.read
          end
          puts '</pre>'
          url = "http://www.tailsteam.com/cgi-bin/nbbdag/commenter.pl?#{query}"
          puts %Q(<p><a href="#{url}">Disassemble it</a> with <a href="http://www.tailsteam.com/cgi-bin/nbbdag/index.pl">Nibbles Commenter</a>)
        elsif lang == 'out'
          puts '<p>Disassemble:<pre>'
          IO.popen("objdump -D -b binary -m i386 '#{f}'") do |pipe|
            5.times{pipe.gets}
            puts pipe.read
          end
          puts '</pre>'
#          puts '<p>ELF info:<pre>'
#          IO.popen("readelf -h '#{f}'") do |pipe|
#            puts pipe.read
#          end
#          puts '</pre>'
        elsif lang == 'gs2'
          url = "http://www.tailsteam.com/cgi-bin/gs2dag/disas.pl?#{query}"
          puts %Q(<p><a href="#{url}">Disassemble it</a> with <a href="http://www.tailsteam.com/cgi-bin/gs2dag/index.pl">gs2 Decompiler</a>)
        end
      end

      if rejudge == 1
        puts %Q(
<form action="rejudge.rb" method="POST">To protect the system from spam, please input your favorite sport (hint: I believe its name must start with 'g', case insensitive)
<input name="sport"><input type="submit" value="rejudge">
<input type="hidden" name="pn" value="#{CGI.escapeHTML(pn)}">
<input type="hidden" name="un" value="#{CGI.escapeHTML(un)}">
<input type="hidden" name="lang" value="#{lang}">
<input type="hidden" name="time" value="#{time}">
</form>)
      end

      puts %Q(<p><a href="/reveal.rb?#{query}/plain">download</a></p>)

      foot
    end
  end
end
