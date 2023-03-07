#!/bin/sh

CSV_SEPARATOR=','
echo "Language${CSV_SEPARATOR}Library${CSV_SEPARATOR}System${CSV_SEPARATOR}Compiler${CSV_SEPARATOR}VariabilityMisc${CSV_SEPARATOR}NumberGenerations${CSV_SEPARATOR}Score"

GNUMBER_GENERATIONS=1000 # number of generations (global, can be used by any implementation)
REPEAT=10 # number of times to repeat the experiment per variant

# run a command N times and return the min, max, mean, and std of the results
function analyze_results {
  # Set the function parameters
  N=$1
  command=$2

  # Create an array to store the results
  results=()

  # Repeat the command N times and store the results
  for i in $(seq $N); do
      result=`eval $command | tr -d '\n' | tr -d '\r'` # incredible caused by Wine situation: https://superuser.com/questions/1647642/using-variables-with-bc-syntax-error
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

  # Return the result string
  echo "$result_str"
}

function testPYvariants() {
  local test_name="$1"
  local ngen="$2"
  local seed="$3"
  
  local variability_misc="no seed"
  if [ -n "$seed" ]; then
    variability_misc="seed $seed"
  fi
  echo -n "Python${CSV_SEPARATOR}std${CSV_SEPARATOR}-${CSV_SEPARATOR}-${CSV_SEPARATOR}${test_name} ${variability_misc}${CSV_SEPARATOR}${ngen}${CSV_SEPARATOR}" # TODO python version
  local cmd_args=(python testassoc.py --number ${ngen} --equality-check "$test_name")
  if [ -n "$seed" ]; then
    cmd_args+=(--seed "$seed")
  fi
  local cmd_str=$(printf "%s " "${cmd_args[@]}")
  local result_str=$(analyze_results ${REPEAT} "${cmd_str}")
  echo "$result_str"
}

testPYvariants "associativity" $GNUMBER_GENERATIONS
testPYvariants "mult-inverse" $GNUMBER_GENERATIONS
testPYvariants "mult-inverse-pi" $GNUMBER_GENERATIONS

testPYvariants "associativity" $GNUMBER_GENERATIONS 42
testPYvariants "mult-inverse" $GNUMBER_GENERATIONS 42
testPYvariants "mult-inverse-pi" $GNUMBER_GENERATIONS 42


function testJAVAvariants() {
    local test_name="$1"
    local test_cmd="$2"
    echo -n "Java${CSV_SEPARATOR}"
    echo -n "${test_name}${CSV_SEPARATOR}"
    echo -n "-${CSV_SEPARATOR}-${CSV_SEPARATOR}-${CSV_SEPARATOR}${GNUMBER_GENERATIONS}${CSV_SEPARATOR}" # TODO JDK version
    local result_str=$(analyze_results ${REPEAT} "${test_cmd}")
    echo "$result_str"
}


javac -d . *.java # prerequisite (no variability here)
testJAVAvariants "java.util.Random.nextFloat()" "java assoc.TestAssoc basic ${GNUMBER_GENERATIONS}"
testJAVAvariants "Math.random()" "java assoc.TestAssoc math ${GNUMBER_GENERATIONS}"
testJAVAvariants "java.util.Random.nextDouble()" "java assoc.TestAssoc double ${GNUMBER_GENERATIONS}"


function testCvariants() {
    local ngen="$1"

    COMPILERS=("gcc" "clang") # TODO: specific flag of clang/gcc like -ffast-math -funsafe-math-optimizations -frounding-math -fsignaling-nans; gcc/clang version
    OPTIONS=("-DCUSTOM=1" "" "-DWIN=1 -DCUSTOM=1" "-DWIN=1")
    FLAGS=("-DOLD_MAIN_C=1" "")

    for compiler in "${COMPILERS[@]}"; do
        for i in {0..3}; do
            for flag in "${FLAGS[@]}"; do

                
                local cmd_args=(./testassoc $ngen) # default execution command
                # we use wine to run the executable on Windows
                if [[ "$compiler" == "gcc" && "${OPTIONS[$i]}" == *"-DWIN=1"* ]]; then
                    # export WINEDEBUG=-all
                    cmd_args=(wine "./testassoc.exe" $ngen)
                fi

                # if compiler is gcc and options contains -DWIN=1, compiler is i686-w64-mingw32-gcc
                if [[ "$compiler" == "gcc" && "${OPTIONS[$i]}" == *"-DWIN=1"* ]]; then
                    compiler="i686-w64-mingw32-gcc"
                fi


                echo -n "C${CSV_SEPARATOR}"
                case "$i" in
                    0)
                        echo -n "custom${CSV_SEPARATOR}Linux${CSV_SEPARATOR}"
                        ;;
                    1)
                        echo -n "(srand48+drand48)${CSV_SEPARATOR}Linux${CSV_SEPARATOR}"
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
                echo -n "${ngen}${CSV_SEPARATOR}"
                # building 
                $compiler -o testassoc testassoc.c ${OPTIONS[$i]} ${flag} # TODO: should be compile N times?
                
                
                local cmd_str=$(printf "%s " "${cmd_args[@]}")
                local result_str=$(analyze_results ${REPEAT} "${cmd_str}")           
                echo "$result_str"
            done
        done
    done
}

testCvariants $GNUMBER_GENERATIONS

