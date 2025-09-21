#!/usr/bin/env sh
set -eu

# Paths (your setup)
GEM5=/home/carlos/projects/gem5/gem5src/gem5
BIN="$GEM5/build/X86/gem5.opt"
SE="$GEM5/configs/deprecated/example/se.py"   # SMT broken here; CMP is fine

# Workloads (one per core)
CMD1=/home/carlos/projects/gem5/gem5-run/memtouch/memtouch
CMD2=/home/carlos/projects/gem5/gem5-run/memtouch/memtouch
CMD3=/bin/ls
CMD4=/bin/echo

ROOT=/home/carlos/projects/gem5/gem5-data/results/smt
mkdir -p "$ROOT"

BP=LTAGE
MAXI=20000000            # 20M insts per experiment
L1I=32kB; L1D=32kB; L2=1MB

run_cfg () {
  NAME=$1
  NCPUS=$2
  CMDS=$3
  OUT="$ROOT/$NAME"
  mkdir -p "$OUT"
  echo "[*] $NAME -> $OUT"

  "$BIN" --outdir="$OUT" \
    "$SE" \
    --cmd="$CMDS" \
    --cpu-type=DerivO3CPU \
    --num-cpus="$NCPUS" \
    --caches --l2cache \
    --l1i_size="$L1I" --l1d_size="$L1D" --l2_size="$L2" \
    --bp-type="$BP" \
    --maxinsts="$MAXI" \
    > "$OUT/simout" 2> "$OUT/simerr"
}

# ST1: 1 core (baseline)
run_cfg ST1 1 "$CMD1"

# CMP2: 2 cores, shared L2 (parallelism via cores)
# Note: pass two commands separated by ';' (se.py maps one per CPU)
run_cfg CMP2 2 "$CMD1;$CMD2"

# CMP4: 4 cores, shared L2
run_cfg CMP4 4 "$CMD1;$CMD2;$CMD3;$CMD4"

echo "[*] CMP sweep complete."
