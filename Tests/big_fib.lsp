; Take from "fib.lsp".
(define fib
  (lambda (n)
    (if (< n 2)
        1
        (+ (fib (- n 1))
           (fib (- n 2))))))

; Taken from "startup".
(define for-each
  (lambda (proc lst)
    (while lst
      (proc (car lst))
      (set! lst (cdr lst)))))

; Taken from "eliza.lsp".
(define say
  (lambda (sentence)
    (for-each write sentence)
    (newline)))

(say '(This will take a while))
(write (fib 35))
(newline)
