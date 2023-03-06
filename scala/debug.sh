function runScalavariants() {

  local ngen="$1"
  local rel_eq="$2"

 
  local cmd_args=(sbt \"run --seed 42 --number ${ngen} --equality-check ${rel_eq}\")
  # local cmd_str=sbt "run --seed 42 --number 1000 --equality-check MultiInv" # $(printf "%s " "${cmd_args[@]}")

  local result_str=$(sbt -warn -Dsbt.log.noformat=true "run --seed 42 --number ${ngen} --equality-check ${rel_eq}")
  # echo "$cmd_str"
  echo "${result_str}"

}

runScalavariants 1000 "MultInv"
