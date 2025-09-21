#!/usr/bin/env bash
set -eu

# --- Paths (match your cache script style) ---
export GEM5=/home/carlos/projects/gem5/gem5src/gem5
export RUN=/home/carlos/projects/gem5/gem5-run
export OUTROOT=/home/carlos/projects/gem5/gem5-data/results

# Workload (reuse your memtouch; swap for any x86 bin you like)
CMD="$RUN/memtouch/memtouch"
[ -x "$CMD" ] || CMD="/bin/ls"

# Convenience
BIN="$GEM5/build/X86/gem5.opt"
SEPY="$GEM5/configs/deprecated/example/se.py"

# ------------- 1) Baseline O3 run -------------
OUT="$OUTROOT/pipeline/o3-baseline"
mkdir -p "$OUT"
"$BIN" \
  --outdir="$OUT" \
  "$SEPY" \
  --cmd="$CMD" \
  --cpu-type=DerivO3CPU \
  --cpu-clock=2GHz --sys-clock=2GHz \
  --caches --l2cache \
  --l1i_size=32kB --l1d_size=32kB --l2_size=1MB \
  --maxinsts=200000000

echo "[baseline] stats: $OUT/stats.txt"
awk '
/simInsts/ {I=$2}
/system\.cpu\.numCycles/ {C=$2}
END{if(C>0) printf("Baseline IPC = %.3f  (insts=%s cycles=%s)\n", I/C, I, C)}' \
  "$OUT/stats.txt"

# ------------- 2) Cycle-by-cycle trace -------------
OUT="$OUTROOT/pipeline/o3-trace"
mkdir -p "$OUT"
"$BIN" \
  --outdir="$OUT" \
  --debug-flags=O3CPU,Fetch,Decode,Rename,IEW,Commit,Branch,Activity \
  --debug-file=pipe.trace \
  "$SEPY" \
  --cmd="$CMD" \
  --cpu-type=DerivO3CPU \
  --cpu-clock=2GHz --sys-clock=2GHz \
  --caches --l2cache \
  --maxinsts=5000000

echo "[trace] debug trace: $OUT/pipe.trace"
echo "[trace] quick peek:"
grep -E 'Fetch|Decode|Rename|IEW|Commit|Branch' "$OUT/pipe.trace" | head -60

echo "[trace] stage/queue highlights:"
egrep 'iq|ROB|LQ|SQ|idleCycles' "$OUT/stats.txt" | sed -n '1,200p'

