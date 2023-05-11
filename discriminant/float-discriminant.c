#include <stdio.h>

double discriminant(double a, double b, double c) {
    double d = b * b - 4 * a * c;
    return d;
}

int main() {
    /*
    double a = 1e8;//.0;
    double b = 1e8;
    double c = 0.25; //1.0;
    */
    /*
    double a = 1.0;
    double b = 1e8;
    double c = (b*b)/(4*a);  // This will make the discriminant theoretically zero
    */
    double a = 1e10;
    double b = 1e10;
    double c = (b*b)/(4*a); // This will make the discriminant theoretically zero
    c = c + 1e-5; // Add a small number to c, which will make the discriminant very small but not zero


    double d = discriminant(a, b, c);
    printf("Discriminant: %f\n", d);

    return 0;
}
