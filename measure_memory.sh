#!/bin/bash

ENGINE=$1       # Path to d8 executable
SCRIPT=$2       # Path to JavaScript benchmark file
ROUNDS=${3:-10} # Number of rounds (default: 10)

if [[ ! -x "$ENGINE" || ! -f "$SCRIPT" ]]; then
  echo "Usage: $0 <d8_path> <script_path> [rounds]"
  exit 1
fi

mems=()

echo "Measuring memory usage for $SCRIPT using $ENGINE, running $ROUNDS rounds..."
echo

for i in $(seq 1 $ROUNDS); do
  echo "Run $i ..."
  # Capture peak memory usage from /usr/bin/time -v output
  mem_kb=$( (/usr/bin/time -v $ENGINE "$SCRIPT") 2>&1 | grep "Maximum resident set size" | awk '{print $6}' )
  mems+=($mem_kb)
done

# Compute average
sum=0
for val in "${mems[@]}"; do
  sum=$((sum + val))
done
avg=$((sum / ROUNDS))

echo
echo "Average peak memory usage: $avg KB"
