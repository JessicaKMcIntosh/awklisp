# Exits AWK Lisp immediately.
# Modules MUST be loaded before awklisp.

# Usage:
# gawk -p -f Modules\exit.awk -f awklisp startup -

# (exit 0) => Exits with return code 0.
# (exit 1) => Exits with return code 1.
# (exit (+ 1 2)) => Exits with return code 3.
# (exit t) => Exits with return code 0.
# (exit nil) => Exits with return code 1.

BEGIN {
    modules["exit"] = "module_exit_register"
}

function module_exit_register() {
    module_func[def_prim("exit", 1)] = "module_exit_func"
}

function module_exit_func() {
    exit(is_number(stack[frame_ptr]) ? numeric_value(stack[frame_ptr]) : stack[frame_ptr] == NIL ? 1 : 0)
}

END {
    # Stop lint errors.
    if (0) {
        module_exit_register()
        module_exit_func()
    }
}
