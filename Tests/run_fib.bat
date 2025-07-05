@ECHO OFF
gawk -v quiet=1 -f Extras/time_begin.awk -f awklisp -f Extras/time_end.awk Tests/big_fib.lsp