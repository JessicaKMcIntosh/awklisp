; This is a file to test including other files.
; Demonstrates the two different ways to give a file.

; Load the startup.scm file with common definitions.
(load "startup.scm")

; And the fib.lsp file.
(write '(Loading the fib.lsp file))

(load "fib.lsp")
