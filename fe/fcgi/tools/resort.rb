require 'pstore'
  def file_types
    ['rb','pl','py','php','scm','l','io','js','lua','tcl',
     'st', 'pro','for','bas',
     'c','cpp','d','ml','hs','adb','m','java','pas','f95','cs','cob',
     'awk','sed','sh',
     'bf','ws','bef', 'di',
     's','out',]
  end
  def file_langs
    ['Ruby','Perl','Python','PHP','Scheme',
     'Common LISP','Io','JavaScript','Lua','Tcl',
     'Smalltalk', 'Prolog','Forth','BASIC',
     'C','C++','D','OCaml','Haskell',
     'Ada','ObjC','Java','Pascal','Fortran','C#','COBOL',
     'AWK','sed','Bash',
     'Brainfuck','Whitespace','Befunge','D-compile-time',
     'gas','x86',]
  end
db = PStore.new('db/problem.db')
root = db.transaction(true) do
  db['root']
end
root.each do |pn|
  ldb = PStore.new("db/#{pn}/_ranks.db")
  ldb.transaction() do
    file_types.zip(file_langs).each do |ext, lang|
        next if !ldb.root?(ext)
        l = ldb[ext]
        l.sort!{|x,y|
          r = x[1]<=>y[1]
          if r != 0
            r
          else
            x[3] <=> y[3]
          end
        }
        ldb[ext] = l
        p l
    end
  end
end
