# -*- coding: utf-8 -*-
require 'handler'

class Index < Handler
  def handle_
    html_header
    title("anarchy golf")

    puts %Q(<h1>Anarchy Golf</h1>
<p>
This is a golf server.
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

)

    if @e['SERVER_NAME'] != 'golf.shinh.org'
      puts %Q(This URI will be deprecated. Please use new URI: <a href="http://golf.shinh.org/">http://golf.shinh.org/</a>)
    end

    pdb = problem_db
    problems = pdb.get('root')
    deadlines = pdb.get('deadline')
    active_problems = []
    hot_post_mortems = []
    recent_problems = []
    endless_problems = []
    now = Time.now.to_i
    problems.zip(deadlines, [*1..deadlines.size]).each do |p, d, i|
      if d && d > now
        active_problems << [d, p, i]
      elsif d && d < now && d > now - 60 * 60 * 24 * 14
        hot_post_mortems << [d, p, i]
      #elsif !active_problems.empty?
      #  recent_problems << [d, p, i]
      elsif !d || d == 0
        endless_problems << [d, p, i]
      end
    end

    #while active_problems.size < 3
    #  active_problems.push(endless_problems.pop)
    #end

    if !active_problems.empty?
      puts '<h2>Active problems</h2><ul>'
      active_problems.sort_by{|d,x,i|[d || 2**33,i,x]}.each do |d, x, i|
        time_str = d ? " #{time_diff(d-now)} left (#{Time.at(d).strftime('%m/%d %H:%M:%S JST')})" : " (endless)"
        puts tag('li',
                 "#{i}. " + a(problem_url(x), x) + time_str)
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

    #if !recent_problems.empty?
      puts '<h2>Recent endless problems</h2><ul>'
      endless_problems[-5..-1].each do |d, x, i|
        puts tag('li',
                 "#{i}. " + a(problem_url(x), x))
      end
      puts '</ul>'
    #end

    puts '<h2>Some links</h2>'
    puts a('all.rb', 'The list of all problems')
    puts '<br>'
    puts '<br>'

    #puts '<h2>All problems</h2>'
    #puts '<ol>'
    #problems.each do |x|
    #  puts tag('li', a(problem_url(x), x))
    #end
    #puts '</ol>'

    puts a("mkprob.html", "Create a new problem")
    puts '<br>'
    puts a("recent.rb", "Recent records")
    puts '<br>'
    puts a("lranking.rb", "Language ranking")
    puts '<br>'
    puts a("u.rb", "User ranking")
    puts '<br>'
    puts a("l.rb", "Results by a language")
    puts '<br>'
    puts a("check.rb", "Performance checker")
    puts '<br>'
    puts a("setpid.html", "A tool to change the PID")
    puts '<br>'
    puts a("version.rb", "Version info of languages")
    puts '<br>'
    puts a("http://github.com/shinh/caddy", "caddy, a testing/squeezing/submission helper tool for golfers")
    puts '<br>'

    puts %Q(
<h2>News</h2>
<ul>
<li>2025-03-24: Updated iogii to 0.3 (beta).
<li>2024-12-15: Updated iogii to 0.2 (alpha).
<li>2024-11-08: Added iogii 0.1 (alpha).
<li>2023-12-18: Updated atlas to c0bf5086c114278a86245d07a50ba2419cf440bf and now it can be used for all problems.
<li>2023-04-19: Updated atlas to 24bb12ae3b16658a98fe5d96e0613ea9f4dc829b .
<li>2023-03-22: Updated atlas to b09a9af7846ebe94da8f4f54312662426d44f185 .
<li>2023-03-14: Updated atlas to 6652d4bb26a971aaa81878808c924d04cb36a81c . Previous version was not working. Sorry for the trouble.
<li>2023-03-12: Updated atlas to 28320e7670cebd4b16e4548893b621f0c8340a30 .
<li>2023-01-13: Updated atlas to 35222501f7a9cea45c3e54cdc0e83bee3cc159c4 .
<li>Added <a href="https://github.com/darrenks/atlas">Atlas</a> as alpha release. You can use Atlas only for problems with <a href="http://golf.shinh.org/rejudge.html">the rejudge feature</a> enabled. As per the author of the language, many things will be changed before the language is officially released. Your solutions may be invalid in future and removed from the ranking by rejudge.
<li>Updated <a href="http://golfscript.com/nibbles/">Nibbles</a> to 1.00.
<li>Added <a href="http://golfscript.com/nibbles/">Nibbles</a>.
<li>Added <a href="https://github.com/DennisMitchell/jellylanguage">Jelly</a>.
<li>Updated Go to 1.9.2
<li>Added <a href="https://github.com/m-ender/labyrinth">Labyrinth</a>.
<li>Added <a href="https://github.com/m-ender/hexagony">Hexagony</a>.
<li>Updated rust.
<li>Now you should be able to use $(STDIN) in GNU make. Also shell scripts won't run as "x86" (aka ELF) anymore.
<li>Added Bash again as Bash (builtins). This is the same as the previous Bash, but in problems where exec is denied, you cannot use any external commands.
<li>Added <a href="http://golf.shinh.org/rejudge.html">the experimental rejudge feature</a>.
<li>Added <a href="https://github.com/manastech/crystal/">Crystal</a>.
<li>Problems for Code Festival have been modified several times. Thanks a lot for feedbacks. Especially, mitchs gave me a lot, thanks!
<li>Added four problems for a golfing event called 短縮王 in <a href="http://codefestival.jp/">Code Festival</a>.
<li>Added Ruby 2.
<li>Added <a href="https://esolangs.org/wiki/Fish">&gt;&lt;&gt;</a>.
<li>Updated <a href="https://github.com/nooodl/gs2">gs2</a>.
<li>Added Make.
<li>Updated the interpreter of Perl6 (2015-03-15). Old solutions may stop working but the preious version was way too old.
<li>Updated the interpreter of Aheui, so you should be able to solve problems with inputs now.
<li>Added <a href="http://esolangs.org/wiki/Aheui">Aheui</a>.
<li>Now we pass -s flag to jq. I may remove some entries which don't pass without -s flag anymore.
<li>Added jq.
<li>Wrote <a href="http://shinhoge.blogspot.jp/2014/10/sandbox-of-my-golf-server.html">a document for the sandbox of this server</a>.
<li>Added <a href="https://github.com/nooodl/gs2">gs2</a>.
<li>Added <a href="https://github.com/yshl/MNNBFSL">MNNBFSL</a>.
<li>Added Befunge-98. Thanks Damon for suggestion!
<li>Added Pike-7.6. Thanks hallvabo for the suggestion!
<li>Added Squirrel-3.1 beta and Chapel-1.7.0. Thanks Nova and flagitious for suggestions!
<li>Added Rust 0.6 and upgraded Burlesque. Also upgraded GHC from 7.0.4-6 to 7.4.1-4.
<li>Added Python 3, and upgrade Python 2.5 to 2.7.
<li>Added <a href="http://mroman.ch/burlesque/">Burlesque</a>. Updated J from 601c to 602a.
<li>Updated FerNANDo interpreter from 0.2 to 0.5. Removed <a href="http://golf.shinh.org/p.rb?Empty+program">Empty program</a> as people seem to dislike duplication.
<li>Added CLC-INTERCAL, Icon, SNOBOL, REXX, PARI/GP, gnuplot, and Malbolge (thanks again for KirarinSnow)
<li>Added Euphoria, K, and Piet (thanks joel, twobit, and KirarinSnow, for suggestion).
<li>For PHP golfers: visit <a href="http://www.phpgolf.org/">phpGolf.org</a> for more competitive golf courses!
<li>Now PHP doesn't report E_NOTICE error so you may see less annoying timeouts.
<li>Downgraded python 2.7 => 2.5.5 as 2.7 is not backward compatible with the previous version (2.5.4).
<li>The golf server has migrated to a VPS (http://vps.sakura.ad.jp/).
<pre>
Debian squeeze (with sid packages) => Debian wheezy/sid (with squeeze/lenny)
linux-2.6.26-2 => linux-3.0.0-1
Intel(R) Core(TM)2 CPU T5600 @ 1.83GHz => Intel(R) Core(TM)2 Duo CPU T7700 @ 2.40GHz (2 virtual CPUs)
1GB/256MB => 1GB/256MB (web server / execution server)
</pre>
I've upgraded several languages, and fixed a few broken languages (e.g., com).
You can see which languages were updated by <a href="https://github.com/shinh/ags/commit/457ca23a274aa07db74c479ab25dc4a51cbac9c7">this github commit</a>.
Please let me know if you see some issues.
<li>Added octave and ucblogo. Updated the version of scala (2.8.1) and gauche (0.9.1). Thanks KirarinSnow, gengar68, and m_satyr for these suggestions!
<li>Due to <a href="http://en.wikipedia.org/wiki/2011_Sendai_earthquake_and_tsunami">the big earthquake</a>, we will have planned power outages several times. I think this site may be down occasionally. Sorry for inconvenience. Update: they say the power company is planning not to stop power for my area. So, maybe this site won't be down.
<li>Added scala, finally. Thanks for folks who suggested this language to me.
<li>I've just removed <a href="http://golf.shinh.org/p.rb?Just+random+data">Just random data</a> from the list as it seems this problems is a copy of <a href="http://www.spoj.pl/SHORTEN/problems/MONS/">SPOJ's MONS</a> and people don't like this problem so much. Also, I made <a href="http://golf.shinh.org/p.rb?Yin+Yang">Yin Yang</a> endless because SPOJ also has the same challenge. Please refrain from copying problems from SPOJ.
<li>There were two directories where we can write permanent files and one of this was used in http://golf.shinh.org/p.rb?27c3_Generate+C . I've already fixed the permission of this directory and removed the entries. Thanks 27c3 guys for finding this issue!
<li>I removed <a href="http://golf.shinh.org/p.rb?Sokoban">Sokoban challenge</a> by mistake but it recovered now. Sorry for inconvenience.
<li>Updated the version of Perl6. Now it uses rakudo-star-2010.07.
<li>Added <a href="http://en.wikipedia.org/wiki/Dc_(Unix)">dc</a>. I also added BC_LINE_LENGTH=9999 environment variable for bc so it can solve more problems. Thanks Carlos for these suggestions!
<li>Added <a href="http://esolangs.org/wiki/FlogScript">FlogScript</a> and <a href="http://esolangs.org/wiki/FerNANDo">FerNANDo</a>. Thanks leonid and asiekierka for the suggestions!
<li>Added <a href="http://www.zsh.org/">Zsh</a>, <a href="http://fishshell.org/index.php">fish</a>, and <a href="http://en.wikipedia.org/wiki/Bc_programming_language">bc</a>.
<li>Sorry for confusing, but python entries for Buffalo need to be fixed. Please wait for a while.... Fixed.
<li>Added <a href="http://code.google.com/p/clojure/">Clojure</a>. Though I forgot to mention, I think <a href="http://john.freml.in/codegolf-cheating">this loophole</a> was closed two weeks ago. It seems sometimes you cannot run C# and Nemerle programs due to this fix. Until I fix this issue, please let me know if you notice you cannot run them on this server. Thanks John for finding and reporting this! 2009-01-29
<li>Updated <a href="version.rb">the version info of languages</a>.
<li>Added <a href="u.rb">user ranking</a>, and re-organized this site.
<li>Added <a href="http://lilypond.org/">LilyPond</a>. Thanks KirarinSnow for suggesting this.
<li>Now, you have <a href="http://golf.shinh.org/setpid.html">setpid</a> interface. You can adjust the PID without attacking the server!
<li>The golf server was upgraded. The new system should be faster than before.
<pre>
Ubuntu hardy => Debian squeeze (with sid packages)
linux-2.6.19-4 => linux-2.6.26-2
Mobile Intel(R) Celeron(R) CPU 1.70GHz => Intel(R) Core(TM)2 CPU T5600 @ 1.83GHz
384MB/128MB => 1GB/256MB (web server / execution server)
</pre>
Many languages were upgrade. I'll work on gathering the version information of them. You can see <a href="http://github.com/shinh/ags">the source code of this system</a> in github.
<li>Some submissions were gone due to disk full. I'm sorry about this. Please re-post your code again.
<li>added <a href="http://golang.org/">Go</a>.
<li>Now the execution server removes written files and directories using tmpfs. Please tell me if you can create a file and utilize the file content by another submission. Also, I removed some records in "hello world" problem as I guess they used file creation. If you didn't, please re-submit the code.
<li>created <a href="http://golf.shinh.org/lang_speed.html">a graph which shows the best solutions size and speed</a>, inspired by <a href="http://shootout.alioth.debian.org/u32/shapes.php">Computer Language Benchmarks Game</a>. <a href="http://golf.shinh.org/lang_speed2.html">Another graph</a> whose size is shown by score (10000 * size_of_best_lang / size_of_the_lang).
<li>added <a href="http://arclanguage.com/install">Arc</a>. Thanks flagitious for suggestion and <a href="http://route477.net/d/?date=20090929#p01">yhara</a> for investigating how to run it in this system.
<li>To support OCaml golf competition, OCaml will be in the top of the language lists for a while.
<li>added <a href="http://asymptote.sourceforge.net/">Asymptote</a> (thanks notogawa for suggestion!).
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
</ul>
</p>
<p>
<a href="http://github.com/shinh/ags">Source code</a>.
</p>
<p>
Contact: shinichiro.hamaji _at_ gmail.com .
If you found some bugs or you have some requests (fix problem you submitted, add language XXX, and etc.), please email me.
</p>
)

    foot
  end
end
