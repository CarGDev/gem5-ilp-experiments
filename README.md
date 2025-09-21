# PipelineGem5: Comprehensive Gem5 CPU Pipeline Analysis Project

This project provides a comprehensive suite of tools and scripts for analyzing modern CPU pipeline performance using the Gem5 simulator. The project encompasses five major analysis domains: branch prediction, pipeline simulation, multithreading (CMP), superscalar execution, and integrated technique analysis. Each component provides detailed insights into different aspects of processor microarchitecture and their interactions.

## Project Structure

```text
pipelineGem5/
├── branchPrediction/                    # Branch prediction analysis
│   ├── BiModeBP/                       # Bimodal branch predictor results
│   ├── LocalBP/                        # Local branch predictor results
│   ├── LTAGE/                          # LTAGE branch predictor results
│   ├── TournamentBP/                   # Tournament branch predictor results
│   ├── parse_bp.sh                     # Results parser and analyzer
│   ├── run_bp.sh                       # Branch prediction simulation runner
│   └── Branch_Prediction_Analysis_Report.md
├── pipelineSimulation/                  # Pipeline simulation analysis
│   ├── o3-baseline/                    # Baseline O3 CPU performance
│   ├── o3-trace/                       # Cycle-by-cycle pipeline traces
│   ├── pipeline/                       # Additional pipeline configurations
│   ├── pipeline_sim.sh                 # Main pipeline simulation script
│   ├── Technical_Analysis_Report.md    # Detailed technical analysis
│   └── README.md                       # Pipeline-specific documentation
├── multiThreading/                      # Chip Multi-Processor (CMP) analysis
│   ├── CMP2/                          # Dual-core CMP configuration
│   ├── CMP4/                          # Quad-core CMP configuration
│   ├── ST1/                           # Single-threaded baseline
│   ├── parse_smt.sh                   # CMP results parser
│   ├── run_cmp.sh                     # CMP simulation runner
│   └── CMP_Analysis_Report.md         # CMP performance analysis
├── multiScalar/                        # Superscalar execution analysis
│   ├── W1/                            # 1-wide pipeline configuration
│   ├── W2/                            # 2-wide pipeline configuration
│   ├── W4/                            # 4-wide pipeline configuration
│   ├── W8/                            # 8-wide pipeline configuration
│   ├── parse_superscalar.sh           # Superscalar results parser
│   ├── run_superscalar.sh             # Superscalar simulation runner
│   └── Superscalar_Analysis_Report.md # ILP analysis and findings
├── integratedAnalysis/                 # Integrated technique analysis
│   ├── BP-LocalBP/                    # Branch prediction + SMT integration
│   │   ├── W1/SMT1/                  # Single-threaded configuration
│   │   └── W1/SMT2/                  # Dual-threaded SMT configuration
│   ├── parse_integrated.sh            # Integrated analysis parser
│   ├── run_integrated.sh              # Integrated simulation runner
│   └── Integrated_Analysis_Report.md # Technique interaction analysis
└── README.md                          # This comprehensive documentation
```

## Overview

This project provides five comprehensive analysis components, each focusing on different aspects of modern processor design:

### 1. Branch Prediction Analysis (`branchPrediction/`)

**Purpose**: Evaluates and compares different branch prediction algorithms to understand their effectiveness across various workloads.

**Key Findings**:
- All four predictors (BiModeBP, LocalBP, LTAGE, TournamentBP) achieved near-identical performance (~0.0477 IPC)
- Branch prediction accuracy exceeded 99.9% across all configurations
- Memory latency (50% L1D miss rate) dominated performance, masking predictor differences
- Sophisticated predictors provided no measurable advantage over simple approaches for this workload

**Technical Configuration**:
- **CPU Model**: DerivO3CPU (Out-of-Order execution)
- **Pipeline Width**: 8 instructions per cycle
- **ROB Size**: 192 entries
- **Cache Hierarchy**: 32KB L1I, 64KB L1D (2-way), 2MB L2 (8-way)
- **Simulation Length**: 50M instructions
- **Benchmark**: memtouch (memory-intensive workload)

