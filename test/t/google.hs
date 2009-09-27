--main=do x<-readLn;putStr$'g':map(\v->'o')[1..x]++"gle"
--main=readLn>>=(\x->putStr$'g':map(\v->'o')[1..x]++"gle")
--main=interact(\x->'g':map(\v->'o')[1..read x]++"gle")
main=interact(\x->'g':replicate(read x)'o'++"gle")
--main=interact(\x->'g':take(read x)['o','o'..]++"gle")
--main=readLn>>=(\x->putStr$'g':replicate x 'o'++"gle")

