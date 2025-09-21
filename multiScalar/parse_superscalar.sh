#!/bin/bash
set -eu

ROOT=/home/carlos/projects/gem5/gem5-data/results/superscalar
printf "%-4s %8s %10s %10s\n" "W" "IPC" "L1D MPKI" "Br MPKI"
for S in "$ROOT"/*/stats.txt; do
  [ -f "$S" ] || continue
  W=$(basename "$(dirname "$S")" | sed 's/^W//')
  awk -v W="$W" '
    /^simInsts/                             {I=$2}
    /system\.cpu\.numCycles/                {C=$2}
    /system\.l1d\.overall_misses::total/    {Dm=$2}
    /branchPred\.mispredictions/            {Bm=$2}
    /branchPred\.lookups/                   {Bl=$2}
    END{
      ipc=(C>0)? I/C : 0;
      dmpki=(I>0)? 1000*Dm/I : 0;
      bmpki=(I>0)? 1000*Bm/I : 0;
      printf "%-4s %8.3f %10.2f %10.2f\n", W, ipc, dmpki, bmpki
    }' "$S"
done | sort -n

