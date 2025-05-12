#!/bin/bash

OUTPUT_FILE="benchmark_results.txt"
echo "V8 Benchmark Results" > "$OUTPUT_FILE"
echo "====================" >> "$OUTPUT_FILE"

D8_RELEASE="out/release/d8"
D8_HARDENED="out/hardened/d8"
TEST_JS="test/benchmarks/data/octane/mandreel.js"

# Throughput
echo -e "\n[Throughput Benchmark] RELEASE" >> "$OUTPUT_FILE"
for i in {1..5}; do
  echo "Run $i" >> "$OUTPUT_FILE"
  tools/run-tests.py benchmarks --outdir=out/release --shell=$D8_RELEASE --time >> "$OUTPUT_FILE" 2>&1
done

echo -e "\n[Throughput Benchmark] HARDENED" >> "$OUTPUT_FILE"
for i in {1..5}; do
  echo "Run $i" >> "$OUTPUT_FILE"
  tools/run-tests.py benchmarks --outdir=out/hardened --shell=$D8_HARDENED --time >> "$OUTPUT_FILE" 2>&1
done

# Latency
echo -e "\n[Latency Benchmark] RELEASE" >> "$OUTPUT_FILE"
for i in {1..5}; do
  echo "Run $i" >> "$OUTPUT_FILE"
  ./measure_latency.sh $D8_RELEASE $TEST_JS 10 >> "$OUTPUT_FILE" 2>&1
done

echo -e "\n[Latency Benchmark] HARDENED" >> "$OUTPUT_FILE"
for i in {1..5}; do
  echo "Run $i" >> "$OUTPUT_FILE"
  ./measure_latency.sh $D8_HARDENED $TEST_JS 10 >> "$OUTPUT_FILE" 2>&1
done

# Memory
echo -e "\n[Memory Benchmark] RELEASE" >> "$OUTPUT_FILE"
for i in {1..5}; do
  echo "Run $i" >> "$OUTPUT_FILE"
  ./measure_memory.sh $D8_RELEASE $TEST_JS 10 >> "$OUTPUT_FILE" 2>&1
done

echo -e "\n[Memory Benchmark] HARDENED" >> "$OUTPUT_FILE"
for i in {1..5}; do
  echo "Run $i" >> "$OUTPUT_FILE"
  ./measure_memory.sh $D8_HARDENED $TEST_JS 10 >> "$OUTPUT_FILE" 2>&1
done

# perf stat
echo -e "\n[Hardware Counters: perf stat] RELEASE" >> "$OUTPUT_FILE"
for i in {1..5}; do
  echo "Run $i" >> "$OUTPUT_FILE"
  perf stat -e dTLB-load-misses,branch-misses $D8_RELEASE $TEST_JS >> "$OUTPUT_FILE" 2>&1
done

echo -e "\n[Hardware Counters: perf stat] HARDENED" >> "$OUTPUT_FILE"
for i in {1..5}; do
  echo "Run $i" >> "$OUTPUT_FILE"
  perf stat -e dTLB-load-misses,branch-misses $D8_HARDENED $TEST_JS >> "$OUTPUT_FILE" 2>&1
done

echo -e "\n All benchmarks completed. Results saved to $OUTPUT_FILE"
