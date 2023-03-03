#!/bin/sh

# TODO: repeat N times the experiments and report std/mean/min/max in the Score

# TODO number as a column 

CSV_SEPARATOR=','
echo "Language${CSV_SEPARATOR}Library${CSV_SEPARATOR}System${CSV_SEPARATOR}Compiler${CSV_SEPARATOR}VariabilityMisc${CSV_SEPARATOR}Score"


# run a command N times and return the min, max, mean, and std of the results
function analyze_results {
  # Set the function parameters
  N=$1
  command=$2

  # Create an array to store the results
  results=()

  # Repeat the command N times and store the results
  for i in $(seq $N); do
      result=$($command | tr -d '\n')
      results+=("$result")
  done

  # Calculate the min, max, mean, and std of the results
  min=$(echo "${results[@]}" | tr ' ' '\n' | sed 's/%//g' | sort -n | head -n 1)
  max=$(echo "${results[@]}" | tr ' ' '\n' | sed 's/%//g' | sort -n | tail -n 1)
  sum=$(echo "${results[@]}" | tr ' ' '\n' | sed 's/%//g' | awk '{s+=$1} END {print s}')
  
  if [ $N -eq 0 ]; then
    mean=0
  else
    mean=$(echo "scale=2; $sum / $N" | bc)
  fi

  # std
  sumsq=0
  for i in "${results[@]}"; do
    sumsq=$(echo "scale=2; $sumsq + ($i - $mean)^2" | bc)
  done
  if [ $N -eq 0 ]; then
    std=0
  else
    std=$(echo "scale=2; sqrt($sumsq / $N)" | bc)
  fi


  # Build a string containing the results
  result_str="Min: $min% Max: $max% Mean: $mean% Std: $std"
  # result_str="Min: $min% Max: $max% Mean: $mean%"

  # Return the result string
  echo "$result_str"
}

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


# Define function to run a Rust variant test and output result
run_RSvariant() {
    local feature=$1
    local error_margin=$2

    # Run test with error margin if provided
    if [[ -n $error_margin ]]; then
        echo -n "Rust${CSV_SEPARATOR}"
        echo -n "-${CSV_SEPARATOR}"
        echo -n "-${CSV_SEPARATOR}-${CSV_SEPARATOR} --error_margin ${error_margin}${CSV_SEPARATOR}"
        local cmd_args=(cargo run --features "$feature" -q -- --error_margin "$error_margin")
    else
        echo -n "Rust${CSV_SEPARATOR}"
        echo -n "-${CSV_SEPARATOR}"
        echo -n "-${CSV_SEPARATOR}-${CSV_SEPARATOR} (no error margin ie pure equality)${CSV_SEPARATOR}"
        local cmd_args=(cargo run --features "$feature" -q --)
    fi

    local cmd_str=$(printf "%s " "${cmd_args[@]}")
    local result_str=$(analyze_results 10 "${cmd_str}")
    echo "$result_str"

    echo "" # Output newline at the end
}


# Call the function for each test
run_RSvariant "associativity" "0.000000000000001"
run_RSvariant "mult_inverse" "0.000000000000001"
run_RSvariant "mult_inverse_pi" "0.000000000000001"
run_RSvariant "associativity"
run_RSvariant "mult_inverse"
run_RSvariant "mult_inverse_pi"


echo -n "LISP${CSV_SEPARATOR}"
echo -n "-${CSV_SEPARATOR}"
echo -n "-${CSV_SEPARATOR}-${CSV_SEPARATOR}-${CSV_SEPARATOR}" # TODO LISP specific
sbcl --noinform --quit --load test_assoc.lisp | tr -d '\n' # play with number
echo ""




SEED="42"

function run_JStest() {
  local check="$1"
  local with_gseed="$2"

  echo -n "JavaScript${CSV_SEPARATOR}"
  echo -n "-${CSV_SEPARATOR}"
  if [[ "$with_gseed" = true ]]; then
    echo -n "-${CSV_SEPARATOR}-${CSV_SEPARATOR}${check} global seed${CSV_SEPARATOR}"
  else
    echo -n "-${CSV_SEPARATOR}-${CSV_SEPARATOR}${check}${CSV_SEPARATOR}"
  fi
  
  
  local npm_args=(--prefix js/ --silent -- --equality-check "${check}" --seed "${SEED}")
  if [[ "$with_gseed" = true ]]; then
    npm_args+=(--with-gseed)
  fi
  
  npm_args_str=$(printf "%s " "${npm_args[@]}")
  # eval "npm start ${npm_args_str}"
  result_str=$(analyze_results 10 "npm start ${npm_args_str}")
  echo "$result_str"
}

run_JStest "associativity" true
run_JStest "mult_inverse" true
run_JStest "mult_inverse_pi" true
run_JStest "associativity" false
run_JStest "mult_inverse" false
run_JStest "mult_inverse_pi" false

# TODO: playing with npm version and randomseed version!
# result_str=$(analyze_results 10 "npm start --prefix js/ --silent -- --equality-check associativity --seed 42 --with-gseed")
# echo "$result_str"




