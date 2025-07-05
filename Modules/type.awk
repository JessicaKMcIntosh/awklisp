# Returns the type of an object as a symbol.
# Modules MUST be loaded before awklisp.

# Usage:
# gawk -p -f Modules\type.awk -f awklisp startup -

# (get_typ nil)   => Symbol
# (get_type 11)   => Number
# (get_type '(t)) => Pair

BEGIN {
    modules["get_type"] = "module_type_register"
}

function module_type_register() {
    module_func[def_prim("get_type", 1)] = "module_type_func"
}

function module_type_func(variable) {
    variable = type_of(stack[frame_ptr])
    variable = toupper(substr(variable, 1, 1)) substr(variable, 2)
    return string_to_symbol(variable)
}