**Analysis Components**:
- **Predictor Comparison**: Direct performance comparison across four predictor types
- **Cache Interaction**: Analysis of how branch prediction affects memory system behavior
- **Functional Unit Utilization**: Impact of branch prediction on execution efficiency
- **Workload Characterization**: Understanding why predictors performed uniformly

### 2. Pipeline Simulation Analysis (`pipelineSimulation/`)

**Purpose**: Performs detailed CPU pipeline analysis with cycle-by-cycle tracing to identify performance bottlenecks and pipeline behavior.

**Key Findings**:
- Baseline IPC of ~0.051 indicates severe pipeline stalls (97% of cycles retired no instructions)
- L1D miss rate of ~50% creates memory wall bottleneck
- Average L1D miss latency of ~78,000 ticks dominates execution time
- Branch prediction worked effectively with <0.05% misprediction rate

**Technical Configuration**:
- **CPU Model**: DerivO3CPU with 8-wide superscalar design
- **Clock Speed**: 2GHz (500 ps period)
- **Pipeline Widths**: 8-wide fetch, decode, issue, commit
- **Queue Sizes**: ROB=192, IQ=64, LQ=32, SQ=32
- **Branch Predictor**: Tournament predictor with 4K BTB entries
- **Cache Configuration**: 32KB L1I, 32KB L1D, 1MB L2

**Analysis Components**:
- **Baseline Performance**: Measures IPC with standard O3 configuration
- **Pipeline Tracing**: Generates detailed traces of Fetch, Decode, Rename, IEW, and Commit stages
- **Queue Analysis**: Examines instruction queue (IQ), reorder buffer (ROB), load queue (LQ), and store queue (SQ) behavior
- **Memory System Analysis**: Detailed cache performance and miss pattern analysis

### 3. Multithreading Analysis (`multiThreading/`)

**Purpose**: Analyzes Chip Multi-Processor (CMP) performance scaling and multi-core architectural trade-offs.

**Key Findings**:
- Perfect linear scaling from single-core (ST1) to dual-core (CMP2) with IPC=20.0
- Quad-core (CMP4) shows asymmetric core utilization with early termination
- Perfect cache hit rates (0.0% miss rate) across all configurations
- LTAGE branch predictor achieved perfect accuracy (0.0% misprediction rate)

**Technical Configuration**:
- **Pipeline Width**: 8 instructions per cycle per core
- **Queue Sizes**: ROB=192, IQ=64, LQ=32, SQ=32 per core
- **Functional Units**: 6 IntAlu, 2 IntMult/Div, 4 FloatAdd/Cmp/Cvt, 2 FloatMult/Div/Sqrt, 4 SIMD units
- **CPU Frequency**: 500 MHz
- **Cache Hierarchy**: L1I=32KB, L1D=32KB, L2=1MB (shared)
- **Simulation Length**: 20M instructions per configuration

**Analysis Components**:
- **Scaling Analysis**: Performance scaling from 1 to 4 cores
- **Resource Utilization**: Per-core instruction distribution and utilization
- **Cache Coherence**: Shared L2 cache behavior and inter-core interference
- **Workload Parallelization**: Analysis of parallelization potential and limitations

### 4. Superscalar Execution Analysis (`multiScalar/`)

**Purpose**: Evaluates instruction-level parallelism (ILP) scaling across different pipeline widths to understand superscalar effectiveness.

**Key Findings**:
- **Counterintuitive Result**: Increasing pipeline width from 1 to 8 instructions per cycle produced virtually no performance improvement
- IPC remained essentially constant at ~0.0477 across all configurations (W1 to W8)
- High data cache miss rate (~50%) creates memory bottleneck that dominates performance
- Limited instruction-level parallelism in the workload prevents effective superscalar scaling

