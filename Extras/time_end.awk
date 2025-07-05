# Stop a timer when the script finishes executing.
# Prints a report with as much resolution as AWK can manage.
# See time_star.awk for the second half.

END {
    _time_end = systime()

    print strftime("BEGIN: %FT%T%z %s %a %b %d %T %Y %z", _time_start);
    print strftime("END:   %FT%T%z %s %a %b %d %T %Y %z", _time_end);
    printf("Duration: %d seconds\n", (_time_end - _time_start))
}