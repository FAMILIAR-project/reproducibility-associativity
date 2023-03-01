#!/bin/sh

echo "Language;Library;System;Score;"

echo -n "Python;std;-;"
python testassoc.py --seed 42 --number 1000 | tr -d '\n'
echo ";"

javac -d . *.java
echo -n "Java;"
echo -n "java.util.Random.nextFloat();"
echo -n "-;"
java assoc.TestAssoc basic | tr -d '\n'
echo ";"

echo -n "Java;"
echo -n "Math.random();"
echo -n "-;"
java assoc.TestAssoc math | tr -d '\n'
echo ";"

echo -n "C;"
echo -n "custom;Linux;"
gcc -o testassoc testassoc.c -DCUSTOM=1
./testassoc | tr -d '\n'
echo ";"

echo -n "C;"
echo -n "(srand48+rand48);Linux;"
gcc -o testassoc testassoc.c  
./testassoc | tr -d '\n'
echo ";"

echo -n "C;"
echo -n "custom;Windows;"
gcc -o testassoc testassoc.c -DWIN=1 -DCUSTOM=1
./testassoc | tr -d '\n'
echo ";"

echo -n "C;"
echo -n "(srand+rand);Windows;"
gcc -o testassoc testassoc.c -DWIN=1 
./testassoc | tr -d '\n'
echo ";"

