#!/bin/bash
set -eu

GEM5=/home/carlos/projects/gem5/gem5src/gem5
BIN="$GEM5/build/X86/gem5.opt"
SE="$GEM5/configs/deprecated/example/se.py"
RUNROOT=/home/carlos/projects/gem5/gem5-data/results/bp
CMD=/home/carlos/projects/gem5/gem5-run/memtouch/memtouch
mkdir -p "$RUNROOT"

# Adjust this list to whatever `"$SE" --list-bp-types` prints on your build
PRED_LIST="LocalBP TournamentBP BiModeBP LTAGE"

for P in $PRED_LIST; do
  OUT="$RUNROOT/$P"
  mkdir -p "$OUT"
  echo "[*] Running $P -> $OUT"
  "$BIN" --outdir="$OUT" \
    "$SE" --cmd="$CMD" \
    --cpu-type=DerivO3CPU --caches --l2cache \
    --bp-type="$P" --maxinsts=50000000 \
    > "$OUT/simout" 2> "$OUT/simerr"
done
echo "[*] Done."
