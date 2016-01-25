require 'handler'

class Version < Handler
  def strip_script(s)
    s.gsub(/#.*/, '').sub('export LD_PRELOAD=$LD_PRELOAD:/lib/i386-linux-gnu/libSegFault.so', '').gsub(/\n+/, "\n")
  end

  def handle_
    html_header
    title("anarchy golf - Version info of languages")
    puts "<h1>Version info of languages</h1>"

    m = {}
    File.readlines('version.txt').each do |line|
      / / =~ line
      m[$`] = $'
    end

    puts "<dl>"
    sorted_langs.each do |ext, lang|
      puts "<dt>#{lang} (#{ext}): #{m[ext]}</dt>"
      puts "<dd>"
      puts "<p>How your program is executed:"
      ss = strip_script(File.read("../../be/srv/s/#{ext}"))
      if ss =~ /ag_launcher/
        puts %Q((note "ag_launcher" below is <a href="https://github.com/shinh/ags/blob/master/be/srv/ag_launcher.c">this script</a>.))
      end
      puts "<pre>" + ss + "</pre>"
      c = "../../be/srv/s/_#{ext}"
      if File.exist?(c)
        puts "<p>How your program is compiled:"
        puts "<pre>" + strip_script(File.read(c)) + "</pre>"
      end
      puts "</p>"
      puts "</dd>"
    end
    puts "</dl>"

    foot
  end
end
