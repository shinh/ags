require 'handler'

class Lranking < Handler
  def handle_
    html_header
    title("anarchy golf - Language Ranking")

    puts tag('h1', "Language Ranking")
    puts tag('p', 'The score is the sum of 10000 * min(sizes of all solutions) / min(sizes of solutions in a language) for each problems.')

    lrf = 'db/_lranking.db'
    if (!File.exists?(lrf) || File.mtime(lrf) < Time.now-60*60*3)
      lr = {}
      db = PStore.new(lrf)
      db.transaction do
        problem_db.get('root').each do |pn|
          a=[]
          ldb = PStore.new("db/#{pn}/_ranks.db")
          ldb.transaction(true) do
            file_types.zip(file_langs).each do |ext, lang|
              next if !ldb.root?(ext)
              l = ldb[ext]
              lm = 0
              l.each{|x|lm=x[1] if lm==0 || lm>x[1]}
              a << [lm,ext]
            end
          end
          a.sort!
          next if !a[0]
          min = a[0][0]
          a.each do |x|
            lr[x[1]] = [0, 0] if !lr[x[1]]
            if x[0] > 0
              lr[x[1]][0] += (10000 * min / x[0]).to_i
              lr[x[1]][1] += 1
            end
          end
        end

        db['root'] = []
        lr.map.sort{|x,y|y[1][0]<=>x[1][0]}.each do |x,y|
          db['root'] << [x, *y]
        end
      end
    end

    db = PStore.new(lrf)
    db.transaction(true) do
      puts '<table border="1"><tr><th>Rank</th><th>Lang</th><th>Score</th><th>#</th><th>Avg.</th></tr>'
      i = 0
      db['root'].each do |x, y, z|
        puts tr(i+=1, "<a href=#{lang_url(x)}>#{ext2lang(x)}</a>", y, z, y/z)
      end
      print '</table>'

      mt = File.mtime(lrf)
      puts tag('p', "#{ext2lang(db['root'][0][0])} is the programming tool of choice for discriminating golfers.")
      puts tag('p', "#{ext2lang(db['root'][1][0])} is a fine programming tool for many courses.")
      puts tag('p', "Last update: #{mt.getutc} (#{mt})")
    end

    foot
  end
end
