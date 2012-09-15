require 'handler'

class U < Handler
  class User
    attr_accessor :count, :score, :all_count, :no1_count
    def initialize
      @count = @score = @all_count = @no1_count = 0
    end
  end

  def aggregate(l, dl, um)
    return if l.empty?

    best = l[0][1]

    seen = {}
    l.each do |v|
      if dl > 0 && dl < v[3].to_i
        next
      end

      un = v[0].sub(/\s*\(.*/, '')
      #un = v[0]
      next if seen[un]
      seen[un] = true

      un = CGI.escapeHTML(un)
      um[un] = User.new if !um[un]

      um[un].count += 1
      score = (best * 10000 / v[1]).to_i
      um[un].score += score
      um[un].no1_count += 1 if score == 10000
    end
  end

  def handle_
    html_header
    pn, pa = page

    lang_name = 'Overall'
    if !pa.empty?
      lindex = file_types.index(pa)
      if !lindex
        puts 'page not found'
        foot
        return
      end
      lang_name = file_langs[lindex]
    end

    title("anarchy golf - user ranking: " + lang_name)
    puts "<h1>User ranking</h1>"

    put_by_languages(pa, 'u.rb', [['', 'Overall']])

    puts "<h2>#{lang_name}</h2>"
    puts "<p>The score is the sum of 10000 * &lt;size of best solution&gt; / &lt;size of your solution&gt; for each problems. Only submissions before the deadline are considered if the problem has the deadline. Parentheses after your name will be removed before the aggregation. If you submitted multiple solutions into a problem, the better one will be calculated. (E.g., suppose you submitted as \"shinh (cheat)\" and \"shinh\" and earned 10000 and 8000, respectively. Then, your total score will be added by 10000)"
    puts "<p>This ranking is not fair (especially for new comers). Please don't consider this so seriously, the intention of this ranking is to show how eager you are golfing :)"
    puts "</p>"

    if !$u_ranks
      $u_ranks = {}
    end
    r = $u_ranks[pa]
    nowt = Time.now
    now = nowt.to_i
    if !r || r[0] < now
      um = {}
      problem_db.get('root').each do |p|
        ldb = PStore.new("db/#{p}/_ranks.db")

        dl = get_db(p).get('deadline').to_i

        if pa.empty?
          file_types.each do |_|
            l = ldb.transaction(true) do
              ldb[_]
            end
            if l
              aggregate(l, dl, um)
            end
          end
        else
          l = ldb.transaction(true) do
            ldb[pa]
          end
          if l
            aggregate(l, dl, um)
          end
        end
      end
      $u_ranks[pa] = [now+60*60, um.sort_by{|un, u|-u.score}]
    end

    puts %Q(<table border="1"><tr><th>Rank</th><th>User</th><th>Score</th><th>Entries</th><th>Avg</th><th># of 10000</th></tr>)
    um = $u_ranks[pa][1]
    rank = 0
    um.each do |un, u|
      next if u.count < 2
      avg = u.score / u.count
      puts %Q(<tr><td>#{rank+=1}</td><td>#{un}</td><td>#{u.score}</td><td>#{u.count}</td><td>#{avg}</td><td>#{u.no1_count}</td></tr>)
    end
    puts %Q(</table>)

    lu = Time.at($u_ranks[pa][0])
    puts tag('p', "Last update: #{lu.getutc} (#{lu})")

    foot
  end
end
