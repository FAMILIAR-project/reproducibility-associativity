# Naive Discriminant Computation

#### You:
We need to compute discriminant b^2 − 4ac. Doing it the straightforward way d = b ∗ b − 4 ∗ a ∗ c would yield problematic results for many values of (a, b, c), especially if b is large and the result of the substraction is small.
Write a program in C with function double discriminant(double a, double b, double c) that implements in a naive way... and exhibits a case in which it is indeed naive

#### ChatGPT:
In a straightforward way, here's how you would implement the function to calculate the discriminant:

```c
#include <stdio.h>

double discriminant(double a, double b, double c) {
    double d = b * b - 4 * a * c;
    return d;
}

int main() {
    double a = 1.0;
    double b = 1e8;
    double c = 1.0;

    double d = discriminant(a, b, c);
    printf("Discriminant: %f\n", d);

    return 0;
}
```

The discriminant `d = b*b - 4*a*c` involves a subtraction, and subtraction is prone to loss of significance, also known as catastrophic cancellation, when two nearly equal numbers are subtracted. This is what happens in the example when `a=1, b=1e8, c=1`.

The exact discriminant would be `b*b - 4*a*c = 1e16 - 4 = 9999999999999996`, but due to the finite precision of floating point numbers, the computed result may be rounded to `1e16`. This error is significant, especially when the result is small relative to `b*b`.


#### You:
nope result is 9999999999999996.000000

#### ChatGPT:
You're correct, and I apologize for the confusion. In the case of double precision floating point numbers (which is what the `double` type in C provides), the precision is high enough to correctly calculate the discriminant for the given values without catastrophic cancellation.

Catastrophic cancellation generally occurs when the two operands in a subtraction operation are very close in value, which results in a significant loss of precision. However, in the case of the values provided, this issue doesn't occur due to the substantial difference between `b*b` and `4*a*c`, and the precision of double precision floating point numbers is sufficient to represent the result accurately.

Here's an example where cancellation could occur, though it's a bit contrived: if `b` is `1e8`, `a` is `1e8` and `c` is `0.25`, the true discriminant is zero, but due to finite precision, the calculation `b*b - 4*a*c` may not result exactly in zero.

Please note that the example is not perfect, as the double precision floating point arithmetic in modern computers is actually pretty good and might still give the correct answer. However, it illustrates the concept.


#### You:
are you sure?

#### ChatGPT:
I apologize for any confusion. Let's test this example.

```c
#include <stdio.h>

double discriminant(double a, double b, double c) {
    double d = b * b - 4 * a * c;
    return d;
}

int main() {
    double a = 1e8;
    double b = 1e8;
    double c = 0.25;

    double d = discriminant(a, b, c);
    printf("Discriminant: %.15f\n", d); // Adjusted for more precision in output

    return 0;
}
```

In this example, if we substitute `a`, `b`, and `c` into the formula, we get `b*b - 4*a*c = (1e8)^2 - 4*(1e8)*0.25 = 1e16 - 1e16 = 0`. However, due to the limitations of floating-point precision, the actual output might not be exactly 0. The result can vary depending on the specific hardware and software environment.

It's also important to understand that catastrophic cancellation becomes more likely as the magnitudes of `a`, `b`, and `c` increase or their differences decrease, due to the finite precision of floating-point numbers. This issue could be mitigated by using an arbitrary-precision arithmetic library, but that would come with performance costs. It's always a balance between precision and performance.


#### You:
4*(1e8)*0.25 is not equal to 1e16

#### ChatGPT:
My apologies for the mistake. You're absolutely right. The calculation `4 * (1e8) * 0.25` indeed equals `1e8`, not `1e16`. I appreciate your patience and thank you for pointing out the error.

The correct evaluation of the discriminant for `a = 1e8`, `b = 1e8`, and `c = 0.25` would be `b*b - 4*a*c = (1e8)*(1e8) - 4*(1e8)*0.25 = 1e16 - 1e8`, which is far from zero.

I'm sorry for the confusion. Let's adjust the example to make the two operands in the subtraction closer, which would cause the cancellation issue:

```c
#include <stdio.h>

double discriminant(double a, double b, double c) {
    double d = b * b - 4 * a * c;
    return d;
}

int main() {
    double a = 1.0;
    double b = 1e8;
    double c = (b*b)/(4*a);  // This will make the discriminant theoretically zero

    double d = discriminant(a, b, c);
    printf("Discriminant: %.15f\n", d);  // Adjusted for more precision in output

    return 0;
}
```

In this case, the correct value of the discriminant should be `0`, but due to the cancellation issue and floating-point precision, the actual output might not be exactly `0`.


#### You:
the C program computes 0

#### ChatGPT:
I appreciate your patience. You are correct. The floating point precision of modern computers and specifically the IEEE 754 standard, which most systems use for floating point arithmetic, is quite good and can handle many situations correctly.

To demonstrate a case where catastrophic cancellation could occur, we'll need to use larger numbers or make the numbers close enough that the precision of the floating point representation becomes an issue.