**Technical Configuration**:
- **Pipeline Widths**: W1 (1-wide) to W8 (8-wide) configurations
- **Scalable Queue Sizes**: ROB=32×W, IQ=16×W, LQ=16×W, SQ=16×W
- **Branch Predictor**: LTAGE for consistent control hazard handling
- **Cache Configuration**: 32KB L1I, 64KB L1D, 2MB L2
- **Simulation Length**: 20M instructions per configuration

**Analysis Components**:
- **ILP Scaling**: Performance scaling with increasing pipeline width
- **Memory Bottleneck Analysis**: Impact of cache miss rates on superscalar effectiveness
- **Instruction Mix Analysis**: Understanding workload characteristics that limit ILP
- **Resource Utilization**: Functional unit usage patterns across different widths

### 5. Integrated Analysis (`integratedAnalysis/`)

**Purpose**: Analyzes the interactions between branch prediction, superscalar execution, and simultaneous multithreading (SMT) techniques.

**Key Findings**:
- Single-threaded configuration (SMT1) achieved IPC of 0.047695 with severe underutilization
- High L1D miss rate (49.97%) and L1I miss rate (3.19%) create frequent memory stalls
- SMT2 configuration failed to complete, highlighting SMT implementation complexity
- Local Branch Predictor achieved good accuracy (0.027% misprediction rate) but benefits were masked by memory bottlenecks

**Technical Configuration**:
- **CPU Type**: BaseO3CPU (Out-of-Order)
- **Branch Predictor**: LocalBP (Local Branch Predictor)
- **Pipeline Widths**: Fetch=1, Decode=1, Dispatch=8, Issue=1, Commit=1
- **Queue Sizes**: ROB=64, IQ=32, LQ=32, SQ=32
- **SMT Policies**: RoundRobin for commit/fetch, Partitioned for queues

**Analysis Components**:
- **Technique Integration**: Analysis of how multiple techniques interact
- **Complexity-Performance Trade-offs**: Evaluation of implementation complexity vs. performance gains
- **Resource Contention**: Analysis of shared resource utilization in SMT configurations
- **System Balance**: Understanding holistic system performance characteristics

## Usage Instructions

### Prerequisites

Before running any analysis, ensure you have:

1. **Gem5 Installation**: Properly built Gem5 simulator with X86 architecture support
2. **Test Binary**: The `memtouch` benchmark binary (or substitute with your preferred workload)
3. **Path Configuration**: Update paths in scripts to match your environment

### 1. Branch Prediction Analysis

**Purpose**: Compare different branch prediction algorithms and analyze their effectiveness.

**Quick Start**:
```bash
cd branchPrediction
./run_bp.sh        # Run simulations for all predictor types
./parse_bp.sh       # Parse and display results
```

**Detailed Usage**:
```bash
# Run individual predictor analysis
cd branchPrediction
./run_bp.sh

# The script will:
# - Test BiModeBP, LocalBP, LTAGE, and TournamentBP predictors
# - Generate results in individual directories (BiModeBP/, LocalBP/, etc.)
# - Create simout and simerr files for each run
# - Generate stats.txt with detailed metrics

# Parse results for analysis
./parse_bp.sh

# This will extract and display:
# - IPC (Instructions Per Cycle)
# - Branch prediction accuracy
# - Cache miss rates
# - Performance comparisons
```

**Expected Output**: Results showing near-identical performance across all predictors (~0.0477 IPC) due to memory bottleneck dominance.

### 2. Pipeline Simulation Analysis

**Purpose**: Perform detailed pipeline analysis with cycle-by-cycle tracing to identify bottlenecks.

**Quick Start**:
```bash
cd pipelineSimulation
./pipeline_sim.sh
```

