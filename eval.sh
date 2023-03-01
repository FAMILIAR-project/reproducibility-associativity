#!/bin/sh

echo "Language;Library;System;Compiler;VariabilityMisc;Score;"

echo -n "Python;std;-;-;-;" # TODO python version
python testassoc.py --seed 42 --number 1000 | tr -d '\n'
echo ";"

javac -d . *.java
echo -n "Java;"
echo -n "java.util.Random.nextFloat();"
echo -n "-;-;-;" # TODO JDK version
java assoc.TestAssoc basic | tr -d '\n'
echo ";"

echo -n "Java;"
echo -n "Math.random();"
echo -n "-;-;-;" # TODO JDK version
java assoc.TestAssoc math | tr -d '\n'
echo ";"


COMPILERS=("gcc" "clang")
OPTIONS=("-DCUSTOM=1" "" "-DWIN=1 -DCUSTOM=1" "-DWIN=1")
FLAGS=("-DOLD_MAIN_C=1" "")

for compiler in "${COMPILERS[@]}"; do
    for i in {0..3}; do
        for flag in "${FLAGS[@]}"; do
            echo -n "C;"
            case "$i" in
                0)
                    echo -n "custom;Linux;"
                    ;;
                1)
                    echo -n "(srand48+rand48);Linux;"
                    ;;
                2)
                    echo -n "custom;Windows;"
                    ;;
                3)
                    echo -n "(srand+rand);Windows;"
                    ;;
            esac

            echo -n "$compiler;"
            echo -n "$flag;" # variability misc
            $compiler -o testassoc testassoc.c ${OPTIONS[$i]} ${flag}
            ./testassoc | tr -d '\n'
            echo -n ";"            
            echo ""
        done
    done
done


