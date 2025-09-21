# Pipeline Simulation

## Set up and configuration in Gem5.

To begin the project, a script was created to configure and launch the baseline pipeline in Gem5. The simulation was executed on the X86 DerivO3CPU model with a 2 GHz CPU and system clock, 32 KB L1 instruction and data caches, and a unified 1 MB L2 cache. The benchmark program used was memtouch, run in syscall emulation mode. The script defined output directories, cache parameters, and execution limits, ensuring reproducibility of the setup.

## Output after running the command

The initial run produced a baseline performance snapshot. The measured IPC was ~0.05 (CPI ≈ 19.7), indicating extremely low throughput. Nearly 97% of cycles retired no instructions, showing that the pipeline was heavily stalled. Analysis of memory system statistics revealed an L1D miss rate close to 50%, with an average miss latency of ~78,000 ticks. These misses frequently propagated through the pipeline, creating bubbles and stalling progress. In contrast, branch prediction worked effectively, with a misprediction rate below 0.05%.

## Cycle-by-cycle analysis of pipeline stages.

Cycle-level tracing (via --debug-flags=O3CPU,Fetch,Decode,Rename,IEW,Commit,Branch) revealed the interactions of the pipeline stages. The traces show frequent stalls at IEW and Commit, triggered by long-latency load misses that blocked dependent instructions. Fetch and Decode also experienced backpressure as the backend filled, illustrating how memory bottlenecks propagate through the pipeline. Overall, the cycle-by-cycle view confirmed that the pipeline’s performance limit was not due to execution width or branch handling, but due to structural and data hazards in the memory system. s

|Metric|Value|Interpretation|
|---|---|---|
|Total Instructions (simInsts)|25,297,289|Benchmark retired ~25M instructions|
|Total Cycles (numCycles)|498,254,810|Simulation ran ~498M cycles|
|IPC|0.051|Very low throughput (pipeline mostly stalled)|
|CPI|19.74|Each instruction took ~20 cycles on average|
|Commit Histogram|~97% cycles at 0 commit|Pipeline idle most of the time (waiting on memory)|
|L1I Miss Rate|~0%|Instruction cache well-behaved|
|L1D Miss Rate|49.8%|Half of all data accesses missed L1|
|L1D MPKI|~124|Very high miss intensity (memory-bound workload)|
|Avg. L1D Miss Latency|~78,000 ticks|Memory stalls extremely long|
|L2 Hit Ratio|66%|1/3 of L2 misses → DRAM access|
|Branch Pred. Mispredict Rate|0.03%|Branching handled very well (not a bottleneck)|
|Instruction Mix|73% IntAlu, 27% memory ops|Heavy integer + memory workloa|

·      The baseline run shows severe memory bottlenecks: nearly half of L1D accesses miss, with miss penalties of tens of thousands of cycles.

·      This results in IPC ≈ 0.05, with the pipeline committing zero instructions in ~97% of cycles.

·      Branch prediction is highly accurate and does not contribute to stalls.

·      Instruction mix is dominated by integer arithmetic and memory operations, with stores forming a large share.

·      The cycle-by-cycle analysis confirms that structural and data hazards in the memory subsystem are the main performance limiter, not branch or execution resources.jggjjjj
