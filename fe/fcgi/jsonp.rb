require 'handler'
require 'json'

class Jsonp < Handler
  def handle_
    text_header
    pn, pa = page
    db = 'db/' + pn + '.db'
    if !File.exist?(db)
      puts 'page not found'
      return
    end
    print JSON.dump(Marshal.load(File.read(db)))
  end
end