**Detailed Usage**:
```bash
cd pipelineSimulation
./pipeline_sim.sh

# The script performs two main analyses:
# 1. Baseline O3 performance measurement (200M instructions)
# 2. Cycle-by-cycle pipeline tracing (5M instructions)

# Results will be generated in:
# - o3-baseline/: Baseline performance metrics
# - o3-trace/: Detailed pipeline traces and debug output
```

**Key Output Files**:
- `o3-baseline/stats.txt`: Comprehensive baseline statistics
- `o3-trace/pipe.trace`: Cycle-by-cycle pipeline trace
- `o3-trace/stats.txt`: Detailed pipeline stage statistics

**Expected Findings**: Low IPC (~0.051) due to high L1D miss rate (~50%) creating memory wall bottleneck.

### 3. Multithreading (CMP) Analysis

**Purpose**: Analyze Chip Multi-Processor scaling behavior and multi-core performance.

**Quick Start**:
```bash
cd multiThreading
./run_cmp.sh        # Run CMP simulations
./parse_smt.sh      # Parse and analyze results
```

**Detailed Usage**:
```bash
cd multiThreading
./run_cmp.sh

# The script tests three configurations:
# - ST1: Single-threaded baseline
# - CMP2: Dual-core CMP
# - CMP4: Quad-core CMP

# Each configuration runs 20M instructions
# Results stored in ST1/, CMP2/, CMP4/ directories

# Parse results
./parse_smt.sh

# This extracts:
# - Per-core instruction counts
# - Aggregate IPC scaling
# - Cache performance metrics
# - Branch prediction accuracy
```

**Expected Findings**: Perfect linear scaling from ST1 to CMP2, asymmetric utilization in CMP4.

### 4. Superscalar Execution Analysis

**Purpose**: Evaluate instruction-level parallelism scaling across different pipeline widths.

**Quick Start**:
```bash
cd multiScalar
./run_superscalar.sh    # Run superscalar simulations
./parse_superscalar.sh  # Parse and analyze results
```

**Detailed Usage**:
```bash
cd multiScalar
./run_superscalar.sh

# Tests four pipeline width configurations:
# - W1: 1-wide pipeline (scalar)
# - W2: 2-wide pipeline
# - W4: 4-wide pipeline  
# - W8: 8-wide pipeline

# Queue sizes scale proportionally:
# - ROB: 32×W entries
# - IQ: 16×W entries
# - LQ/SQ: 16×W entries each

# Parse results
./parse_superscalar.sh

# Extracts:
# - IPC scaling across widths
# - Cache miss rate trends
# - Branch misprediction patterns
# - Resource utilization analysis
```

**Expected Findings**: Counterintuitive result showing no performance improvement with increased pipeline width due to memory bottleneck.

### 5. Integrated Analysis

**Purpose**: Analyze interactions between branch prediction, superscalar execution, and SMT techniques.

**Quick Start**:
```bash
cd integratedAnalysis
./run_integrated.sh     # Run integrated simulations
./parse_integrated.sh   # Parse and analyze results
```

**Detailed Usage**:
```bash
cd integratedAnalysis
./run_integrated.sh

# Tests integrated configurations:
# - SMT1: Single-threaded with LocalBP
# - SMT2: Dual-threaded SMT with LocalBP

# Analyzes technique interactions:
# - Branch prediction + superscalar execution
# - SMT resource sharing and contention
# - Complexity vs. performance trade-offs

# Parse results
./parse_integrated.sh

# Extracts:
# - Technique interaction effects
# - Resource contention analysis
# - Complexity-performance trade-offs
# - System balance characteristics
```

**Expected Findings**: SMT1 shows severe underutilization, SMT2 may fail due to implementation complexity.

## Configuration Parameters

### Environment Setup

**Required Paths** (modify in each script):
```bash
# Gem5 installation path
GEM5=/home/carlos/projects/gem5/gem5src/gem5

# Results output directory
RUNROOT=/home/carlos/projects/gem5/gem5-data/results

# Test binary path
CMD=/home/carlos/projects/gem5/gem5-run/memtouch/memtouch
```

