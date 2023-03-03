# Reproducibility, associativity, and deep variability 

Reproducibility: software experiments with damn simple associativity and deep variability

Do you agree that `x+(y+z) == (x+y)+z`? 
Well, let's see...

Here are the current implementations:
 * configurable Python implementation with `seed` and `number` 
 * configurable Java implementation with `basic` (float), `double` or `math` 
 * configurable C implementation with `custom` (optional) + `windows` or `linux` having an effect on random primitives 
 * configurable Rust implementation with compile-time options (associativity, multiplication inverse with and without Pi) and run-time options with optional error margin over equality 
 * LISP implementation 

To execute all variants and gathered results into a CSV: `sh eval.sh > results2.csv`

## Resources

### General 

https://lemire.me/blog/2019/03/12/multiplying-by-the-inverse-is-not-the-same-as-the-division/

https://en.wikipedia.org/wiki/Linear_congruential_generator (pseudo-random generator)

### Rust

https://users.rust-lang.org/t/why-are-float-equality-comparsions-allowed/76603 about float equals stuffs
Clippy lints https://rust-lang.github.io/rust-clippy/master/index.html#float_cmp 

