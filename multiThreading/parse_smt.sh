#!/bin/bash
set -eu

# Configuration
ROOT="${1:-${PWD}/results}"
OUTPUT_FILE="${2:-}"

# Function to print header
print_header() {
    printf "%-6s %8s %12s %12s %12s %12s %12s %12s %s\n" \
        "Config" "IPC" "CPI" "L1D MPKI" "L1I MPKI" "L2 MPKI" "Br MPKI" "Cache Util%" "Per-thread Stats"
    printf "%-6s %8s %12s %12s %12s %12s %12s %12s %s\n" \
        "------" "---" "---" "---------" "---------" "---------" "---------" "---------" "---------------"
}

# Function to analyze a single configuration
analyze_config() {
    local D="$1"
    local S="$D/stats.txt"
    local Cfg=$(basename "$D")
    
    if [ ! -s "$S" ]; then
        printf "%-6s %8s %12s %12s %12s %12s %12s %12s %s\n" \
            "$Cfg" "-" "-" "-" "-" "-" "-" "-" "-" "RUNNING/EMPTY"
        return
    fi
    
    awk -v CFG="$Cfg" '
    BEGIN {
        I=C=Dm=Im=L2m=Bm=Bl=0
        L1D_hits=L1D_misses=L1I_hits=L1I_misses=L2_hits=L2_misses=0
        delete T
    }
    /^simInsts/                              {I=$2}
    /system\.cpu\.numCycles/                 {C=$2}
    /system\.l1d\.overall_misses::total/     {Dm=$2}
    /system\.l1i\.overall_misses::total/     {Im=$2}
    /system\.l2\.overall_misses::total/      {L2m=$2}
    /branchPred\.mispredictions/             {Bm=$2}
    /branchPred\.lookups/                    {Bl=$2}
    /system\.l1d\.overall_hits::total/       {L1D_hits=$2}
    /system\.l1i\.overall_hits::total/       {L1I_hits=$2}
    /system\.l2\.overall_hits::total/        {L2_hits=$2}
    /commit\.committedInsts::([0-9]+)/       {tid=$1; gsub(/.*::/,"",tid); T[tid]=$2}
    END{
        # Calculate metrics
        ipc=(C>0)? I/C : 0;
        cpi=(I>0)? C/I : 0;
        dmpki=(I>0)? 1000*Dm/I : 0;
        impki=(I>0)? 1000*Im/I : 0;
        l2mpki=(I>0)? 1000*L2m/I : 0;
        bmpki=(I>0)? 1000*Bm/I : 0;
        
        # Calculate cache utilization
        l1d_total=L1D_hits+L1D_misses;
        l1d_util=(l1d_total>0)? (L1D_hits/l1d_total)*100 : 0;
        
        # Format per-thread counts
        out="";
        thread_count=0;
        for (t in T) { 
            if (thread_count>0) out = out " ";
            out = out "t" t "=" T[t];
            thread_count++;
        }
        if (thread_count==0) out="single-thread";
        
        printf "%-6s %8.3f %12.2f %12.2f %12.2f %12.2f %12.2f %12.1f %s\n", 
            CFG, ipc, cpi, dmpki, impki, l2mpki, bmpki, l1d_util, out;
    }' "$S"
}

# Main execution
if [ -n "$OUTPUT_FILE" ]; then
    exec > "$OUTPUT_FILE"
fi

echo "SMT Performance Analysis Report"
echo "Generated: $(date)"
echo "Results directory: $ROOT"
echo ""

print_header

# Process all configuration directories
for D in "$ROOT"/*; do
    [ -d "$D" ] || continue
    analyze_config "$D"
done | sort

echo ""
echo "Legend:"
echo "  IPC    = Instructions Per Cycle"
echo "  CPI    = Cycles Per Instruction" 
echo "  MPKI   = Misses Per Kilo Instructions"
echo "  Cache Util% = L1D Cache Hit Rate"
echo "  Per-thread Stats = Instructions committed per thread"