### Simulation Parameters

**Branch Prediction Analysis**:
- **CPU Type**: DerivO3CPU (Out-of-Order execution)
- **Max Instructions**: 50,000,000 per predictor
- **Cache Configuration**: L1I=32KB, L1D=64KB, L2=2MB
- **Pipeline Width**: 8 instructions per cycle
- **ROB Size**: 192 entries
- **Branch Predictors**: BiModeBP, LocalBP, LTAGE, TournamentBP

**Pipeline Simulation**:
- **CPU Type**: DerivO3CPU
- **Clock Speed**: 2GHz (500 ps period)
- **Baseline Instructions**: 200M
- **Trace Instructions**: 5M
- **Cache Configuration**: L1I=32KB, L1D=32KB, L2=1MB
- **Debug Flags**: O3CPU, Fetch, Decode, Rename, IEW, Commit, Branch, Activity

**Multithreading (CMP)**:
- **CPU Type**: DerivO3CPU
- **Core Configurations**: 1, 2, 4 cores
- **Max Instructions**: 20M per configuration
- **Pipeline Width**: 8 instructions per cycle per core
- **Cache Configuration**: L1I=32KB, L1D=32KB, L2=1MB (shared)
- **Branch Predictor**: LTAGE

**Superscalar Execution**:
- **Pipeline Widths**: 1, 2, 4, 8 instructions per cycle
- **Scalable Queues**: ROB=32×W, IQ=16×W, LQ=16×W, SQ=16×W
- **Max Instructions**: 20M per configuration
- **Branch Predictor**: LTAGE
- **Cache Configuration**: L1I=32KB, L1D=64KB, L2=2MB

**Integrated Analysis**:
- **CPU Type**: BaseO3CPU
- **Branch Predictor**: LocalBP
- **Pipeline Widths**: Fetch=1, Decode=1, Dispatch=8, Issue=1, Commit=1
- **Queue Sizes**: ROB=64, IQ=32, LQ=32, SQ=32
- **SMT Policies**: RoundRobin (commit/fetch), Partitioned (queues)

## Output Files and Results Interpretation

### Understanding Simulation Outputs

Each analysis component generates specific output files that require different interpretation approaches:

#### Branch Prediction Analysis Outputs

**Key Files**:
- `stats.txt`: Comprehensive simulation statistics
- `simout`: Standard output log
- `simerr`: Error log (check for simulation issues)

**Critical Metrics to Analyze**:
```bash
# IPC (Instructions Per Cycle) - Higher is better
system.cpu.ipc = 0.047669

# Branch prediction accuracy
system.cpu.branchPred.condPredicted = 3516804
system.cpu.branchPred.condIncorrect = 1404
# Accuracy = (3516804 - 1404) / 3516804 = 99.96%

# Cache miss rates
system.cpu.dcache.overall_miss_rate::total = 0.4981  # 49.81% miss rate
```

**Interpretation Guidelines**:
- **IPC < 0.1**: Indicates severe performance bottlenecks (memory-bound workload)
- **Branch Accuracy > 99%**: Excellent prediction performance
- **L1D Miss Rate > 40%**: Memory subsystem is the primary bottleneck
- **Uniform IPC across predictors**: Memory bottleneck masks predictor differences

#### Pipeline Simulation Outputs

**Key Files**:
- `o3-baseline/stats.txt`: Baseline performance metrics
- `o3-trace/pipe.trace`: Cycle-by-cycle pipeline trace
- `o3-trace/stats.txt`: Detailed pipeline stage statistics

**Critical Metrics to Analyze**:
```bash
# Overall performance
simInsts = 25297289
system.cpu.numCycles = 498254810
# IPC = 25297289 / 498254810 = 0.051

# Pipeline stage utilization
system.cpu.fetch.idleCycles = 485000000  # High idle cycles indicate stalls
system.cpu.commit.idleCycles = 485000000

# Queue occupancy
system.cpu.iq.avgOccupancy = 15.2
system.cpu.rob.avgOccupancy = 45.8
```

