require 'handler'

class Marshalp < Handler
  def handle_
    text_header
    pn, pa = page
    db = 'db/' + pn + '.db'
    if !File.exist?(db)
      puts 'page not found'
      return
    end
    print File.read(db)
  end
end
