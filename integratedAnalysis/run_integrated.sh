#!/bin/bash
set -eu

###############################################################################
# Integrated ILP experiment: Branch Prediction × Superscalar Width × SMT
# Layout matches your environment.
###############################################################################

# --- Paths (adapt to your tree if needed) ------------------------------------
GEM5=/home/carlos/projects/gem5/gem5src/gem5
BIN="$GEM5/build/X86/gem5.opt"
SE="$GEM5/configs/deprecated/example/se.py"

# Workloads for SMT threads (use your binaries/args here).
# For SMT>1 we pass them joined with ';' so se.py creates multiple thread contexts
CMD1=/home/carlos/projects/gem5/gem5-run/memtouch/memtouch
CMD2=/home/carlos/projects/gem5/gem5-run/memtouch/memtouch
CMD3=/bin/ls
CMD4=/bin/ls

ROOT=/home/carlos/projects/gem5/gem5-data/results/integrated
mkdir -p "$ROOT"

# --- Global constants (kept fixed across runs to be comparable) --------------
MAXI=20000000      # limit committed instructions per run (finish in reasonable time)
L1I=32kB; L1D=32kB; L2=1MB    # keep memory hierarchy constant across runs

# NOTE: Use `$SE --list-bp-types` to confirm these names in your build.
BP_LIST="LocalBP BiModeBP TournamentBP LTAGE"
W_LIST="1 2 4"     # superscalar widths (fetch/decode/rename/issue/commit)
T_LIST="1 2 4"     # SMT hardware threads on ONE physical core

# --- Helper: build command string for T threads -------------------------------
mk_cmds () {
  T="$1"
  case "$T" in
    1) echo "$CMD1" ;;
    2) echo "$CMD1;$CMD2" ;;
    4) echo "$CMD1;$CMD2;$CMD3;$CMD4" ;;
    *) echo "$CMD1" ;;
  esac
}

for BP in $BP_LIST; do
  for W in $W_LIST; do
    # Scale the core buffers with width (simple heuristic).
    ROB=$((W*64))   # Reorder Buffer entries
    IQ=$((W*32))    # Issue Queue entries
    LQ=$((W*32))    # Load Queue
    SQ=$((W*32))    # Store Queue

    for T in $T_LIST; do
      # Directory name encodes the three dimensions
      OUT="$ROOT/BP-${BP}/W${W}/SMT${T}"
      mkdir -p "$OUT"
      echo "[*] BP=$BP  W=$W  SMT=$T  ->  $OUT"

      # Build per-run command list for thread contexts
      CMDS="$(mk_cmds "$T")"

      # ------------------------- RUN -----------------------------------------
      # Key flags explained (use these lines in your report):
      #   --bp-type=<BP>                 choose branch predictor implementation
      #   --caches --l2cache             enable private L1I/L1D and a unified L2
      #   --l1i_size/--l1d_size/--l2_size keep memory fixed across runs
      #   --maxinsts=<N>                 stop after N committed insts (fairness)
      #   --smt --num-cpus=1             single O3 core exposing T HW threads
      #   --param system.cpu[0].*        set per-CPU (index 0) microarch widths
      #   fetch/decode/rename/issue/commitWidth = W (superscalar width)
      #   ROB/IQ/LQ/SQ entries scaled with W to avoid artificial stalls
      # -----------------------------------------------------------------------

      "$BIN" --outdir="$OUT" \
        "$SE" \
        --cmd="$CMDS" \
        --cpu-type=DerivO3CPU \
        --caches --l2cache \
        --l1i_size="$L1I" --l1d_size="$L1D" --l2_size="$L2" \
        --bp-type="$BP" \
        --maxinsts="$MAXI" \
        --num-cpus=1 $([ "$T" -gt 1 ] && echo --smt) \
        \
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
        echo "    ok: $OUT/stats.txt"
      else
        echo "    FAILED/RUNNING — see $OUT/simerr"
      fi
    done
  done
done

echo "[*] Integrated sweep complete."

