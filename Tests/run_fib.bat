@ECHO OFF
gawk -v quiet=1 -f Tests/time_begin.awk -f awklisp -f Tests/time_end.awk Tests/big_fib.lsp