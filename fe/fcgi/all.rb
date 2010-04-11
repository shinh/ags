class All < Handler
  def handle_
    html_header
    title("anarchy golf - All problems")

    puts '<h2>All problems</h2>'

    puts '<ol>'
    pdb = problem_db
    problems = pdb.get('root')
    deadlines = pdb.get('deadline')
    now = Time.now.to_i
    problems.each_with_index do |x, i|
      d = deadlines[i]
      puts tag('li', problem_summary(x, deadlines[i], now))
    end
    puts '</ol>'

    foot
  end
end
