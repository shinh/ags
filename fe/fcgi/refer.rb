require 'handler'

class Refer < Handler
  def handle_
    html_header
    title("anarchy golf - refer")

    h = Hash.new{0}
    `tail -3000 /var/log/lighttpd/access.log`.scan(/"(http:[^"]+)/) do
#    File.read('/var/log/lighttpd/access.log').scan(/"(http:[^"]+)/) do
      k = $1
      next if k=~/shinh.org/
      next if k=~/localhost/
      h[k]+=1
    end
    puts '<ul>'
    h.sort{|x,y|y[1]<=>x[1]}.each do |k, v|
      puts %Q(<li><a href="#{k}">#{k}</a> (#{v}))
    end
    puts '</ul>'

    foot
  end
end
