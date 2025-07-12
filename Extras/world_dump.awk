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
# gawk -f awklisp -f Extras\world_dump.awk -v dump_all=1 startup.scm


END {
    # Take from Modules/type.awk for displaying types.
    world_dump_type_name[a_number] = "number"
    world_dump_type_name[a_pair]   = "pair"
    world_dump_type_name[a_string] = "string"
    world_dump_type_name[a_symbol] = "symbol"

    # Prepare the ordinal table for character conversions.
    world_dump_ord_init()

    printf("\n\nDumping Memory:\n")
    if (dump_names     || dump_all) world_dump_names()
    if (dump_pairs     || dump_all) world_dump_pairs()
    if (dump_props     || dump_all) world_dump_properties()
    if (dump_protected || dump_all) world_dump_protected()
    if (dump_stack     || dump_all) world_dump_stack()
    if (dump_values    || dump_all) world_dump_values()
}

function world_dump_names(    expr) {
    print "Print Names:"
    for (expr in printname) {
        printf("%5d %s\n",
                expr,
                world_dump_to_string(expr))
    }
    print ""
}

function world_dump_pairs(    expr, rows) {
    print "Pairs:"
    rows = 0
    for (expr in car) {
        if ((rows++ % 20) == 0)
            print "Pair ID CAR: Name      ID Type     CDR: Name      ID Type"

        printf("%7d %-12s %4d %-8s %-12s %4d %-8s",
                expr,
                world_dump_to_string(car[expr]),
                car[expr],
                world_dump_type_name[car[expr] % 4],
                world_dump_to_string(cdr[expr]),
                cdr[expr],
                world_dump_type_name[cdr[expr] % 4])
        print ""
    }
    print ""
}

function world_dump_protected(    expr) {
    print "Protected:"
    for (expr = 1; expr <= protected_ptr; ++expr)
        printf("%s %d %d\n",
                world_dump_to_string(expr),
                expr,
                protected[expr])
    print ""
}

function world_dump_stack(    expr, type, temp, rows) {
    print "Stack: (This is probably meaningless.)"
    printf("Stack Pointer: %d\n", stack_ptr)
    printf("Frame Pointer: %d\n", frame_ptr)
    for (expr in stack) {
        if ((rows++ % 20) == 0)
            print " Num Value: Name              ID Type     CAR: Name      ID   Type   CDR: Name      ID   Type"
        type = world_dump_type_name[stack[expr] % 4]
        temp = stack[expr]
        printf("%4d %-22s %4d %-8s",
                expr,
                world_dump_to_string(temp),
                temp,
                type)
        if (type == "pair") {
            printf(" %-12s %4d %8s %-12s %4d %8s",
                    world_dump_to_string(car[temp]),
                    car[temp],
                    world_dump_type_name[car[temp] % 4],
                    world_dump_to_string(cdr[temp]),
                    cdr[temp],
                    world_dump_type_name[cdr[temp] % 4])
        }
        print ""
    }
    print ""
}

function world_dump_values(    expr, type, temp, rows) {
    print "Values:"
    rows = 0
    for (expr in value) {
        if ((rows++ % 20) == 0)
            print "Symbol             ID Value: Name              ID Type     CAR: Name      ID Type     CDR: Name      ID Type"
        type = world_dump_type_name[value[expr] % 4]
        temp = value[expr]
        printf("%-16s %4d %-22s %4d %-8s",
                world_dump_to_string(expr),
                expr,
                world_dump_to_string(temp),
                temp,
                type)
        if (type == "pair") {
            printf(" %-12s %4d %-8s %-12s %4d %-8s",
                    world_dump_to_string(car[temp]),
                    car[temp],
                    world_dump_type_name[car[temp] % 4],
                    world_dump_to_string(cdr[temp]),
                    cdr[temp],
                    world_dump_type_name[cdr[temp] % 4])
        }
        if (expr in properties)
            printf(" Prop")
        print ""
    }
    print ""
}

function world_dump_properties(    expr, left, right, rows, temp, i) {
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
                world_dump_to_string(temp),
                world_dump_type_name[temp % 4])
    }
    print ""
}

# Convert an expression to a string depending on the type.
function world_dump_to_string (expr) {
    if (!(expr in printname))
        return ""
    if (is_string(expr))
        return world_dump_escape_string(printname[expr])
    return printname[expr]
}

function world_dump_ord_init(    char, ord) {
    for (ord = 0; ord <= 255; ord ++) {
        char = sprintf("%c", ord)
        world_objects_ord[char] = ord
    }
}

function world_dump_escape_string(str,    new, pos, char) {
    new = ""
    for  (pos = 1; pos <= length(str); pos++) {
        char = substr(str, pos, 1)
        switch (char) {
            case "\a": char = "\\a";  break
            case "\b": char = "\\b";  break
            case "\f": char = "\\f";  break
            case "\n": char = "\\n";  break
            case "\r": char = "\\r";  break
            case "\t": char = "\\t";  break
            case "\v": char = "\\v";  break
            case "\"": char = "\\\""; break
            case "\\": char = "\\\\"; break
            default:
                if (char < " ") {
                    char = sprintf("\\x%x", world_objects_ord[char])
                }
            break
        }
        new = new char
    }
    return "\"" new "\"";
}