**Interpretation Guidelines**:
- **IPC < 0.1**: Pipeline severely underutilized
- **High idle cycles**: Indicates frequent pipeline stalls
- **Queue occupancy < 50%**: Insufficient instruction-level parallelism
- **Memory miss latency > 1000 cycles**: Memory wall bottleneck

#### Multithreading (CMP) Outputs

**Key Files**:
- `ST1/stats.txt`: Single-threaded baseline
- `CMP2/stats.txt`: Dual-core configuration
- `CMP4/stats.txt`: Quad-core configuration

**Critical Metrics to Analyze**:
```bash
# Per-core instruction counts
system.cpu0.committedInsts = 20000000
system.cpu1.committedInsts = 19999658
system.cpu2.committedInsts = 361747    # Early termination
system.cpu3.committedInsts = 129365    # Early termination

# Aggregate performance
simInsts = 40491091
system.cpu.numCycles = 2000000
# Aggregate IPC = 40491091 / 2000000 = 20.2
```

**Interpretation Guidelines**:
- **Perfect linear scaling**: Ideal parallelization (ST1 → CMP2)
- **Asymmetric completion**: Workload dependencies or synchronization issues
- **Early termination**: Sequential dependencies limiting parallelization
- **Cache hit rate = 0%**: Workload fits entirely in L1 cache

#### Superscalar Execution Outputs

**Key Files**:
- `W1/stats.txt` through `W8/stats.txt`: Width-specific results

**Critical Metrics to Analyze**:
```bash
# IPC scaling across widths
W1: system.cpu.ipc = 0.047724
W2: system.cpu.ipc = 0.047737
W4: system.cpu.ipc = 0.047712
W8: system.cpu.ipc = 0.047688

# Cache miss rate trends
W1: system.cpu.dcache.overall_miss_rate::total = 0.4974
W8: system.cpu.dcache.overall_miss_rate::total = 0.4979
```

**Interpretation Guidelines**:
- **Constant IPC across widths**: Memory bottleneck dominates performance
- **Increasing cache miss rates**: Wider pipelines may increase cache pressure
- **Limited ILP**: Workload lacks sufficient instruction-level parallelism
- **Memory-bound workload**: Cache miss latency masks superscalar benefits

#### Integrated Analysis Outputs

**Key Files**:
- `W1/SMT1/stats.txt`: Single-threaded configuration
- `W1/SMT2/stats.txt`: Dual-threaded SMT (may be empty if failed)

**Critical Metrics to Analyze**:
```bash
# Single-threaded performance
system.cpu.ipc = 0.047695
system.cpu.dcache.overall_miss_rate::total = 0.4997
system.cpu.branchPred.condIncorrect = 724

# Resource utilization
system.cpu.rob.fullEvents = 16892
system.cpu.iq.fullEvents = 51
```

**Interpretation Guidelines**:
- **Low IPC with high miss rates**: Memory bottleneck dominates
- **High ROB full events**: Insufficient instruction window depth
- **SMT failure**: Implementation complexity or resource contention
- **Technique interactions**: Individual optimizations may not improve overall performance

### Performance Bottleneck Identification

#### Memory Wall Analysis
```bash
# High L1D miss rates (>40%) indicate memory bottleneck
system.cpu.dcache.overall_miss_rate::total = 0.4981

# High miss latency indicates memory subsystem limitations
system.cpu.dcache.avg_miss_latency = 83193  # ticks
```

#### Control Hazard Analysis
```bash
# Low branch misprediction rates indicate good prediction
system.cpu.branchPred.condIncorrect = 1404
system.cpu.branchPred.condPredicted = 3516804
# Misprediction rate = 1404 / 3516804 = 0.04%
```

