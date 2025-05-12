#!/bin/bash

# Configuration
ENGINE_PATH=$1              # Path to d8 executable
SCRIPT_PATH=$2              # Path to JavaScript test script
ROUNDS=${3:-10}             # Number of test rounds, default is 10

if [[ ! -x "$ENGINE_PATH" || ! -f "$SCRIPT_PATH" ]]; then
  echo "Usage: $0 <d8_path> <script_path> [rounds]"
  exit 1
fi

# Initialize result arrays
real_times=()
user_times=()
sys_times=()

echo "Running benchmark for $SCRIPT_PATH using $ENGINE_PATH, total $ROUNDS rounds:"
echo

for i in $(seq 1 $ROUNDS); do
  echo "Round $i..."
  output=$( { /usr/bin/time -f "real=%e user=%U sys=%S" $ENGINE_PATH "$SCRIPT_PATH"; } 2>&1 )

  # Extract timing results
  real=$(echo "$output" | grep real | cut -d= -f2)
  user=$(echo "$output" | grep user | cut -d= -f2)
  sys=$(echo "$output" | grep sys | cut -d= -f2)

  real_times+=($real)
  user_times+=($user)
  sys_times+=($sys)
done

# Function: calculate average and standard deviation
calc_stats() {
  local arr=("$@")
  local sum=0
  local n=${#arr[@]}

  for val in "${arr[@]}"; do
    sum=$(echo "$sum + $val" | bc)
  done

  avg=$(echo "scale=4; $sum / $n" | bc)

  sq_sum=0
  for val in "${arr[@]}"; do
    diff=$(echo "$val - $avg" | bc)
    sq_sum=$(echo "$sq_sum + ($diff * $diff)" | bc)
  done

  std=$(echo "scale=4; sqrt($sq_sum / $n)" | bc -l)
  echo "$avg (  $std)"
}

# Output statistics
echo
echo "Benchmark results (unit: seconds):"
echo "Real time: $(calc_stats "${real_times[@]}")"
echo "User time: $(calc_stats "${user_times[@]}")"
echo "Sys  time: $(calc_stats "${sys_times[@]}")"
