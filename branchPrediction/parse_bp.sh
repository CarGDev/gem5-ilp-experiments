#!/bin/bash
set -eu

ROOT=/home/carlos/projects/gem5/gem5-data/results/bp
printf "%-12s  %10s  %10s  %8s\n" "Predictor" "Acc(%)" "MPKI" "IPC"
for S in "$ROOT"/*/stats.txt; do
  [ -f "$S" ] || continue
  P=$(basename "$(dirname "$S")")
  awk -v P="$P" '
    /branchPred\.lookups/ {L=$2}
    /branchPred\.mispredictions/ {M=$2}
    /^simInsts/ {I=$2}
    /system\.cpu\.numCycles/ {C=$2}
    END{
      acc = (L>0)? 100*(1-M/L) : 0;
      mpki= (I>0)? 1000*M/I   : 0;
      ipc = (C>0)? I/C        : 0;
      printf "%-12s  %10.2f  %10.2f  %8.3f\n", P, acc, mpki, ipc
    }' "$S"
done | sort

