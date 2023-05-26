# Find Real Roots

#### You:
def solve(a: float, b: float, c: float):
   ''' find real roots of ax^2+bx+c '''


#### ChatGPT:
Sure, here's a Python function that finds the real roots of the equation ax^2 + bx + c = 0 using the quadratic formula.

```python
import cmath

def solve(a: float, b: float, c: float):
    ''' find real roots of ax^2+bx+c '''
    # calculate the discriminant
    D = (b**2) - (4*a*c)
    
    # find two solutions
    sol1 = (-b-cmath.sqrt(D))/(2*a)
    sol2 = (-b+cmath.sqrt(D))/(2*a)
    
    # check if roots are real
    real_roots = []
    if sol1.imag == 0:
        real_roots.append(sol1.real)
    if sol2.imag == 0:
        real_roots.append(sol2.real)

    return real_roots
```

This function will return a list of the real roots of the equation. If there are no real roots, it will return an empty list. Note that we use `cmath` to handle complex numbers because the square root of a negative number is a complex number, and we want to avoid a ValueError. We then check if the roots are real by checking if the imaginary part is zero. If it is, we add the real part of the root to the list of real roots.


#### You:
what if D = 0?

#### ChatGPT:
The discriminant (D) in the quadratic formula helps us understand the nature of the roots of a quadratic equation:

- If D > 0, then there are two distinct real roots.
- If D = 0, then there is exactly one real root (or the two real roots coincide).
- If D < 0, then there are two complex roots, which means no real roots.

In the Python function given above, if the discriminant is zero, the `cmath.sqrt(D)` part will be zero, so both solutions will be equal to `-b / (2*a)`. In that case, the function will return a list with one number, which represents the one real root of the equation.
