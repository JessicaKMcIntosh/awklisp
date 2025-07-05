# Start a timer when the script starts executing.
# See time_end.awk for the second half.

BEGIN {
    _time_start = systime()
}