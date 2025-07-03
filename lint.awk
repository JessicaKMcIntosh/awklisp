# This is an addition to make lint happy about uninitialized global variables.

BEGIN {
    heap_increment = 0
    profiling = 0
}
