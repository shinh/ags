require 'handler'
require 'fileutils'

class Mkprob < Handler
  def handle_
#    if (!develop?)
#      raise 'now mkprob.rb is updating'
#    end

    q = query

    if q.sport.to_s.downcase != 'golf'
      raise 'Your access was denied. Please mail me if you don\'t know the name of your favorite sport.'
    end

    t = q.title
    err('title is empty') if t == ''
    err('description is empty') if q.desc == ''
    err('output is empty') if q.output == ''
    err('deadline is empty') if q.deadline == ''
    err('invalid title (use [a-zA-Z0-9_ ])') if t !~ /^[a-zA-Z0-9_ ]+$/

    d = q.deadline.to_i
    deadline = d > 0 ? (Time.now+q.deadline.to_i*60*60).to_i : 0
    if q.deadline == 'kaigi'
      deadline = 1213956000
    end
    q['deadline'] = deadline

    db = 'db/' + t
    err('already exists') if File.exists?(db)
    FileUtils.mkdir db
    store(t, q)

    pdb = problem_db
    pdb.transaction do
      pdb['root'] = [] if !pdb.root?('root')
      pdb['root'] << t
      pdb['deadline'] << deadline
    end

    mircbot("New problem: http://golf.shinh.org#{problem_url(t)}")

    redirect("/")
  end
end

