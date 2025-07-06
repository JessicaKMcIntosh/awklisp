# Returns the type of an object as a symbol.
# Modules MUST be loaded before awklisp.

# This is more of an example module than something expected to be useful.
# Loading modules does not add overhead at runtime.
# Modules can do anything with the AWK Lisp internals. So please ba careful.
# Don't forget to add your module to "Modules/all.awk" so it will be loaded.

# Usage:
# gawk -p -f Modules\type.awk -f awklisp startup -

# (get_type 11)   => Number
# (get_type '(t)) => Pair
# (get_type "s")  => String
# (get_typ nil)   => Symbol

# First setup the module.
BEGIN {
    # Register the module in the modules array so it can do whatever setup it requires.
    modules["get_type"] = "module_type_register"

    # Tis would be a good place to add any global variables for the module.
}

# This is called just before the read-eval loop starts after all of the builtin setup is done.
function module_type_register() {
    # This creates a primitive, a lisp form that can called like builtin primitives.
    # First a primitive is created for the form.
    # In this case the '1' here tells AWK Lisp this primitive requires exactly one parameter.
    # Use 0 for no parameters.
    # Use "" for unlimited parameters. See the implementation of LIST and WHILE for examples.
    # When the primitive is created a symbol is also created.
    # Finally the symbol is added to the module_func array with the name of the AWk function.
    module_func[def_prim("get_type", 1)] = "module_type_func"
}

# This is the Awk function called when the code is evaluated.
# Nothing is passed to the function.
# Functions are to get their values from the stack.
# See the implementations in the AWk functions eval() and apply()
function module_type_func(    variable) {
    variable = type_of(stack[frame_ptr])
    variable = toupper(substr(variable, 1, 1)) tolower(substr(variable, 2))
    return string_to_symbol(variable)
}

END {
    # Stop lint errors.
    if (0) {
        module_type_register()
        module_type_func()
    }
}
