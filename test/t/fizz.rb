1.upto(?d){|n|puts ["Fizz#{s=[:Buzz][n%5]}"][n%3]||s||n}
#1.upto(?d){|n|s=[:Buzz][n%5];puts n%3<1?"Fizz#{s}":s||n}

#1.upto(?d){|n|n%3<1&&s="Fizz";puts n%5<1?"#{s}Buzz":s||n}
#1.upto(?d){|n|s=[:Fizz][n%3];puts n%5<1?"#{s}Buzz":s||n}
#1.upto(?d){|i|puts"#{b=[:Fizz][i%3]}#{i%5<1?:Buzz:b ?$9:i}"}

#?d.times{|i|puts"#{b=i%3>1?:Fizz:$9}#{i%5>3?:Buzz:b ?$9:i+1}"}
#1.upto(?d){|i|$><<(b=[:Fizz][i%3])<<(i%5<1?:Buzz:b ?$9:i)<<$/}

#1.upto(?d){|i|puts"#{b=i%3<1?:Fizz:$9}#{i%5<1?:Buzz:b ?$9:i}"}
#1.upto(?d){|i|puts"#{:Fizz if b=i%3<1}#{i%5<1?:Buzz:b ?'':i}"}
#1.upto(?d){|i|s="#{:Fizz if i%3<1}#{:Buzz if i%5<1}";puts s[0]?s:i}

#1.upto(?d){|i|puts i%3<1?i%5<1?:FizzBuzz: :Fizz:i%5<1?:Buzz:i}
#1.upto(?d){|i|s="Fizz"[i%3*4,4]+"Buzz"[i%5*4,4];puts s ?s:i}

#1.upto(?d){|i|s=0;l=0;i%5<1&&l

#  3 => 0,1
#  5 => 1,1
# 15 => 0,2



#a=[*1..?d]
#1.upto(33){|i|a[3*i-1]="Fizz"}
#1.upto(20){|i|a[v=5*i-1].to_i<1?a[v]+="Buzz":a[v]="Buzz"}
#puts a
