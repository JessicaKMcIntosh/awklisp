END {
    _time_end = systime()

    print strftime("BEGIN: %FT%T%z %s %a %b %d %T %Y %z", _time_start);
    print strftime("END:   %FT%T%z %s %a %b %d %T %Y %z", _time_end);
    printf("Duration: %d seconds\n", (_time_end - _time_start))
}