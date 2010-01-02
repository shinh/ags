require 'handler'

class P < Handler
  def show_input(i,c)
    puts tag('h2', 'Sample input:'+a("#test#{c}",'_',"test#{c}"))
    puts i == '' ? tag('p', '*NOTHING*') : tag('pre', CGI.escapeHTML(i))
  end

  def show_output(o)
    puts tag('h2', 'Sample output:')
    puts tag('pre', CGI.escapeHTML(o))
  end

  def handle_
    html_header
    pn, pa = page
    if !File.exist?('db/' + pn + '.db')
      puts 'page not found'
      foot
      return
    end

    title("anarchy golf - " + pn)

    puts %Q(
<script>
use_form = function() {
  document.getElementById('file').innerHTML='<select name="ext">#{sorted_langs.map{|x, y|"<option value=\"#{x}\">#{y}</option>"}}</select><br><textarea name="code" rows="20" cols="80"></textarea>';
  return false;
}
</script>
)

    db = get_db(pn)
    t, d, i, o, i2, o2, i3, o3, de, dl =
      db.get('title', 'desc', 'input', 'output',
             'input2', 'output2', 'input3', 'output3', 'dexec', 'deadline')
    de = de == 'on' ? 1 : de.to_i

    dl = dl.to_i
    now = Time.now.to_i
    pm = (dl > 0 && dl < now) ? 1 : 0

    if dl > 0 && pm == 0 && dl - 60*60*24 < now
      if !db.get('announced')
        mircbot("Near deadline: http://golf.shinh.org#{problem_url(t)}")
        db.transaction do
          db['announced'] = true
        end
      end
    end

    puts tag('h1', t)

    puts %Q(<h2>Submit</h2>
<p>
<form action="submit.rb" method="POST" enctype="multipart/form-data">
Your name: <input name="user" value="#{user_name}"><br>
<div id="file">
File: <input type="file" name="file">
<input type="button" onclick="use_form(); 1;" value="use form">
</div>
Open <a href="bas.html">code-statistics</a>: <input type="checkbox" name="reveal"><br>
<input type="submit"><br>
<input type="hidden" name="problem" value="#{pa}">
</form>
</p>
)

    #puts '<p>Language is selected by extension. Supported types are:<br>'
    #puts (file_types.zip(file_langs).map{|x, y|
    #        "#{y}(#{x})"
    #      }*', ')
    #puts '</p>'
    puts '<p>Language is selected by the extension of the file. See <a href="version.rb">the list of supported languages</a> to know the extension of your language.</p>'

    puts tag('h2', 'Problem')
    puts tag('p', d.gsub(/\r\n|\n/,"<br>"))
    puts tag('h2', 'Options')
    if de == 2
      puts %Q(<p>exec is denied (using strict filter)</p>)
    elsif de == 1
      puts %Q(<p>exec is denied</p>)
    end

    if dl > 0
      dl = (dlorig=dl) - now
      if dl > 0
        puts %Q(<p>#{time_diff(dl)} before deadline (#{Time.at(dlorig).strftime('%m/%d %H:%M:%S JST')}), all source codes will be revealed after the deadline</p>)
      else
        puts %Q(<p>now post-mortem time, all source codes will be revealed</p>)
      end
    else
      puts %Q(<p>no deadline, the server will not save your submission</p>)
    end

    show_input(i,1)
    show_output(o)
    if o2 && o2 != ''
      show_input(i2,2) if i2 != ''
      show_output(o2)
    end
    if o3 && o3 != ''
      show_input(i3,3) if i3 != ''
      show_output(o3)
    end

    html, lr = *ranking(pn, nil, pm)
    puts html

    if lr.size > 0
      puts tag('h3', 'Language Ranking'+a("#ranking",'_',"ranking"))
      puts %Q(<table border="1"><tr><th>Rank</th><th>Lang</th><th>User</th><th>Size</th><th>Score</th></tr>)
      i = 0
      lr = lr.sort_by{|x|x[1]}
      min = lr[0][1][0]
      lr.each do |k, v|
        puts %Q(<tr><td>#{i+=1}</td><td>#{ext2lang(k)}</td><td>#{CGI.escapeHTML(v[2])}</td><td>#{v[0]}</td><td>#{10000*min/v[0]}</td></tr>)
      end
      puts %Q(</table>)
    end

    if File.exist?("db/#{pn}/_refer.db")
    puts %Q(<h3>Referer</h3>
<p>Note that, they may contain spoilers.</p>
<ul>)
    rdb = PStore.new("db/#{pn}/_refer.db")
    rdb.transaction(true) do
      rdb.roots.select{|r|rdb[r]}.sort do |a,b|
        rdb[a] <=> rdb[b]
      end.each do |r|
        if !r.index('shinh.org')  # ad-hoc
          puts %Q(<li><a href="#{r}">#{r}</a>)
        end
      end
    end
    puts %Q(</ul>)
    end

    foot
  end

end
