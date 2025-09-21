#!/bin/bash
set -eu
ROOT=/home/carlos/projects/gem5/gem5-data/results/integrated

printf "%-10s %-3s %-4s %8s %10s %10s  %s\n" "BP" "W" "T" "IPC" "L1D MPKI" "Br MPKI" "Per-thread committed"
find "$ROOT" -name stats.txt | while read -r S; do
  # decode BP/W/T from path: .../BP-<BP>/W<W>/SMT<T>/stats.txt
  BP=$(echo "$S" | sed -n 's#.*/BP-\([^/]*\)/.*#\1#p')
  W=$(echo "$S" | sed -n 's#.*/W\([0-9]*\)/.*#\1#p')
  T=$(echo "$S" | sed -n 's#.*/SMT\([0-9]*\)/.*#\1#p')
  awk -v BP="$BP" -v W="$W" -v T="$T" '
    /^simInsts/                              {I=$2}
    /system\.cpu\.numCycles/                 {C=$2}
    /system\.l1d\.overall_misses::total/     {Dm=$2}
    /branchPred\.mispredictions/             {Bm=$2}
    /branchPred\.lookups/                    {Bl=$2}
    /commit\.committedInsts::([0-9]+)/       {tid=$1; gsub(/.*::/,"",tid); Tcommit[tid]=$2}
    END{
      ipc=(C>0)? I/C : 0;
      dmpki=(I>0)? 1000*Dm/I : 0;
      bmpki=(I>0)? 1000*Bm/I : 0;
      per="";
      for (t in Tcommit) per=per "t" t "=" Tcommit[t] " ";
      printf "%-10s %-3s %-4s %8.3f %10.2f %10.2f  %s\n", BP, W, T, ipc, dmpki, bmpki, per;
    }' "$S"
done | sort -k1,1 -k2,2n -k3,3n

