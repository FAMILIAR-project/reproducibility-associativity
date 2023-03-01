#include <stdio.h>
#include <stdlib.h>
#define XMASK (char)(99)
static int randseed=-1;

/* Macro to return a uniform distributed random real number between 0 and 1 */
/* s is the seed, bb the multiplier. 'Maxint &' is used to mask the sign bit*/
#define Maxint (0x7fffffff)
#define invmaxint 4.656612875e-10
#define bb 31415821
#ifdef CUSTOM
#define uniform (double)(invmaxint*(randseed=(Maxint & ((randseed*bb)-1))))
#else
#ifdef WIN
#define uniform rand()
#else
#define uniform drand48()
#endif
#endif

int associativity_test()
{
  double x = uniform; double y = uniform; double z = uniform;
  //  printf("%f   %f   %f   %d\n",x,y,z,x+(y+z) == (x+y)+z);
  return x+(y+z) == (x+y)+z;
}

float proportion(int number)
{
  int ok=0;
  for (int i=0;i<number;i++) ok += associativity_test();
  return ok*100.0/number;
}


/* Here is the entry point of the program */
#ifdef OLD_MAIN_C
void main(argc, argv)
int argc;
char *argv[];
{
#else
int main(int argc, char **argv) {
#endif 
#ifdef WIN
  srand(123);
#else
  srand48(123);
#endif
int count = 100000; // default value
if (argc > 1) {
count = atoi(argv[1]); // convert the user input to an integer
}
printf("%f%%\n", proportion(count));
#ifndef OLD_MAIN_C
  return 0;
#endif
}