# Define function to run a Rust variant test and output result
run_RSvariant() {
    local feature=$1
    local ngen=$2
    local error_margin=$3
    

    # Run test with error margin if provided
    if [[ -n $error_margin ]]; then
        echo -n "Rust${CSV_SEPARATOR}"
        echo -n "-${CSV_SEPARATOR}"
        echo -n "-${CSV_SEPARATOR}-${CSV_SEPARATOR}${feature} --error_margin ${error_margin}${CSV_SEPARATOR}${ngen}${CSV_SEPARATOR}"
        local cmd_args=(cargo run --features "$feature" -q -- --error_margin "$error_margin")
    else
        echo -n "Rust${CSV_SEPARATOR}"
        echo -n "-${CSV_SEPARATOR}"
        echo -n "-${CSV_SEPARATOR}-${CSV_SEPARATOR}${feature} (no error margin ie pure equality)${CSV_SEPARATOR}${ngen}${CSV_SEPARATOR}"
        local cmd_args=(cargo run --features "$feature" -q --)
    fi

    local cmd_str=$(printf "%s " "${cmd_args[@]}")
    local result_str=$(analyze_results ${REPEAT} "${cmd_str}")
    echo "$result_str"
}


# Call the function for each test
run_RSvariant "associativity" $GNUMBER_GENERATIONS "0.000000000000001" 
run_RSvariant "mult_inverse" $GNUMBER_GENERATIONS "0.000000000000001" 
run_RSvariant "mult_inverse_pi" $GNUMBER_GENERATIONS "0.000000000000001" 
run_RSvariant "associativity" $GNUMBER_GENERATIONS
run_RSvariant "mult_inverse" $GNUMBER_GENERATIONS
run_RSvariant "mult_inverse_pi" $GNUMBER_GENERATIONS

function testLISPvariants() {
    local ngen="$1"
    echo -n "LISP${CSV_SEPARATOR}"
    echo -n "-${CSV_SEPARATOR}"
    echo -n "-${CSV_SEPARATOR}-${CSV_SEPARATOR}-${CSV_SEPARATOR}${ngen}${CSV_SEPARATOR}" # TODO LISP specific
    local cmd_args=(sbcl --noinform --quit --load test_assoc.lisp) # play with number
    local cmd_str=$(printf "%s " "${cmd_args[@]}")
    local result_str=$(analyze_results ${REPEAT} "${cmd_str}")           
    echo "$result_str"
}

testLISPvariants 42000 # TODO: play with number of generations (proportions), default value used right now




SEED="42"

function run_JStest() {
  local check="$1"
  local with_gseed="$2"
  local ngen="$3"

  echo -n "JavaScript${CSV_SEPARATOR}"
  echo -n "-${CSV_SEPARATOR}"
  if [[ "$with_gseed" = true ]]; then
    echo -n "-${CSV_SEPARATOR}-${CSV_SEPARATOR}${check} global seed${CSV_SEPARATOR}${ngen}${CSV_SEPARATOR}"
  else
    echo -n "-${CSV_SEPARATOR}-${CSV_SEPARATOR}${check}${CSV_SEPARATOR}${ngen}${CSV_SEPARATOR}"
  fi
  
  
  local npm_args=(--prefix js/ --silent -- --equality-check "${check}" --seed "${SEED}" --number "${ngen}") # TODO: play with number
  if [[ "$with_gseed" = true ]]; then
    npm_args+=(--with-gseed)
  fi
  
  npm_args_str=$(printf "%s " "${npm_args[@]}")
  # eval "npm start ${npm_args_str}"
  result_str=$(analyze_results ${REPEAT} "npm start ${npm_args_str}")
  echo "$result_str"
}

run_JStest "associativity" true $GNUMBER_GENERATIONS
run_JStest "mult_inverse" true $GNUMBER_GENERATIONS
run_JStest "mult_inverse_pi" true $GNUMBER_GENERATIONS
run_JStest "associativity" false $GNUMBER_GENERATIONS
run_JStest "mult_inverse" false $GNUMBER_GENERATIONS
run_JStest "mult_inverse_pi" false $GNUMBER_GENERATIONS




function runBASHvariants() {

  local ngen="$1"
  local rel_eq="$2"

  echo -n "Bash${CSV_SEPARATOR}"
  echo -n "-${CSV_SEPARATOR}"
  echo -n "-${CSV_SEPARATOR}-${CSV_SEPARATOR}${rel_eq}${CSV_SEPARATOR}${ngen}${CSV_SEPARATOR}"
  
  local cmd_args=(sh testassoc.sh -n ${ngen} -e ${rel_eq}) # play with number
  local cmd_str=$(printf "%s " "${cmd_args[@]}")
  local result_str=$(analyze_results ${REPEAT} "${cmd_str}")
  
  echo "$result_str"

}

# TODO fix number of generations, Bash is quite slow
runBASHvariants 10 "associativity"
runBASHvariants 10 "mult_inverse"
runBASHvariants 10 "mult_inverse_pi"

function runScalavariants() {

  local ngen="$1"
  local rel_eq="$2"

  echo -n "Scala${CSV_SEPARATOR}"
  echo -n "-${CSV_SEPARATOR}"
  echo -n "-${CSV_SEPARATOR}-${CSV_SEPARATOR}${rel_eq}${CSV_SEPARATOR}${ngen}${CSV_SEPARATOR}"

  local cmd_str=$(printf "%s \"%s\"" "sbt -warn -Dsbt.log.noformat=true" "run --seed 42 --number ${ngen} --equality-check ${rel_eq}")
  local result_str=$(analyze_results ${REPEAT} "${cmd_str}")


  echo "${result_str}"

}

cd scala
runScalavariants $GNUMBER_GENERATIONS "Associativity"
runScalavariants $GNUMBER_GENERATIONS "MultInv"
runScalavariants $GNUMBER_GENERATIONS "MultInvPi"
cd - > /dev/null

