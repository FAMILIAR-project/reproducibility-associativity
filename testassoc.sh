#!/bin/bash

# Define equality check options as variables
ASSOCIATIVITY="associativity"
MULT_INVERSE="mult_inverse"
MULT_INVERSE_PI="mult_inverse_pi"

# Define associativityTest function
# takes a while with high number of generations

# Pi can be computed once and for all and then used in the test
pi=$(echo "scale=10; 4*a(1)" | bc -l)

# TODO: seed with $RANDOM 

associativityTest() {
  local option=$1
  local x=$(echo "scale=10; $RANDOM / 32767" | bc -l)
  local y=$(echo "scale=10; $RANDOM / 32767" | bc -l)
  local z=$(echo "scale=10; $RANDOM / 32767" | bc -l)
  
  if [ "$option" = "$ASSOCIATIVITY" ]; then
    test=$(echo "$x + ($y + $z) == ($x + $y) + $z" | bc -l)
    [ $test -eq 1 ] && echo "1" || echo "0"
  elif [ "$option" = "$MULT_INVERSE" ]; then
    test=$(echo "$x * $z / ($y * $z) == $x / $y" | bc -l)
    [ $test -eq 1 ] && echo "1" || echo "0"
  elif [ "$option" = "$MULT_INVERSE_PI" ]; then
    test=$(echo "$x * $z * $pi / ($y * $z * $pi) == $x / $y" | bc -l)
    [ $test -eq 1 ] && echo "1" || echo "0"
  else
    echo "Invalid option" >&2
    exit 1
  fi
}

# Define proportion function
proportion() {
  local number=$1
  local option=$2
  
  local ok=0
  for (( i=0; i<$number; i++ )); do
    ok=$((ok + $(associativityTest $option)))
  done
  
  echo "$(echo "scale=2; $ok * 100 / $number" | bc -l)%"
}

# Parse command-line arguments using 'getopts'
while getopts ":n:e:" opt; do
  case $opt in
    n)
      number=$OPTARG
      ;;
    e)
      equality_check=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument" >&2
      exit 1
      ;;
  esac
done

# Call the proportion function with the parsed command-line arguments
proportion ${number:-10000} ${equality_check:-$ASSOCIATIVITY}