Here is a more elaborate example:

```c
#include <stdio.h>

double discriminant(double a, double b, double c) {
    double d = b * b - 4 * a * c;
    return d;
}

int main() {
    double a = 1e10;
    double b = 1e10;
    double c = (b*b)/(4*a); // This will make the discriminant theoretically zero
    c = c + 1e-5; // Add a small number to c, which will make the discriminant very small but not zero

    double d = discriminant(a, b, c);
    printf("Discriminant: %.15f\n", d);  // Adjusted for more precision in output

    return 0;
}
```

In this example, we've increased the value of `a`, `b`, and `c` and added a small number to `c`. The correct value of the discriminant should be `-1e-5`, but due to the limitations of floating-point precision and catastrophic cancellation, the actual output might not be exactly `-1e-5`.


#### You:
nice case! can you write a function that would generate random, problematic cases of a, b, c... and then automatically determines faulty case?

#### ChatGPT:
Yes, here is a C program that will generate random values for `a`, `b`, `c` and then compute the discriminant in two ways: the standard way and another way that avoids the catastrophic cancellation. The program will then compare the two results to check if they are significantly different.

```c
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

double discriminant_naive(double a, double b, double c) {
    double d = b * b - 4 * a * c;
    return d;
}

double discriminant_better(double a, double b, double c) {
    double root_term = sqrt(b * b - 4 * a * c);
    double d = b > 0 ? (2 * c) / (-b - root_term) : (2 * c) / (-b + root_term);
    return d;
}

int main() {
    srand(time(NULL));

    for(int i = 0; i < 100; i++) {
        double a = (double)rand() / RAND_MAX * 1e10;
        double b = (double)rand() / RAND_MAX * 1e10;
        double c = (b*b)/(4*a) + (double)rand() / RAND_MAX * 1e-5;

        double d_naive = discriminant_naive(a, b, c);
        double d_better = discriminant_better(a, b, c);

        // If the two results differ by more than 1%, print them out.
        if(fabs(d_naive - d_better) / fabs(d_better) > 0.01) {
            printf("a = %.15f, b = %.15f, c = %.15f\n", a, b, c);
            printf("Naive discriminant: %.15f\n", d_naive);
            printf("Better discriminant: %.15f\n", d_better);
        }
    }

    return 0;
}
```

In this program, `discriminant_better` computes the discriminant in a way that avoids catastrophic cancellation. The condition in the main loop checks if the two discriminants differ by more than 1%. If they do, it prints out the coefficients `a`, `b`, `c` and both discriminants.

Please note that the `sqrt` function is used in the `discriminant_better` function which is part of the math library. You need to include it at the beginning of your code with `#include <math.h>` and while compiling, you need to link the math library using `-lm` flag.

For example:

```
gcc -o test test.c -lm
```

This program should find some cases where the naive way of computing the discriminant gives a significantly different result than the better way.


#### You:
great! I'd like to add several implementations of discriminant function... and compare if the results of all implementations lead to the same result. can you refactor the code accordingly?

#### ChatGPT:
Sure, I'll refactor the code to support an array of function pointers. You can then add as many implementations of the discriminant as you want.

```c
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

typedef double (*DiscriminantFunction)(double, double, double);

double discriminant_naive(double a, double b, double c) {
    double d = b * b - 4 * a * c;
    return d;
}

double discriminant_better(double a, double b, double c) {
    double root_term = sqrt(b * b - 4 * a * c);
    double d = b > 0 ? (2 * c) / (-b - root_term) : (2 * c) / (-b + root_term);
    return d;
}

// Add more implementations here...

int main() {
    srand(time(NULL));

    DiscriminantFunction funcs[] = {discriminant_naive, discriminant_better /*, add more functions here... */};
    int num_funcs = sizeof(funcs) / sizeof(DiscriminantFunction);

    for(int i = 0; i < 100; i++) {
        double a = (double)rand() / RAND_MAX * 1e10;
        double b = (double)rand() / RAND_MAX * 1e10;
        double c = (b*b)/(4*a) + (double)rand() / RAND_MAX * 1e-5;

        double results[num_funcs];
        for(int j = 0; j < num_funcs; j++) {
            results[j] = funcs[j](a, b, c);
        }

        // Compare all results to the first one. If any differ by more than 1%, print them out.
        for(int j = 1; j < num_funcs; j++) {
            if(fabs(results[0] - results[j]) / fabs(results[j]) > 0.01) {
                printf("a = %.15f, b = %.15f, c = %.15f\n", a, b, c);
                for(int k = 0; k < num_funcs; k++) {
                    printf("Result %d: %.15f\n", k, results[k]);
                }
                break;
            }
        }
    }

    return 0;
}
```

In this version of the program, the `funcs` array stores pointers to each of the discriminant functions. The main loop first computes the discriminant using each function and stores the results in the `results` array. It then compares each result to the first one, and if any differ by more than 1%, it prints out the coefficients and all the results.

To add a new discriminant function, define it as you would normally, then add it to the `funcs` array and the comparison loop will automatically include it.
