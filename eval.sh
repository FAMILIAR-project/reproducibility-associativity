#!/bin/sh

# TODO: repeat N times the experiments and report std/mean/min/max in the Score

# TODO number as a column 

CSV_SEPARATOR=';'
echo "Language${CSV_SEPARATOR}Library${CSV_SEPARATOR}System${CSV_SEPARATOR}Compiler${CSV_SEPARATOR}VariabilityMisc${CSV_SEPARATOR}Score"

echo -n "Python${CSV_SEPARATOR}std${CSV_SEPARATOR}-${CSV_SEPARATOR}-${CSV_SEPARATOR}-${CSV_SEPARATOR}" # TODO python version
python testassoc.py --seed 42 --number 1000 | tr -d '\n' # play with number 
echo "" 

javac -d . *.java
echo -n "Java${CSV_SEPARATOR}"
echo -n "java.util.Random.nextFloat()${CSV_SEPARATOR}"
echo -n "-${CSV_SEPARATOR}-${CSV_SEPARATOR}-${CSV_SEPARATOR}" # TODO JDK version
java assoc.TestAssoc basic 1000 | tr -d '\n' # play with number (and seed TODO)
echo ""

echo -n "Java${CSV_SEPARATOR}"
echo -n "Math.random()${CSV_SEPARATOR}"
echo -n "-${CSV_SEPARATOR}-${CSV_SEPARATOR}-${CSV_SEPARATOR}" # TODO JDK version
java assoc.TestAssoc math 1000 | tr -d '\n' # play with number
echo ""

echo -n "Java${CSV_SEPARATOR}"
echo -n "java.util.Random.nextDouble()${CSV_SEPARATOR}"
echo -n "-${CSV_SEPARATOR}-${CSV_SEPARATOR}-${CSV_SEPARATOR}" # TODO JDK version
java assoc.TestAssoc double 1000 | tr -d '\n' # play with number
echo ""


COMPILERS=("gcc" "clang") # TODO: specific flag of clang/gcc like -ffast-math -funsafe-math-optimizations -frounding-math -fsignaling-nans; gcc/clang version
OPTIONS=("-DCUSTOM=1" "" "-DWIN=1 -DCUSTOM=1" "-DWIN=1")
FLAGS=("-DOLD_MAIN_C=1" "")

for compiler in "${COMPILERS[@]}"; do
    for i in {0..3}; do
        for flag in "${FLAGS[@]}"; do
            echo -n "C${CSV_SEPARATOR}"
            case "$i" in
                0)
                    echo -n "custom${CSV_SEPARATOR}Linux${CSV_SEPARATOR}"
                    ;;
                1)
                    echo -n "(srand48+rand48)${CSV_SEPARATOR}Linux${CSV_SEPARATOR}"
                    ;;
                2)
                    echo -n "custom${CSV_SEPARATOR}Windows${CSV_SEPARATOR}"
                    ;;
                3)
                    echo -n "(srand+rand)${CSV_SEPARATOR}Windows${CSV_SEPARATOR}"
                    ;;
            esac

            echo -n "$compiler${CSV_SEPARATOR}"
            echo -n "$flag${CSV_SEPARATOR}" # variability misc
            $compiler -o testassoc testassoc.c ${OPTIONS[$i]} ${flag}
            ./testassoc | tr -d '\n' # play with number of generations (proportions), default value used right now
            echo ""
        done
    done
done


echo -n "Rust${CSV_SEPARATOR}"
echo -n "-${CSV_SEPARATOR}"
echo -n "-${CSV_SEPARATOR}-${CSV_SEPARATOR}-${CSV_SEPARATOR}" # TODO Rust-specific
cargo build --release --quiet 
./target/release/testassoc | tr -d '\n' # play with number
echo ""

