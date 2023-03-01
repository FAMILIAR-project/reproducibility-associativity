# Reproducibility, associativity, and deep variability 

Reproducibility: software experiments with damn simple associativity and deep variability

Do you agree that `x+(y+z) == (x+y)+z`? 
Well, let's see...

Here are the current implementations:
 * configurable Python implementation with `seed` and `number` 
 * configurable Java implementation with `basic` or `math` 
 * configurable C implementation with `custom` (optional) + `windows` or `linux`

To execute all variants and gathered results into a CSV: `sh eval.sh > results2.csv`
