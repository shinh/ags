DESC=%Q(Implement the cellular automation given by one generation of "rule 30." Strip dead cells (spaces) from beginning and end.

Each new cell is determined by the previous cell in the same spot and its two neighbors:

"###" -> " "
"## " -> " "
"# #" -> " "
"#  " -> "#"
" ##" -> "#"
" # " -> "#"
"  #" -> "#"
"   " -> " "

See <a href="http://mathworld.wolfram.com/Rule30.html">http://mathworld.wolfram.com/Rule30.html</a> for more information.)

DESC=%Q(Implement the cellular automation given by one generation of "rule 30." Strip dead cells (spaces) from beginning and end.

Each new cell is determined by the previous cell in the same spot and its two neighbors:
<pre>"###" -> " "
"## " -> " "
"# #" -> " "
"#  " -> "#"
" ##" -> "#"
" # " -> "#"
"  #" -> "#"
"   " -> " "</pre>
See <a href="http://mathworld.wolfram.com/Rule30.html">http://mathworld.wolfram.com/Rule30.html</a> for more information.)

out = ''
1.upto(0x7f){|i|out << i.chr}

require 'pstore'
db=PStore.new("db/#{ARGV[0]}.db")
db.transaction do
#   puts db['input'].sub!(" \r\n", "\r\n")
#   puts db['output']=out
#   puts db['desc']+='Thanks leonid for suggesting this challenge!'
#   puts db['deadline'] += 4 * 24 * 60 * 60
#  puts db['rejudge'] = 1
  db['desc'] = %Q(See <a href="https://github.com/tric/trick2015/blob/master/ksk_2/remarks.markdown">this description for detail</a>. If there are multiple solutions, output the one which have as many leading positive numbers as possible.

This problem is a test for <a href="rejudge.html">the rejudge feature</a>. Hopefully luck-depend solutions won\'t work anymore, though this proble itself would be exploitable by embeded solutions.)


#   puts db['deadline']+=1100000
#  puts db['desc']=db['desc']+"<br>Though I removed solutions which used file input, some of them are interesting. Now it's post-mortem, please resubmit cheat code!"
#   db['output3']="    *\r\n   ***  *\r\n   *** ***\r\n    *****   *\r\n     ****  ** *\r\n     ***   ***\r\n    ***  ****\r\n    ********\r\n     ****\r\n     ****\r\n     ***\r\n   ooooooo\r\n    ooooo\r\n    ooooo"
#  db['desc'] += '<br> -- shinh.'
#   x=db['output2']
#   puts x.sub!(/b/,'b ')
#   db['output2'] = x
#  db['desc'].sub!(/<br>.*/,'')
#  db['input3']='-Queens -Diamonds'
#  db['desc']+="<br>Thanks for good challenge, pbx. Is the test case 3 of this problem collect? I'm suspecting it lacks Queens. If so, I will fix and expire all submissions for this problem. Anyway I should add edit-problem feature :("
end
