(defun iota (a m n)
  (if (< m n)
      a
    (iota (cons m a) (- m 1) n)))

(defun fizzbuzz (n)
  (mapcar #'(lambda (i)
          (cond ((zerop (mod i 15)) "FizzBuzz")
            ((zerop (mod i 5)) "Buzz")
            ((zerop (mod i 3)) "Fizz")
            (t i)))
      (iota '() n 1)))

(loop for s in (fizzbuzz 100) do
      (format t "~A~%" s))
