#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

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
