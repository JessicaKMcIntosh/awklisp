# This is an addition to make lint happy about uninitialized global variables.

BEGIN {
    heap_increment = 100
    profiling = 0
    quiet = 0
    loud_gc = 0

    # Give these arrays a type since it might not get used.
    delete car
    delete cdr
    delete module_func
    delete modules
    delete printname
    delete property
    delete stack
    delete value

    # Stop the warning: close: `/dev/stderr' is not an open file, pipe or co-process
    printf("") >"/dev/stderr"

}

END {
    # Stop errors for not calling this.
    type_of(0)
}
