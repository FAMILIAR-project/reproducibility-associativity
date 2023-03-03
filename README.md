# Reproducibility, associativity, and deep variability 

Reproducibility: software experiments with damn simple associativity and deep variability

Do you agree that `x+(y+z) == (x+y)+z`? 
Well, let's see...

Here are the current implementations:
 * configurable Python implementation with `seed` and `number` 
 * configurable Java implementation with `basic` (float), `double` or `math` 
 * configurable C implementation with `custom` (optional) + `windows` or `linux` having an effect on random primitives. We compile with `gcc`, `i686-w64-mingw32-gcc` (when needs be/possible), and `clang` 
 * configurable Rust implementation with compile-time options (associativity, multiplication inverse with and without Pi) and run-time options with optional error margin over equality 
 * LISP implementation 
 * configurable JavaScript implementation with `seed` number (and actually the surprising `global seed`) and `equality-check` (associativity, multiplication inverse with and without Pi)
 * configurable Bash implementation with `equality-check` using `-e` (associativity, multiplication inverse with and without Pi)

 All implementations (but LISP until now) support parameterization of the number of random generations. 
 Executions are repeated 10 times by default (min, max, average, std reported).

To execute all variants and gathered results into a CSV: `export WINEDEBUG=-all; sh eval.sh > results.csv; python postdata.py; # do something with data like rich results.csv`

## Resources

### General 

https://lemire.me/blog/2019/03/12/multiplying-by-the-inverse-is-not-the-same-as-the-division/

https://en.wikipedia.org/wiki/Linear_congruential_generator (pseudo-random generator)

### Rust

https://users.rust-lang.org/t/why-are-float-equality-comparsions-allowed/76603 about float equals stuffs
Clippy lints https://rust-lang.github.io/rust-clippy/master/index.html#float_cmp 

### LISP

https://gist.github.com/garandria/0e965d7a4efff89ed245d71f0c3785a3
https://stackoverflow.com/questions/11006798/how-can-i-obtain-a-negative-random-integer-in-common-lisp 

### C

To cross-compile for Windows from Linux with `i686-w64-mingw32-gcc`, specific packages are needed (e.g. on Fedora `mingw64-gcc.x86_64`). 
The combinatorial is roughly (but in fact there are much more variation points and variants):
```
gcc -o testassoc-l testassoc.c
gcc -o testassoc-lc testassoc.c -DCUSTOM
i686-w64-mingw32-gcc -o testassoc-w testassoc.c -DWIN
i686-w64-mingw32-gcc -o testassoc-wc testassoc.c -DWIN -DCUSTOM
```