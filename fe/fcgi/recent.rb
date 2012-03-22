require 'handler'

class Recent < Handler
  def handle_
    html_header
    title("anarchy golf - recent entries")
    puts %Q(<h1>recent entries</h1><table border="1">
<tr><th>Problem</th><th>Rank</th><th>User</th><th>Lang</th><th>Size</th><th>Score</th><th>Time</th><th>Date</th></tr>
)
    db =get_db('recent')
    db.get('root').each do |pn, un, ext, cs, time, now, rank, score|
      # for removed language
      ft = file_types.index(ext)
      ft = ft ? file_langs[ft] : '???'
      puts %Q(<tr><td><a href="#{problem_url(pn)}">#{pn}</td><td>#{rank}</td><td>#{CGI.escapeHTML(un)}</td><td><a href="#{lang_url(ext)}">#{ft}</a></td><td>#{cs}</td><td>#{score}</td><td>#{"%.4f"%time}</td><td>#{now.strftime('%y/%m/%d %H:%M:%S')}</td></tr>)
    end
    puts %Q(</table>)
    foot
  end
end
