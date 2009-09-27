#!/usr/bin/env ruby

require 'stringio'

if __FILE__ == $0
  $A=ARGF
end
ext = File.extname($A.path)
c = $A.read

# if ext == '.bf'
#   c = c.scan(/[\+-\[\]><,\.]/)*''
# end

# if ext == '.ms'
#   $i = StringIO.new(c, 'r')
#   require 'msc'
#   c = $o
#   c.gsub!('-=', '')
#   c.gsub!("\n", '')
# end

# if ext != '.out'
#   c.gsub!(/^ +/,'')
#   c.gsub!(/^(\/\/.*|#(?!!|import|include)|--).*/,'')
#   c.gsub!(/\/\*[^\*]*(\*+[^\/*][^*]*)*\*+\//,'')
#   1 while c.gsub!(/\n\n/,"\n")
#   c.gsub!(";\n",';')
#   c.gsub!("{\n",'{')
#   if ext != '.sed' && ext != '.sh' && ext != '.cs' && ext != '.c' && ext != '.hs'
#     c.gsub!('\n',"\n")
#   end
#   c.strip!
# end
# #c.gsub!(/\n+\Z/,'')
p c.size
File.open("out#{ext}", 'w') do |of|
  of.print(c)
end
