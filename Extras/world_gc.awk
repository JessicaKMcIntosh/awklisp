# Runs the garbage collector then prints out everything that is
# either marked or not marked, depending on whatis requested.

# Usage:
# Include this file on the command line: -f Extras\world_gc.awk
# Set the variables for the gc data you want to see. See the table below.
# Type       | Variable
# -----------+---------------------
# Both       | -v gc_both=1
# Marked     | -v gc_marked=1
# Unmarked   | -v gc_unmarked=1

# Example:
# gawk -f awklisp -f Extras\world_gc.awk startup

END {
    # Take from Modules/type.awk for displaying types.
    world_gc_type_name[a_number] = "number"
    world_gc_type_name[a_pair]   = "pair"
    world_gc_type_name[a_string] = "string"
    world_gc_type_name[a_symbol] = "symbol"

    # Make Lint happy, well, happier...
    world_gc_show_both = (gc_both == 1) ? 1 : 0
    world_gc_show_marked = (gc_marked == 1) ? 1 : 0
    world_gc_show_unmarked = (gc_unmarked == 1) ? 1 : 0

    print ""
    print "Running the Garbage Collector..."
    gc_mark()

    printf("\n\nGC Data: ")
    if ((world_gc_show_both == 1) || ((world_gc_show_marked == 1) && (world_gc_show_unmarked == 1))) {
        world_gc_show_both = 1;
        show_marked = show_unmarked = 1
        printf "Both Marked and Unmarked."
    } else if (world_gc_show_marked == 1) {
        print "Marked"
    } else if (world_gc_show_unmarked == 1) {
        print "UmMarked"
    } else {
        print "Neither?"
    }

    world_gc_pairs()
    world_gc_values()
}

# Convert an expression to a string depending on the type.
function world_gc_to_string (expr) {
    if (!(expr in printname))
        return ""
    if (is_string(expr))
        return sprintf("\"%s\"", printname[expr])
    return printname[expr]
}

function world_gc_pairs(expr, rows) {
    print "Pairs:"
    rows = 0
    for (expr in car) {
        if (world_gc_show_unmarked && (expr in marks))
            continue
        if (world_gc_show_marked && !(expr in marks))
            continue
        if ((rows++ % 20) == 0)
            print "Pair ID CAR: Name      ID Type     CDR: Name      ID Type     Marked"
        printf("%7d %-12s %4d %-8s %-12s %4d %-8s %-3s",
                expr,
                world_gc_to_string(car[expr]),
                car[expr],
                world_gc_type_name[car[expr] % 4],
                world_gc_to_string(cdr[expr]),
                cdr[expr],
                world_gc_type_name[cdr[expr] % 4],
                (expr in marks) ? "Yes" : "No")
        print ""
    }
    print ""
}

function world_gc_values(    expr, type, temp, rows) {
    print "Values:"
    rows = 0
    for (expr in value) {
        if ((rows++ % 20) == 0)
            print "Symbol             ID Value: Name              ID Type     CAR: Name      ID Type     CDR: Name      ID Type     Marked"
        type = world_gc_type_name[value[expr] % 4]
        temp = value[expr]
        printf("%-16s %4d %-22s %4d %-8s",
                world_gc_to_string(expr),
                expr,
                world_gc_to_string(temp),
                temp,
                type)
        if (type == "pair")
            printf(" %-12s %4d %-8s %-12s %4d %-8s",
                    world_gc_to_string(car[temp]),
                    car[temp],
                    world_gc_type_name[car[temp] % 4],
                    world_gc_to_string(cdr[temp]),
                    cdr[temp],
                    world_gc_type_name[cdr[temp] % 4])
        else
            printf("%54s", "")
        printf(" %-3s", (expr in marks) ? "Yes" : "No")
        print ""
    }
    print ""
}
