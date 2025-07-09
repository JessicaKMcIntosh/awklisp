# AWK Lisp: a Lisp interpreter in awk

This is a fork just to play around with this fun toy.

My intention is to add gawk specific extensions to make the code cleaner and hopefully improve performance.

I have some other ideas as well.

* Add output for monitoring performance.
  Can't tell if something is an improvement if you can't measure it.
* Add a string data type and string routines. - Mostly done. Need more functions.
* C style for loops would be an interesting addition.
  startup has a for-each loop.
* More math primitives.
* ~~Include other files. So startup and other libraries could be loaded on demand.~~ - This is done. `(source "file_name.scm")`
* Adding break and continue for loops would be an interesting challenge.

## COPYRIGHT

All original files are still copyright (c) 1994, 2001 by Darius Bacon.

Anything I, Jessica K McIntosh, have produced is in the public domain.

## Original readme

See the Manual file for documentation.

This release also has a Perl version, perlisp, contributed by the Perl
Avenger, who writes:

  It has new primitives: a reentrant "load", a "trace" command, and more
  error reporting.  Perlisp will attempt to load a program called
  "testme" before anything else, when it runs.  After that, it will load
  $HOME/.perlisprc if that file exists, before reverting to the
  interactive read/eval/print loop.

The awk code is still essentially the code posted to alt.sources (May
31, 1994), but with a garbage collector added.

Copyright (c) 1994, 2001 by Darius Bacon.

Permission is granted to anyone to use this software for any
purpose on any computer system, and to redistribute it freely,
subject to the following restrictions:

1. The author is not responsible for the consequences of use of
   this software, no matter how awful, even if they arise from
   defects in it.

2. The origin of this software must not be misrepresented, either
   by explicit claim or by omission.

3. Altered versions must be plainly marked as such, and must not
   be misrepresented as being the original software.