#### Pipeline Utilization Analysis
```bash
# High idle cycles indicate pipeline stalls
system.cpu.fetch.idleCycles = 485000000
system.cpu.commit.idleCycles = 485000000

# Low queue occupancy indicates limited ILP
system.cpu.iq.avgOccupancy = 15.2  # out of 64 entries
```

### Key Performance Insights

#### 1. Memory Bottleneck Dominance
- **Finding**: L1D miss rates of ~50% across all analyses
- **Implication**: Memory latency dominates execution time, masking other optimizations
- **Recommendation**: Focus on memory subsystem optimization over CPU microarchitecture

#### 2. Branch Prediction Effectiveness
- **Finding**: All predictors achieve >99.9% accuracy
- **Implication**: Control hazards effectively eliminated
- **Recommendation**: Simple predictors sufficient for predictable workloads

#### 3. Superscalar Scaling Limitations
- **Finding**: No performance improvement with increased pipeline width
- **Implication**: Limited instruction-level parallelism in workload
- **Recommendation**: Workload-aware design over maximum theoretical performance

#### 4. Multi-Core Scaling Behavior
- **Finding**: Perfect linear scaling to dual-core, asymmetric quad-core utilization
- **Implication**: Workload-dependent parallelization potential
- **Recommendation**: Analyze workload characteristics before scaling core count

#### 5. Technique Integration Complexity
- **Finding**: SMT implementation failures and resource contention
- **Implication**: Integration complexity may outweigh performance benefits
- **Recommendation**: Holistic system design over individual technique optimization

## Customization and Extension

### Modifying Simulation Parameters

#### Changing Workloads
```bash
# Replace memtouch with your benchmark
CMD=/path/to/your/benchmark

# Update script paths
sed -i 's|memtouch|your_benchmark|g' run_*.sh
```

#### Adjusting Cache Configurations
```bash
# Modify cache sizes in scripts
--l1i_size=64kB --l1d_size=64kB --l2_size=2MB

# Adjust associativity
--l1i_assoc=4 --l1d_assoc=4 --l2_assoc=16
```

#### Scaling Simulation Length
```bash
# Increase instruction count for better statistics
--maxinsts=100000000  # 100M instructions

# Balance simulation time vs. statistical significance
```

### Adding New Analysis Components

#### Creating Custom Branch Predictors
```bash
# Add new predictor to PRED_LIST in run_bp.sh
PRED_LIST="LocalBP TournamentBP BiModeBP LTAGE YourCustomBP"

# Ensure predictor is available in Gem5 build
"$SE" --list-bp-types
```

#### Extending Pipeline Width Analysis
```bash
# Add wider configurations in run_superscalar.sh
for W in 1 2 4 8 16 32; do
  # Scale queue sizes appropriately
  ROB=$((W*32))
  IQ=$((W*16))
done
```

#### Implementing Custom SMT Policies
```bash
# Modify SMT configuration in integrated analysis
--smt-policy=RoundRobin
--smt-policy=Partitioned
--smt-policy=YourCustomPolicy
```

## Troubleshooting

### Common Issues and Solutions

#### Simulation Failures
```bash
# Check error logs
cat */simerr

# Common issues:
# - Insufficient memory
# - Invalid binary path
# - Gem5 build issues
# - Configuration conflicts
```

#### Performance Anomalies
```bash
# Verify configuration consistency
grep -r "cpu-type" */config.ini

# Check for resource conflicts
grep -r "numROBEntries" */stats.txt
```

#### Path Configuration Issues
```bash
# Update all script paths
find . -name "*.sh" -exec sed -i 's|/old/path|/new/path|g' {} \;

# Verify Gem5 installation
ls -la $GEM5/build/X86/gem5.opt
```

## Requirements and Dependencies

### System Requirements
- **Operating System**: Linux (Ubuntu 18.04+ recommended)
- **Memory**: 8GB+ RAM (16GB+ for large simulations)
- **Storage**: 10GB+ free space for results
- **CPU**: Multi-core processor recommended

