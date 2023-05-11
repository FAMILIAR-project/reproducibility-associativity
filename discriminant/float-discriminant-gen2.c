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

double discriminant_dekker(double a, double b, double c) {
    double sq_b = b * b;
    double four_ac = 4.0 * a * c;

    // Dekker's algorithm
    double diff = sq_b - four_ac;
    double err_b = sq_b - diff;
    double err_ac = four_ac + (err_b - diff);

    if (err_b != diff) {
        // No need to apply Dekker's algorithm, return the simple calculation
        return diff;
    }
    else {
        // Apply Dekker's algorithm to correct the error
        double err_b_dekker = sq_b - err_b;
        double err_ac_dekker = four_ac - err_ac;

        return (err_b_dekker - err_ac_dekker) + diff;
    }
}

/*@ requires xy == \round_double(\NearestEven,x*y) && 
  @          \abs(x) <= 0x1.p995 && 
  @          \abs(y) <= 0x1.p995 &&
  @          \abs(x*y) <=  0x1.p1021;
  @ ensures  ((x*y == 0 || 0x1.p-969 <= \abs(x*y)) 
  @                 ==> x*y == xy+\result);
  @*/
double Dekker(double x, double y, double xy) {

  double C,px,qx,hx,py,qy,hy,tx,ty,r2;
  C=0x8000001p0;
  /*@ assert C == 0x1p27+1; */

  px=x*C;
  qx=x-px;
  hx=px+qx;
  tx=x-hx;

  py=y*C;
  qy=y-py;
  hy=py+qy;
  ty=y-hy;

  r2=-xy+hx*hy;
  r2+=hx*ty;
  r2+=hy*tx;
  r2+=tx*ty;
  return r2;
}

// https://www.lri.fr/~sboldo/progs/discri.c.html
double discriminant_boldo(double a, double b, double c) {
  double p,q,d,dp,dq;
  p=b*b;
  q=a*c;
  
  if (p+q <= 3*fabs(p-q))
    d=p-q;
  else {
    dp=Dekker(b,b,p);
    dq=Dekker(a,c,q);
    d=(p-q)+(dp-dq);
  }
  return d;
}

// Add more implementations here...

int main() {
    srand(time(NULL));

    // using calc
    // 9143542153.361972808837891*9143542153.361972808837891 - 4*1454597162.760140895843506*14368989100.677461624145508	~5868.02713524853480235649
    // using Python 3.11
    // >>> 9143542153.361972808837891*9143542153.361972808837891 - 4*1454597162.760140895843506*14368989100.677461624145508
    // 0.0

    DiscriminantFunction funcs[] = {discriminant_better, discriminant_naive, discriminant_dekker, discriminant_boldo /*, add more functions here... */};
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
