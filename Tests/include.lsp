; This is a file to test including other files.
; Demonstrates the two different ways to give a file.

; Load the startup file with common definitions.
@include startup

; And the fib.lsp file.
(write '(Including the fib.lsp file))

@INCLUDE "fib.lsp"