### Software Dependencies
- **Gem5 Simulator**: Version 21.0+ with X86 support
- **Python**: 3.6+ (for Gem5 scripts)
- **GCC**: 7.0+ (for building Gem5)
- **Standard Unix Tools**: bash, awk, grep, sed

### Building Gem5
```bash
# Clone and build Gem5
git clone https://gem5.googlesource.com/public/gem5
cd gem5
scons build/X86/gem5.opt -j$(nproc)

# Verify build
build/X86/gem5.opt --version
```

## Contributing and Extending

### Adding New Analysis Types
1. Create new directory structure
2. Implement run and parse scripts
3. Add configuration templates
4. Update this README with new section
5. Test with multiple workloads

### Modifying Existing Analyses
1. Backup original configurations
2. Test changes incrementally
3. Validate results against known baselines
4. Update documentation
5. Consider backward compatibility

### Best Practices
- **Consistent Naming**: Use descriptive directory and file names
- **Parameter Documentation**: Document all configuration options
- **Error Handling**: Include comprehensive error checking
- **Result Validation**: Cross-check results across different analyses
- **Performance Considerations**: Balance simulation time vs. accuracy

## Summary and Key Insights

This comprehensive Gem5 pipeline analysis project provides valuable insights into modern processor design and performance characteristics. The five analysis components reveal several critical findings that challenge conventional wisdom in computer architecture:

### Major Discoveries

1. **Memory Wall Dominance**: Across all analyses, memory subsystem performance (specifically L1D cache miss rates of ~50%) emerges as the primary performance bottleneck, often masking the effects of sophisticated CPU microarchitecture optimizations.

2. **Predictor Uniformity**: Four fundamentally different branch prediction algorithms (BiModeBP, LocalBP, LTAGE, TournamentBP) achieve virtually identical performance (~0.0477 IPC), suggesting that predictor complexity may provide diminishing returns for certain workload classes.

3. **Superscalar Scaling Paradox**: Increasing pipeline width from 1 to 8 instructions per cycle produces no measurable performance improvement, highlighting the critical importance of workload characteristics in determining superscalar effectiveness.

4. **Multi-Core Scaling Patterns**: Perfect linear scaling from single-core to dual-core configurations, followed by asymmetric utilization in quad-core systems, demonstrates workload-dependent parallelization potential.

5. **Integration Complexity**: Simultaneous multithreading implementations reveal significant complexity challenges, with SMT configurations failing to complete successfully due to resource contention and implementation difficulties.

### Educational Value

This project serves as an excellent educational resource for understanding:
- **System Balance**: The importance of balanced system design over individual component optimization
- **Workload Awareness**: How workload characteristics determine the effectiveness of architectural techniques
- **Bottleneck Analysis**: Methods for identifying and analyzing performance bottlenecks
- **Simulation Methodology**: Best practices for computer architecture simulation and analysis

### Research Implications

The findings support several important research directions:
- **Workload-Aware Design**: Matching microarchitectural complexity to actual application requirements
- **Memory System Optimization**: Prioritizing memory subsystem improvements over CPU microarchitecture enhancements
- **Energy Efficiency**: Simpler predictors may be more energy-efficient for predictable workloads
- **Holistic System Design**: The need for integrated approaches rather than isolated technique optimization

### Practical Applications

For practitioners in computer architecture, this project demonstrates:
- **Design Space Exploration**: Efficient methods for evaluating architectural trade-offs
- **Performance Debugging**: Techniques for identifying and analyzing performance bottlenecks
- **Simulation Best Practices**: Guidelines for conducting meaningful architectural simulations
- **Result Interpretation**: Methods for understanding and validating simulation results

This project provides a comprehensive foundation for understanding modern processor design challenges and serves as a valuable resource for students, researchers, and practitioners in computer architecture.
