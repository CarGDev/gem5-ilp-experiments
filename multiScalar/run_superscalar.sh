#!/bin/bash
set -eu

GEM5=/home/carlos/projects/gem5/gem5src/gem5
BIN="$GEM5/build/X86/gem5.opt"
SE="$GEM5/configs/deprecated/example/se.py"
CMD=/home/carlos/projects/gem5/gem5-run/memtouch/memtouch

ROOT=/home/carlos/projects/gem5/gem5-data/results/superscalar
mkdir -p "$ROOT"

BP=LTAGE          # strong predictor so control hazards don't mask width effects
MAXI=20000000     # 20M to finish faster; keep constant across configs

for W in 1 2 4 8; do
  OUT="$ROOT/W$W"; mkdir -p "$OUT"
  echo "[*] W=$W -> $OUT"

  ROB=$((W*32))
  IQ=$((W*16))
  LQ=$((W*16))
  SQ=$((W*16))

  "$BIN" --outdir="$OUT" \
    "$SE" --cmd="$CMD" \
    --cpu-type=DerivO3CPU --caches --l2cache \
    --bp-type="$BP" --maxinsts="$MAXI" \
    --param "system.cpu[0].fetchWidth=$W" \
    --param "system.cpu[0].decodeWidth=$W" \
    --param "system.cpu[0].renameWidth=$W" \
    --param "system.cpu[0].issueWidth=$W" \
    --param "system.cpu[0].commitWidth=$W" \
    --param "system.cpu[0].numROBEntries=$ROB" \
    --param "system.cpu[0].numIQEntries=$IQ" \
    --param "system.cpu[0].LQEntries=$LQ" \
    --param "system.cpu[0].SQEntries=$SQ" \
    > "$OUT/simout" 2> "$OUT/simerr"

  if [ -s "$OUT/stats.txt" ]; then
    echo "  ok: $OUT/stats.txt"
  else
    echo "  FAILED/RUNNING — check $OUT/simerr"
  fi
done

echo "[*] Superscalar sweep complete."

