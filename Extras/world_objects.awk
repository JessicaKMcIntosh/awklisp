# Print out everything in values[] and properties[] as a pretty little tree.
# The goal is for the output to be valid AWK Lisp code.

# TODO: This should probably correctly reproduce a string.

# Usage:
# Include this file on the command line: -f Extras\world_objects.awk

# Example:
# gawk -f awklisp -f Extras\world_objects.awk startup

END {
    printf("\n\nObjects:\n")
    world_objects()

    # Make lint happy.
    cmp_str_printname(0, 0, 0, 0)
}

function world_objects(    expr, name) {
    # Sort by the printname when possible.
    PROCINFO["sorted_in"] = "cmp_str_printname"

    # Reuse marks for noting which values were already printed.
    delete marks

    # First print symbols thar are just atoms, like primitives.
    for (expr in value) {
        if (!(is_symbol(expr) && is_atom(value[expr])))
            continue
        marks[expr] = 1

        # No print name means it isn't really there.
        if (!(expr in printname))
            continue
        # Numbers are easy.
        if (is_number(value[expr]))
            name = "0"
        else if (is_string(value[expr]))
            name = sprintf("\"%s\"", printname[value[expr]])
        else {
            # Get the name of the value.
            name = (value[expr] in printname ? printname[value[expr]] : sprintf("<%s>", value[expr]))

            # If this is a primitive get the primitives name.
            if (is_symbol(value[expr]) && match(name, /#<Primitive (.*)>/))
                name = substr(name, 13, length(name) - 13)

            # Skip over native primitive definitions.
            if ((printname[expr] == name) || (name == "#eof"))
                continue
        }

        printf("%c%s %s %s%c\n", 40, "define", printname[expr], name, 41)

    }

    # Next print everything else.
    for (expr in value) {
        if (expr in marks)
            continue
        printf("%c%s ", 40, "define")
        write_expr_indent(expr, 0, 0, NIL)
        write_expr_indent(value[expr], 1, 0, NIL)
        printf("%c\n", 41)
    }

    write_world_properties()
}

# This was adapted from write_expr(expr) to add indention.
function write_expr_indent(expr, indent, noindent, parent, name)
{
    if (is_atom(expr)) {
        # This is a special case for a parameter given to a lambda.
        # These should be on a separate line at the same indention as the lambda.
        # For examples see length in startup and eliza-answer in eliza.lsp
        if ((parent != NIL) && is_pair(parent) && is_pair(car[parent]) && (car[car[parent]] == LAMBDA))
            printf("\n%*s", (indent * 2), "")

        if (is_string(expr))
            printf("\"%s\"", printname[expr])
        else if (!is_symbol(expr))
            printf("%d", numeric_value(expr))
        else {
            printf("%s", expr in printname ? printname[expr] : sprintf("<%s>", expr))
        }
    } else {
        # Indent the open paren unless requested otherwise.
        if (noindent == 0)
            printf("\n%*s", (indent * 2), "")
        printf("%c", 40)

        # Print a space to the output prettier when indention will be skipped.
        if (is_pair(car[expr]) && is_pair(cdr[expr]))
            printf(" ")

        # Don't print lines with only an indented open paren.
        # This brings the next line up to make things prettier.
        write_expr_indent(car[expr], indent + 1, is_pair(car[expr]), NIL)

        # Don't indent the next line to make certain forms prettier.
        if (car[expr] == LAMBDA || car[expr] == IF || car[expr] == WHILE)
            noindent = 1

        parent = expr
        for (expr = cdr[expr]; is_pair(expr); expr = cdr[expr]) {
            printf(" ")
            write_expr_indent(car[expr], indent + 1, noindent, parent)
            noindent = 0
            parent = expr
        }
        if (expr != NIL) {
            printf(" . ")
            write_expr_indent(expr, indent + 1, noindent, NIL)
        }
        printf("%c", 41)
    }
}

function write_world_properties(    p, i, left, right, count) {
    printf("\nProperties:\n")
    count = 0
    for (p in property) {
        count++
        i = index(p, SUBSEP)
        left = substr(p, 1, i-1)
        right = substr(p, i+1)
        if (printname[right] == "macro")
            printf("%c%s '%s", 40, "define-macro", printname[left])
        else
            printf("%c%s '%s '%s", 40, "put", printname[left], printname[right])
        write_expr_indent(property[p], 1, 0, NIL)
        printf("%c\n", 41)
    }
    if (count == 0)
        print "No Properties Defined!"
}

# Sorting functions.
# This is taken from the GNU AWK manual.
# Modified to sort by printname of the values.
# https://www.gnu.org/software/gawk/manual/gawk.html#Array-Sorting

function cmp_str_printname(i1, v1, i2, v2)
{
    # Try to get the print name for each value.
    if (i1 in printname)
        i1 = printname[i1]
    else
        i1 = i1 ""
    if (i2 in printname)
        i2 = printname[i2]
    else
        i2 = i2 ""


    v2 = v2 ""
    if (i1 < i2)
        return -1
    return (i1 != i2)
}
