#include <stdio.h>
#include <mpfr.h>

int main() {
    mpfr_t a, b, c, result, tmp;

    mpfr_init2(a, 256); // Initialize mpfr variables with precision 256
    mpfr_init2(b, 256);
    mpfr_init2(c, 256);
    mpfr_init2(result, 256);
    mpfr_init2(tmp, 256);

    // Assuming a, b, and c
    mpfr_set_d(a, 1454597162.760140895843506, MPFR_RNDN);
    mpfr_set_d(b, 9143542153.361972808837891, MPFR_RNDN);
    mpfr_set_d(c, 14368989100.677461624145508, MPFR_RNDN);

    mpfr_mul(tmp, b, b, MPFR_RNDN); // tmp = b*b
    mpfr_mul(result, a, c, MPFR_RNDN); // result = a*c
    mpfr_mul_ui(result, result, 4, MPFR_RNDN); // result = 4*a*c
    mpfr_sub(result, tmp, result, MPFR_RNDN); // result = b*b - 4*a*c

    mpfr_printf("Result: %.256Rf\n", result);

    // Clear up memory
    mpfr_clear(a);
    mpfr_clear(b);
    mpfr_clear(c);
    mpfr_clear(result);
    mpfr_clear(tmp);

    return 0;
}
