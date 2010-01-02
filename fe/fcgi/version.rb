require 'handler'

class Version < Handler
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
      puts "<dt>#{lang} (#{ext})</dt>"
      puts "<dd>#{m[ext]}</dd>"
    end
    puts "</dl>"

    foot
  end
end
