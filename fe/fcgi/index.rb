require 'handler'

class Index < Handler
  def handle_
    html_header
    title("anarchy golf")

    puts %Q(<h1>Under construction</h1>
<p>
This is a test of golf server.
You can enjoy short coding here in several languages (#{file_types.size} languages).
The purpose of this server is not serious competition.
Joke problems are welcomed and
you can speak freely about problems and can release spoilers.
For serious competition with ranking,
enter <a href="http://codegolf.com/">Code Golf</a>.
</p>
<p>
IRC channel for this golf server: #anagol in freenode. Please feel free to join the channel to talk about various things around golf.
</p>
<p>
Mark Byers kindly prepared a <a href="http://sites.google.com/site/codegolfingtips/Home">site</a> for this golf server. If you would like to join to add tips, please ask Mark to add you as a collaborator (supposedly, in IRC?).
</p>
<p>
I've just understood how to create too short entries (thanks for nazo). However, it seems not to be easy to fix the bug. I'll work on the problem in near future and I'll remove entries which is considered to use the bug. Thanks for understanding.
</p>
)

    if @e['SERVER_NAME'] != 'golf.shinh.org'
      puts %Q(This URI will be deprecated. Please use new URI: <a href="http://golf.shinh.org/">http://golf.shinh.org/</a>)
    end

    pdb = problem_db
    problems = pdb.get('root')
    deadlines = pdb.get('deadline')
    active_problems = []
    hot_post_mortems = []
    now = Time.now.to_i
    problems.zip(deadlines, [*1..deadlines.size]).each do |p, d, i|
      if d && d > now
        active_problems << [d, p, i]
      elsif d && d < now && d > now - 60 * 60 * 24 * 14
        hot_post_mortems << [d, p, i]
      end
    end

    if !active_problems.empty?
      puts '<h2>Active problems</h2><ul>'
      active_problems.sort_by{|d,x,i|[d,i,x]}.each do |d, x, i|
        puts tag('li',
                 "#{i}. " + a(problem_url(x), x) +
                 " #{time_diff(d-now)} left (#{Time.at(d).strftime('%m/%d %H:%M:%S JST')})")
      end
      puts '</ul>'
    end

    if !hot_post_mortems.empty?
      puts '<h2>Hot post mortems</h2><ul>'
      hot_post_mortems.sort_by{|d,x,i|-d}.each do |d, x, i|
        puts tag('li',
                 "#{i}. " + a(problem_url(x), x) +
                 " #{time_diff(now-d)} before")
      end
      puts '</ul>'
    end

    puts '<h2>All problems</h2>'

    puts '<ol>'
    problems.each do |x|
      puts tag('li', a(problem_url(x), x))
    end
    puts '</ol>'

    puts a("mkprob.html", "create new problem")
    puts '<br>'
    puts a("recent.rb", "recent records")
    puts '<br>'
    puts a("lranking.rb", "language ranking")
    puts '<br>'
    puts a("checker.html", "performance checker")
    puts '<br>'
    puts a("caddy.tgz", "caddy, a testing/squeezing/submission helper tool for golfers")
    puts '<br>'

    puts %Q(
<p>
News
<ul>
<li>added <a href="http://maxima.sourceforge.net/">Maxima</a> (thanks yshl!) and <a href="http://rebol.com/">REBOL</a> (thanks Jos\'h!). I couldn\'t find the best suffixes for them. I couldn\'t find commonly used suffix for Maxima. REBOL\'s "r" was already used by R. If you know better suffixes for them, please let me know.
<li>added <a href="http://www.ueda.info.waseda.ac.jp/lmntal/pukiwiki.php?LMNtal">LMNtal</a>.
<li>I forgot to mention this... There is a twitter account which reports the recent activities: http://twitter.com/mircbot. You may able to use its RSS as well.
<li>updated the interpreter of Universal Lambda. See <a href="http://www.golfscript.com/lam/">the official site</a> for the information how this changed. Also, added disassembled view of Universal Lambda. See <a href="http://golf.shinh.org/reveal.rb?Permutations/irori/1226857691&lamb">this code</a> for example.
<li>added <a href="http://www.golfscript.com/lam/">Universal Lambda</a>. Thanks flagitious!
<li>added <a href="http://www.geocities.jp/takt0_h/cyan/index.html">Cyan</a> (sorry, there seem to be no English docs).
<li>added Nemerle 0.9.3, <a href="http://tph.tuwien.ac.at/~oemer/qcl.html">QCL</a> 0.6.3 with <a href="http://shinh.skr.jp/dat_dir/qcl-0.6.3.patch">this patch</a>, and <a href="http://www.kite-language.org/trac">Kite</a> 1.0b6.
<li>added DOS using dosemu.
<li>now grass interpreter is <a href="http://panathenaia.halfmoon.jp/alang/grass.ml">OCaml version</a>. Thanks YT!
<li>submission size limit (CONTENT_LENGTH) was relaxed from 10k to 20k.
<li>added <a href="http://www.blue.sky.or.jp/grass/">Grass</a>. Now we are using <a href="http://www.blue.sky.or.jp/grass/grass.rb">grass.rb</a>. If you want to use faster implementation, please recommend me better implementations.
<li>ruby 1.8.7.
<li>allow more time for R (you have 2 sec for 3 test cases problems, 2.5 secs for 2 test cases, and 4 secs for 1 test case) since its invocation seems to take more than one second.
<li>updated execution server (Ubuntu edgy => gutsy). Many languages are updated (the detail will be described). Maybe now you can use standard input from /dev/fd/0. As usual :\(, there may be several bugs. Please report me if you find bugs.
<li>made the system allow >65336 bytes outputs (this is the limit of linux pipe) for this <a href="http://golf.shinh.org/p.rb?Print+out+a+lot+_56K+BEWARE_">this challenge</a>. thanks yshl for investigating.
<li>added R (2.3.1). As of this time, I think we cannot use stdin. I'll investigate way to do...
<li>updated version of D (2.010), Io (20080209).
<li>added JVM, <a href="http://groovy.codehaus.org/">Groovy</a>. Unfortunately, Scala was too slow in my attempts (it didn't solve hello world with 12sec timeout). (2008-02-17 added) Sorry, all groovy problem was considered as using exec. I'm not sure, but I've fixed the problem for easy ones.
<li>updated goruby's version using <a href="http://svn.ruby-lang.org/cgi-bin/viewvc.cgi/trunk/golf_prelude.rb?view=markup&pathrev=15046">revision 15046</a>.
<li>released <a href="caddy.tgz">caddy</a>, a helper tool for golfers. You can test your solution, squeeze (remove comments or unnecessary whitespaces) your code, and submit the solution with this tool. Please unpack the package and check README for details. (I fixed a bug of database. Please re-download the package again if your caddy doesn't work correctly)
<li>updated goruby using <a href="http://svn.ruby-lang.org/cgi-bin/viewvc.cgi/trunk/golf_prelude.rb?revision=14809">this version</a>. The most significant change might be the faster method_missing, which is provided by eban and flagitious. Thanks for the great contribution!
<li>added "name grep" to language summary page. This patch is provided by flagitious. Also, fixed binary escape for \\x1a-\\x1f, suggested by Pla. Thanks two guys!
<li>updated golfscript using new version and ruby1.9.
<li>added language summary page. You can access the page from <a href="http://golf.shinh.org/lranking.rb">language ranking</a>. These information will be updated every 10 minutes. Uploaded the newest source code of this server.
<li>added goruby, which is a kind of joke program but is *officially* bundled in ruby-1.9.0-0 package (you can create the binary by &quot;make golf&quot;). I think there are two features: 1. Kernel#h method, which outputs Hello, world! 2. short method names: you can call Kernel#print using &quot;pr&quot;. This feature is implemented by method_missing.
<li>added <a href="http://www.vim.org/">Vim</a> as a language. You should make the buffer match the expected output given by each problem. The buffer is initialized using the standard input of the problem. For example, &quot;ddZZ&quot; can be the 4B solution of &quot;delete first line&quot; challenge.
<li>added <a href="http://www.golfscript.com/golfscript/">GolfScript</a>, a stack oriented esoteric language developped by flagitious. I'm pretty sure this language can be the #1 language of this site. Though the first purpose of this language might be golfing, its computation model is interesting, too. Thanks flagitious for this nice work!
<li>added Z80 as a language. Please check out <a href="http://www.mokehehe.com/z80golf/">the description of the environment made by mokehehe</a>. Thanks mokehehe for suggesting and providing the environment!
<li>according to flagitious's suggestion, I relaxed timeout policy: you have 1 sec for 3 test cases problems, 1.5 secs for 2 test cases, and 3 secs for 1 test case.
<li>deploy new exec filter into all problems. It makes program ~10 times faster. Please tell me if you find some bugs.
<li>thanks all guys for submissions for tesing problem! I fixed A+'s suffix problem according to the <a href="http://golf.shinh.org/p.rb?testing#A+">suggestion</a>.
<li>the <a href="http://www.icfpcontest.org/">ICFP contest</a> is coming soon (July 20th)! I introduce this contest in this site because I think you golfers will enjoy this contest (especially, the contest in the last year contains many golfing challenges!). Join and enjoy the contests (but don't defeat me :) 
<li>add <a href="http://www.bigzaphod.org/whirl/">Whirl</a>.
<li>update version of DMD to 1.015 and fix VHDL's exec denied problem.
<li>add <a href="http://d.hatena.ne.jp/ku-ma-me/20070529/p1">Pefunge</a>.
<li>my email address was changed.
<li>add deadline feature. Authors of problems can select the deadline. After the deadline, the problem state becomes to "post-mortem" and all submitted source codes are opened. If you want to create closed problem, you can select no deadline option.
<li>add <a href="http://www.gnu.org/software/ghostscript/ghostscript.html">Postscript</a>.
<li>add <a href="http://home.vrweb.de/~juergen.kahrs/gawk/XML/">xgawk</a>, <a href="http://www.gnu.org/software/m4/">m4</a>, and update GHC to 6.6 from 6.4.
<li>expire all entries which use file save. I know this bug as mentioned the below, but i have not fixed yet. Please kindly don't submit entries using file save/load.
<li>changed the timeout of Java to 1.5sec (because its stratup is slow).
</ul>
<p>
Please whisper me (shinichiro.hamaji _at_ gmail.com) if you found some problems.
If you meet the following situations, it is the bug.
</p>
<ul>
<li>can access network
<li>can be root
<li>can allocate >50MB memory
<li>meet stupid things
</ul>
</p>
<p>
I know the following things:
<ul>
<li>can load saved files. Basically, the saved files will be removed after executing submitted code. However, you can avoid this check by using system call directly. (I'll remove this bug if I have much spare time...)
</ul>
</p>
<p>
<a href="sag.tgz">Source code</a>.
<a href="langs.html">Version informations</a>.
</p>
)

    foot
  end
end
