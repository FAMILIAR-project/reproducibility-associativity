#!/bin/sh

echo "Java"
javac -d . *.java
echo "first line is with java.util.Random.nextFloat()"
echo "second line is with Math.random()"
java assoc.TestAssoc

echo "Python"
python testassoc.py --seed 42 --number 1000

echo "C"
echo "Windows (srand+rand), custom"
gcc -o testassoc testassoc.c -DWIN=1 -DCUSTOM=1
./testassoc 

echo "Windows (srand+rand), no custom"
gcc -o testassoc testassoc.c -DWIN=1 
./testassoc 

echo "Linux (srand48+rand48), no custom"
gcc -o testassoc testassoc.c  
./testassoc 

echo "Linux (srand48+rand48), custom"
gcc -o testassoc testassoc.c -DCUSTOM=1
./testassoc 

