function analyze_results {
  # Set the function parameters
  N=$1
  command=$2

  # Create an array to store the results
  results=()
  # echo $N
  # echo $command
  # echo `eval $command`
  # Repeat the command N times and store the results
  for i in $(seq $N); do
      result=`eval $command` # incredible caused by Wine situation: https://superuser.com/questions/1647642/using-variables-with-bc-syntax-error
      results+=("$result")
  done

  echo ${results[@]}
  
}

REPEAT=2

function runScalavariants() {

  local ngen="$1"
  local rel_eq="$2"

 
  local cmd_args=(sbt \"run --seed 42 --number ${ngen} --equality-check ${rel_eq}\")
  # local cmd_str=sbt "run --seed 42 --number 1000 --equality-check MultiInv" # $(printf "%s " "${cmd_args[@]}")

  local cmd_str=$(printf "%s \"%s\"" "sbt -warn -Dsbt.log.noformat=true" "run --seed 42 --number ${ngen} --equality-check ${rel_eq}")
  # local result_str=$(sbt -warn -Dsbt.log.noformat=true "run --seed 42 --number ${ngen} --equality-check ${rel_eq}")
  # echo "$cmd_str"
  # local result_str=`eval ${cmd_str}`
  echo $cmd_str
  local result_str=$(analyze_results ${REPEAT} "${cmd_str}")
  echo "${result_str}"

}

runScalavariants 1000 "MultInv"
