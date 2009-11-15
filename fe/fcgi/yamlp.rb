require 'handler'
require 'yaml'

class Yamlp < Handler
  def handle_
    text_header
    pn, pa = page
    db = 'db/' + pn + '.db'
    if !File.exist?(db)
      puts 'page not found'
      return
    end
    print YAML.dump(Marshal.load(File.read(db)))
  end
end
