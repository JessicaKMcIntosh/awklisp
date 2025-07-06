# Things to fix

## BUGS

* Fix the lint errors on close of /dev/stderr.
  Rearrange them to guarantee it is closed only once after use.

## URGENT

* Fix printing of strings in `Extras/world_objects.awk` to create reproducible strings.
* Write a shell script for *nix.

## Test Cases

All of the primitives need test cases.
Most of those could be done with unit testing.

* Need to verify that `Extras/world_objects.awk` produces reproducible code.

* Strings.
  * Defining a string variable.
  * (write) the string.
  * TODO: Add more as more string functions are added.
  * These two are equivalent, the second uses hex and octal numbers.

```scheme
(write "A string with\tspecial\\ character\"s.=")
(write "A string with\tspecia\154\\ char\x61cter\"s.\x3D")
```

* Types module. (get_type)

  Since this is an example module this could be an example Unit test.

```scheme
(get_type nil)
(get_type 11)
(get_type '(t))
(get_type "str")
```

* Using modules?

  Because modules are registered right before the read-eval loop starts they can used test all the Awk functions.
  HAve the registration function simple do all the work.

  It is also possible to inject code in the input buffer so it is processed before files are read.

  You could also intercept the read-eval loop by setting `top-level-driver` to your own function.
  Create test cases with embedded parameters for testing.
  Only (write) and (newline) have effects outside of AWk.
  These two could be intercepted by changing WRITE and NEWLINE to invalid values and registering customer functions for each.

```awk
; Initialize data in a module.
; This line will add some code to the input buffer.
; Make sure to append, other modules might have initialization code.
line = line "()(write (gensym))(newline)"
; Token must be set to something or the contents of 'line' are ignored.
; This is due to a hack supporting interactive use.
token = "'"
```

* Resources:

  * <https://wiki.c2.com/?SchemeUnit>
  * <https://blog.code-cop.org/2023/10/unit-testing-scheme.html>

* Loading a file. (load)

## Documentation

* How strings are handled.

  Document the escape codes.
  The same as Gawk except:
  * \nnn (\077 or \177) for octal require three characters total.
  * \xhh (\xa0 or \xFF) for hexadeciman require two characters total.
  * \uhh.. is not supported. Too much work. :shrug:

* A full list of functions and any deviations from R5RS.

## Would be good

* For the batch file look for files with multiple extensions.
  Extend the processing of the command line args.
* For the (load) command look for files with multiple extensions.

## Nice to have

* Input for alternate bases prefixes are #b (binary), #o (octal), #d (decimal), and #x (hexadecimal)

* (format)

* Rearrange and rename the files.
  A consistent extension would help. `.scm`

* Implement (break) and (continue) for (While) loops.
Test case:

```scheme
(define whiletest
    (lambda (start limit action)
        (while (< start limit)
            (eval action)
            (if (eq? 5 start)
                (begin
                    (write 'Five!!)
                    (newline)
                    )) ; This is a great spot for a break.
            (set! start (+ start 1)))
        start))

(write
    (whiletest
        0   ; Start
        10  ; Limit
        '(begin
            (write start)
            (newline)
        )))
(newline)
```

* R5RS conpatability?
