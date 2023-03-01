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
void main(argc, argv)
int argc;
char *argv[];
{
#ifdef WIN
  srand(123);
#else
  drand48(123);
#endif
  printf("%f%%\n",proportion(100000));
}
