# Dump out various bits of memory.
# These output a LOT of text!

# Usage:
# Include this file on the command line: -f Extras\world_dump.awk
# Set the variables for the memory you want dumped. See the table below.

# Since each of these outputs so much text you must ask for each one individually.
# Set the following variables on the command line to get the area dumped.
# Area       | Variable
# -----------+---------------------
# Everything | -v dump_all
# Names      | -v dump_names=1
# Pairs      | -v dump_pairs=1
# Properties | -v dump_props=1
# Protected  | -v dump_protected=1
# Stack      | -v dump_stack=1
# Values     | -v dump_values=1

# For example, do dump everything:
# gawk -f awklisp -f Extras\world_dump.awk -v dump_all=1 startup

END {
    printf("\n\nDumping Memory:\n")
    if (dump_names     || dump_all) memory_dump_names()
    if (dump_pairs     || dump_all) memory_dump_pairs()
    if (dump_props     || dump_all) memory_dump_properties()
    if (dump_protected || dump_all) memory_dump_protected()
    if (dump_stack     || dump_all) memory_dump_stack()
    if (dump_values    || dump_all) memory_dump_values()
}

function memory_dump_names(    expr, type, temp, rows) {
    print "Print Names:"
    for (expr in printname) {
        printf("%5d %s\n",
                expr,
                printname[expr])
    }
    print ""
}

function memory_dump_pairs(    expr, rows) {
    print "Pairs:"
    rows = 0
    for (expr in car) {
        if ((rows++ % 20) == 0)
            print "Pair ID CAR: Name      ID Type     CDR: Name      ID Type"

        printf("%7d %-12s %4d %-8s %-12s %4d %-8s",
                expr,
                (car[expr] in printname ? printname[car[expr]] : ""),
                car[expr],
                type_of(car[expr]),
                (cdr[expr] in printname ? printname[cdr[expr]] : ""),
                cdr[expr],
                type_of(cdr[expr]))
        print ""
    }
    print ""
}

function memory_dump_protected(    expr) {
    print "Protected:"
    for (expr = 1; expr <= protected_ptr; ++expr)
        printf("%s %d %d\n",
                printname[expr],
                expr,
                protected[expr])
    print ""
}

function memory_dump_stack(    expr, type, temp) {
    print "Stack: (This is probably meaningless.)"
    printf("Stack Pointer: %d\n", stack_ptr)
    printf("Frame Pointer: %d\n", frame_ptr)
    for (expr in stack) {
        if ((rows++ % 20) == 0)
            print " Num Value: Name              ID Type     CAR: Name      ID   Type   CDR: Name      ID   Type"
        type = type_of(stack[expr])
        temp = stack[expr]
        printf("%4d %-22s %4d %-8s",
                expr,
                (temp in printname ? printname[temp] : ""),
                (is_number(temp) ? numeric_value(temp) : temp),
                type)
        if (type == "pair") {
            printf(" %-12s %4d %8s %-12s %4d %8s",
                    (car[temp] in printname ? printname[car[temp]] : ""),
                    car[temp],
                    type_of(car[temp]),
                    (cdr[temp] in printname ? printname[cdr[temp]] : ""),
                    cdr[temp],
                    type_of(cdr[temp]))
        }
        print ""
    }
    print ""
}

function memory_dump_values(    expr, type, temp, rows) {
    print "Values:"
    rows = 0
    for (expr in value) {
        if ((rows++ % 20) == 0)
            print "Symbol             ID Value: Name              ID Type     CAR: Name      ID Type     CDR: Name      ID Type"
        type = type_of(value[expr])
        temp = value[expr]
        printf("%-16s %4d %-22s %4d %-8s",
                (expr in printname ? printname[expr] : ""),
                expr,
                (temp in printname ? printname[temp] : ""),
                (is_number(temp) ? numeric_value(temp) : temp),
                type)
        if (type == "pair") {
            printf(" %-12s %4d %-8s %-12s %4d %-8s",
                    (car[temp] in printname ? printname[car[temp]] : ""),
                    car[temp],
                    type_of(car[temp]),
                    (cdr[temp] in printname ? printname[cdr[temp]] : ""),
                    cdr[temp],
                    type_of(cdr[temp]))
        }
        if (expr in properties)
            printf(" Prop")
        print ""
    }
    print ""
}

function memory_dump_properties(    expr, left, right, rows) {
    print "Properties:"
    rows = 0
    for (expr in property) {
        i = index(expr, SUBSEP)
        left = substr(expr, 1, i-1)
        right = substr(expr, i+1)
        temp = property[expr]
        printf("%-10s = %-18s %-18s %4d %-22s %-8s\n",
                expr,
                printname[left],
                printname[right],
                temp,
                temp in printname ? printname[temp] : "",
                type_of(temp))
    }
}